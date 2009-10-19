From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 00:57:40 +0400
Message-ID: <20091019205740.GD5233@lenovo>
References: <200910190002.39937.denys@visp.net.lb> <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com> <4ADC5D3B.8010006@gmail.com> <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com> <20091019155034.GA5233@lenovo> <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com> <4ADC9DE2.5010308@gmail.com> <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com> <4ADCB3A4.8060408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ADCB3A4.8060408@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Eric Dumazet - Mon, Oct 19, 2009 at 08:44:52PM +0200]
...
| 
| There is still a race here, since you do a dev_put(po->ppoe_dev); without any lock held
| 
| So pppoe_flush_dev() can run concurently and dev_put(po->ppoe_dev) at same time.
| 
| In fact pppoe_flush_dev() can change po->ppoe_dev anytime, so you should check
| all occurences of po->ppoe_dev use in the code and check if appropriate locking is done.
| 
| pppoe_rcv_core() is not safe
| pppoe_ioctl() is not safe
| pppoe_sendmsg() is not safe
| __pppoe_xmit() is not safe
| 

Eric, Michal, please take a look (compile-test only).
There is still unclear moment for NETDEV_CHANGEMTU
since one could be doing this in say endless loop from
userspace calling device to flush all the time which
implies dev_put as a result :(

Comments are welcome (and complains as well). I'll be able to
continue handling (or reply to mail) tomorrow evening only.
Anyway -- this patch is ugly enough but may happen to work.

	-- Cyrill
---
 drivers/net/pppoe.c |   79 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 62 insertions(+), 17 deletions(-)

Index: linux-2.6.git/drivers/net/pppoe.c
=====================================================================
--- linux-2.6.git.orig/drivers/net/pppoe.c
+++ linux-2.6.git/drivers/net/pppoe.c
@@ -386,14 +386,19 @@ static struct notifier_block pppoe_notif
 static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_sock *po = pppox_sk(sk);
-	struct pppox_sock *relay_po;
+	struct pppox_sock *relay_po = NULL;
+	struct net *net = NULL;
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
-		relay_po = get_item_by_addr(dev_net(po->pppoe_dev),
-						&po->pppoe_relay);
-		if (relay_po == NULL)
+		spin_lock(&flush_lock);
+		if (po->pppoe_dev)
+			net = dev_net(po->pppoe_dev);
+		spin_unlock(&flush_lock);
+		if (net)
+			relay_po = get_item_by_addr(net, &po->pppoe_relay);
+		if (!net || !relay_po)
 			goto abort_kfree;
 
 		if ((sk_pppox(relay_po)->sk_state & PPPOX_CONNECTED) == 0)
@@ -652,12 +657,15 @@ static int pppoe_connect(struct socket *
 	/* Delete the old binding */
 	if (stage_session(po->pppoe_pa.sid)) {
 		pppox_unbind_sock(sk);
+		spin_lock(&flush_lock);
 		if (po->pppoe_dev) {
 			pn = pppoe_pernet(dev_net(po->pppoe_dev));
 			delete_item(pn, po->pppoe_pa.sid,
 				po->pppoe_pa.remote, po->pppoe_ifindex);
 			dev_put(po->pppoe_dev);
+			po->pppoe_dev = NULL;
 		}
+		spin_unlock(&flush_lock);
 		memset(sk_pppox(po) + 1, 0,
 		       sizeof(struct pppox_sock) - sizeof(struct sock));
 		sk->sk_state = PPPOX_NONE;
@@ -670,7 +678,9 @@ static int pppoe_connect(struct socket *
 		if (!dev)
 			goto end;
 
+		spin_lock(&flush_lock);
 		po->pppoe_dev = dev;
+		spin_unlock(&flush_lock);
 		po->pppoe_ifindex = dev->ifindex;
 		pn = pppoe_pernet(dev_net(dev));
 		write_lock_bh(&pn->hash_lock);
@@ -708,10 +718,12 @@ end:
 	release_sock(sk);
 	return error;
 err_put:
+	spin_lock(&flush_lock);
 	if (po->pppoe_dev) {
 		dev_put(po->pppoe_dev);
 		po->pppoe_dev = NULL;
 	}
+	spin_unlock(&flush_lock);
 	goto end;
 }
 
@@ -738,6 +750,7 @@ static int pppoe_ioctl(struct socket *so
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po = pppox_sk(sk);
+	unsigned int mtu = 0;
 	int val;
 	int err;
 
@@ -746,11 +759,19 @@ static int pppoe_ioctl(struct socket *so
 		err = -ENXIO;
 		if (!(sk->sk_state & PPPOX_CONNECTED))
 			break;
-
+		err = -EBUSY;
+		if (!spin_trylock(&flush_lock))
+			break;
+		err = -ENODEV;
+		if (po->pppoe_dev) {
+			mtu = po->pppoe_dev->mtu;
+			err = 0;
+		}
+		spin_unlock(&flush_lock);
+		if (err)
+			break;
 		err = -EFAULT;
-		if (put_user(po->pppoe_dev->mtu -
-			     sizeof(struct pppoe_hdr) -
-			     PPP_HDRLEN,
+		if (put_user(mtu - sizeof(struct pppoe_hdr) - PPP_HDRLEN,
 			     (int __user *)arg))
 			break;
 		err = 0;
@@ -760,14 +781,22 @@ static int pppoe_ioctl(struct socket *so
 		err = -ENXIO;
 		if (!(sk->sk_state & PPPOX_CONNECTED))
 			break;
-
+		err = -EBUSY;
+		if (!spin_trylock(&flush_lock))
+			break;
+		err = -ENODEV;
+		if (po->pppoe_dev) {
+			mtu = po->pppoe_dev->mtu;
+			err = 0;
+		}
+		spin_unlock(&flush_lock);
+		if (err)
+			break;
 		err = -EFAULT;
 		if (get_user(val, (int __user *)arg))
 			break;
 
-		if (val < (po->pppoe_dev->mtu
-			   - sizeof(struct pppoe_hdr)
-			   - PPP_HDRLEN))
+		if (val < (mtu - sizeof(struct pppoe_hdr) - PPP_HDRLEN))
 			err = 0;
 		else
 			err = -EINVAL;
@@ -842,7 +871,7 @@ static int pppoe_sendmsg(struct kiocb *i
 	int error;
 	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 	char *start;
 
 	lock_sock(sk);
@@ -856,7 +885,15 @@ static int pppoe_sendmsg(struct kiocb *i
 	hdr.code = 0;
 	hdr.sid = po->num;
 
+	spin_lock(&flush_lock);
 	dev = po->pppoe_dev;
+	if (!dev) {
+		spin_unlock(&flush_lock);
+		error = -ENODEV;
+		goto end;
+	}
+	dev_hold(dev);
+	spin_unlock(&flush_lock);
 
 	error = -EMSGSIZE;
 	if (total_len > (dev->mtu + dev->hard_header_len))
@@ -899,6 +936,8 @@ static int pppoe_sendmsg(struct kiocb *i
 	dev_queue_xmit(skb);
 
 end:
+	if (dev)
+		dev_put(dev);
 	release_sock(sk);
 	return error;
 }
@@ -911,15 +950,19 @@ end:
 static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_sock *po = pppox_sk(sk);
-	struct net_device *dev = po->pppoe_dev;
+	struct net_device *dev;
 	struct pppoe_hdr *ph;
 	int data_len = skb->len;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
 
-	if (!dev)
-		goto abort;
+	spin_lock(&flush_lock);
+	if (!po->pppoe_dev)
+		goto abort_unlock;
+	dev = po->pppoe_dev;
+	dev_hold(dev);
+	spin_unlock(&flush_lock);
 
 	/* Copy the data if there is no space for the header or if it's
 	 * read-only.
@@ -942,11 +985,13 @@ static int __pppoe_xmit(struct sock *sk,
 
 	dev_hard_header(skb, dev, ETH_P_PPP_SES,
 			po->pppoe_pa.remote, NULL, data_len);
-
 	dev_queue_xmit(skb);
+	dev_put(dev);
 
 	return 1;
 
+abort_unlock:
+	spin_unlock(&flush_lock);
 abort:
 	kfree_skb(skb);
 	return 1;
