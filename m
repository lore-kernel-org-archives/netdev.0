From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 17:59:20 +0400
Message-ID: <20091020135920.GB5181@lenovo>
References: <200910190002.39937.denys@visp.net.lb> <200910201452.58789.denys@visp.net.lb> <20091020134217.GA5181@lenovo> <200910201650.10066.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:37975 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbZJTN7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 09:59:19 -0400
Content-Disposition: inline
In-Reply-To: <200910201650.10066.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Denys Fedoryschenko - Tue, Oct 20, 2009 at 04:50:09PM +0300]
|
...
| >
| > Thanks Denys, I'm preparing new patch (just back from office
| > and had no inet connection that is why reply is delayed, sorry).
| There is no problem at all.
| This rename operation is just future operation and host is redundant, so i can 
| do tests on it anytime.
| 

ok, here is it, please try (it's still a draft version though)

	-- Cyrill
---
 drivers/net/pppoe.c |  106 +++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 81 insertions(+), 25 deletions(-)

Index: linux-2.6.git/drivers/net/pppoe.c
=====================================================================
--- linux-2.6.git.orig/drivers/net/pppoe.c
+++ linux-2.6.git/drivers/net/pppoe.c
@@ -313,8 +313,8 @@ static void pppoe_flush_dev(struct net_d
 			sk = sk_pppox(po);
 			spin_lock(&flush_lock);
 			po->pppoe_dev = NULL;
-			spin_unlock(&flush_lock);
 			dev_put(dev);
+			spin_unlock(&flush_lock);
 
 			/* We always grab the socket lock, followed by the
 			 * hash_lock, in that order.  Since we should
@@ -386,13 +386,21 @@ static struct notifier_block pppoe_notif
 static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_sock *po = pppox_sk(sk);
-	struct pppox_sock *relay_po;
+	struct pppox_sock *relay_po = NULL;
+	struct net_device *dev = NULL;
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
-		relay_po = get_item_by_addr(dev_net(po->pppoe_dev),
-						&po->pppoe_relay);
+		struct pppoe_net *pn = pppoe_pernet(sock_net(sk));
+		read_lock_bh(&pn->hash_lock);
+		dev = po->pppoe_dev;
+		if (dev) {
+			dev_hold(dev);
+			relay_po = get_item_by_addr(dev_net(dev),
+					&po->pppoe_relay);
+		}
+		read_unlock_bh(&pn->hash_lock);
 		if (relay_po == NULL)
 			goto abort_kfree;
 
@@ -401,6 +409,7 @@ static int pppoe_rcv_core(struct sock *s
 
 		if (!__pppoe_xmit(sk_pppox(relay_po), skb))
 			goto abort_put;
+		dev_put(dev);
 	} else {
 		if (sock_queue_rcv_skb(sk, skb))
 			goto abort_kfree;
@@ -412,6 +421,8 @@ abort_put:
 	sock_put(sk_pppox(relay_po));
 
 abort_kfree:
+	if (dev)
+		dev_put(dev);
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
@@ -625,8 +636,8 @@ static int pppoe_connect(struct socket *
 	struct sock *sk = sock->sk;
 	struct sockaddr_pppox *sp = (struct sockaddr_pppox *)uservaddr;
 	struct pppox_sock *po = pppox_sk(sk);
-	struct net_device *dev;
-	struct pppoe_net *pn;
+	struct net_device *dev = NULL;
+	struct pppoe_net *pn = NULL;
 	int error;
 
 	lock_sock(sk);
@@ -652,12 +663,15 @@ static int pppoe_connect(struct socket *
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
@@ -670,10 +684,11 @@ static int pppoe_connect(struct socket *
 		if (!dev)
 			goto end;
 
+		write_lock_bh(&pn->hash_lock);
+		dev_hold(dev);
 		po->pppoe_dev = dev;
 		po->pppoe_ifindex = dev->ifindex;
 		pn = pppoe_pernet(dev_net(dev));
-		write_lock_bh(&pn->hash_lock);
 		if (!(dev->flags & IFF_UP)) {
 			write_unlock_bh(&pn->hash_lock);
 			goto err_put;
@@ -700,6 +715,7 @@ static int pppoe_connect(struct socket *
 			goto err_put;
 
 		sk->sk_state = PPPOX_CONNECTED;
+		dev_put(dev);
 	}
 
 	po->num = sp->sa_addr.pppoe.sid;
@@ -708,10 +724,13 @@ end:
 	release_sock(sk);
 	return error;
 err_put:
+	dev_put(dev);
+	write_lock_bh(&pn->hash_lock);
 	if (po->pppoe_dev) {
 		dev_put(po->pppoe_dev);
 		po->pppoe_dev = NULL;
 	}
+	write_unlock_bh(&pn->hash_lock);
 	goto end;
 }
 
@@ -738,6 +757,8 @@ static int pppoe_ioctl(struct socket *so
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po = pppox_sk(sk);
+	struct pppoe_net *pn = pppoe_pernet(sock_net(sk));
+	unsigned int mtu = 0;
 	int val;
 	int err;
 
@@ -746,11 +767,17 @@ static int pppoe_ioctl(struct socket *so
 		err = -ENXIO;
 		if (!(sk->sk_state & PPPOX_CONNECTED))
 			break;
-
+		read_lock_bh(&pn->hash_lock);
+		err = -ENODEV;
+		if (po->pppoe_dev) {
+			mtu = po->pppoe_dev->mtu;
+			err = 0;
+		}
+		read_unlock_bh(&pn->hash_lock);
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
@@ -761,13 +788,21 @@ static int pppoe_ioctl(struct socket *so
 		if (!(sk->sk_state & PPPOX_CONNECTED))
 			break;
 
+		read_lock_bh(&pn->hash_lock);
+		err = -ENODEV;
+		if (po->pppoe_dev) {
+			mtu = po->pppoe_dev->mtu;
+			err = 0;
+		}
+		read_unlock_bh(&pn->hash_lock);
+		if (err)
+			break;
+
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
@@ -839,10 +874,11 @@ static int pppoe_sendmsg(struct kiocb *i
 	struct sk_buff *skb;
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po = pppox_sk(sk);
+	struct pppoe_net *pn = pppoe_pernet(sock_net(sk));
 	int error;
 	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 	char *start;
 
 	lock_sock(sk);
@@ -856,18 +892,27 @@ static int pppoe_sendmsg(struct kiocb *i
 	hdr.code = 0;
 	hdr.sid = po->num;
 
-	dev = po->pppoe_dev;
+	read_lock_bh(&pn->hash_lock);
+	error = -ENODEV;
+	if (po->pppoe_dev) {
+		dev = po->pppoe_dev;
+		dev_hold(dev);
+		error = 0;
+	}
+	read_unlock_bh(&pn->hash_lock);
+	if (error)
+		goto end;
 
 	error = -EMSGSIZE;
 	if (total_len > (dev->mtu + dev->hard_header_len))
-		goto end;
+		goto end_put;
 
 
 	skb = sock_wmalloc(sk, total_len + dev->hard_header_len + 32,
 			   0, GFP_KERNEL);
 	if (!skb) {
 		error = -ENOMEM;
-		goto end;
+		goto end_put;
 	}
 
 	/* Reserve space for headers. */
@@ -885,7 +930,7 @@ static int pppoe_sendmsg(struct kiocb *i
 	error = memcpy_fromiovec(start, m->msg_iov, total_len);
 	if (error < 0) {
 		kfree_skb(skb);
-		goto end;
+		goto end_put;
 	}
 
 	error = total_len;
@@ -898,6 +943,8 @@ static int pppoe_sendmsg(struct kiocb *i
 
 	dev_queue_xmit(skb);
 
+end_put:
+	dev_put(dev);
 end:
 	release_sock(sk);
 	return error;
@@ -911,21 +958,28 @@ end:
 static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_sock *po = pppox_sk(sk);
-	struct net_device *dev = po->pppoe_dev;
+	struct pppoe_net *pn = pppoe_pernet(sock_net(sk));
+	struct net_device *dev;
 	struct pppoe_hdr *ph;
 	int data_len = skb->len;
 
-	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
+	read_lock_bh(&pn->hash_lock);
+	if (!po->pppoe_dev) {
+		read_unlock_bh(&pn->hash_lock);
 		goto abort;
+	}
+	dev = po->pppoe_dev;
+	dev_hold(dev);
+	read_unlock_bh(&pn->hash_lock);
 
-	if (!dev)
-		goto abort;
+	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
+		goto abort_put;
 
 	/* Copy the data if there is no space for the header or if it's
 	 * read-only.
 	 */
 	if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len))
-		goto abort;
+		goto abort_put;
 
 	__skb_push(skb, sizeof(*ph));
 	skb_reset_network_header(skb);
@@ -944,9 +998,11 @@ static int __pppoe_xmit(struct sock *sk,
 			po->pppoe_pa.remote, NULL, data_len);
 
 	dev_queue_xmit(skb);
-
+	dev_put(dev);
 	return 1;
 
+abort_put:
+	dev_put(dev);
 abort:
 	kfree_skb(skb);
 	return 1;
