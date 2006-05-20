From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannel subsystem update.
Date: Sat, 20 May 2006 19:52:02 +0400
Message-ID: <20060520155202.GA31923@2ka.mipt.ru>
References: <200605051248.42662.kelly@au.ibm.com> <200605161102.29472.kelly@au.ibm.com> <20060516061909.GA28670@2ka.mipt.ru> <20060515.235712.26771832.davem@davemloft.net> <20060516173416.GA22552@2ka.mipt.ru> <20060518103443.GB26183@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30677 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751326AbWETPwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 May 2006 11:52:19 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060518103443.GB26183@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The more I think about TCP processing in netchannels, the more I get
close to the following ideas:
 
 * map netchannel to socket.
 * implement own TCP (receiving for now) state machine.

So I would like to ask people, what do we want for netchannels
 
 * existing Linux TCP stack
 * fairly simple minimalistic RFC compliant stack

While developing first apporoach I've found that input TCP processing 
sometimes refers to dst_entry which can only be obtained through the input
routing code. You can find appropriate changes in attached incremental patch.
Full netchannel patch can be found at homepage [1].

Implementations is fairly proof-of-concept,
since I do not like the idea to bind netchannel to socket.<br/>
All TCP state machine is handled inside socket code, so userspace
must create listening socket, wait until new connection is created,
accept it and the bind netchannel to the newly created socket for
established connection. All further data flow is handled inside
netchannels, but actually it is not working as expected yet.

So question is how to process TCP state machine for netchannels: bind
them to socket and use existing code, or create small netchannel TCP
state machine?


1. Netchannel homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

Initial TCP support for netchannels. Incremental patch.
Proof-of-concept only.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
index 7ab2fa0..c161809 100644
--- a/include/linux/netchannel.h
+++ b/include/linux/netchannel.h
@@ -55,6 +55,7 @@ struct unetchannel_control
 	__u32			len;
 	__u32			flags;
 	__u32			timeout;
+	unsigned int		fd;
 };
 
 #ifdef __KERNEL__
@@ -77,6 +78,8 @@ struct netchannel
 	unsigned int		qlen;
 
 	void			*priv;
+
+	struct inode 		*inode;
 };
 
 struct netchannel_cache_head
diff --git a/net/core/netchannel.c b/net/core/netchannel.c
index 96e5e5b..a33ed60 100644
--- a/net/core/netchannel.c
+++ b/net/core/netchannel.c
@@ -25,6 +25,7 @@
 #include <linux/notifier.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <linux/file.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
 #include <linux/highmem.h>
@@ -114,7 +115,7 @@ static struct netchannel *netchannel_che
 	struct netchannel *nc;
 	struct hlist_node *node;
 	int found = 0;
-	
+
 	hlist_for_each_entry_rcu(nc, node, &bucket->head, node) {
 		if (netchannel_hash_equal_full(&nc->unc, unc)) {
 			found = 1;
@@ -125,6 +126,30 @@ static struct netchannel *netchannel_che
 	return (found)?nc:NULL;
 }
 
+static void netchannel_mmap_cleanup(struct netchannel *nc)
+{
+	unsigned int i;
+	struct netchannel_mmap *m = nc->priv;
+
+	for (i=0; i<m->pnum; ++i)
+		__free_page(m->page[i]);
+
+	kfree(m);
+}
+
+static void netchannel_cleanup(struct netchannel *nc)
+{
+	switch (nc->unc.type) {
+		case NETCHANNEL_COPY_USER:
+			break;
+		case NETCHANNEL_MMAP:
+			netchannel_mmap_cleanup(nc);
+			break;
+		default:
+			break;
+	}
+}
+
 static void netchannel_free_rcu(struct rcu_head *rcu)
 {
 	struct netchannel *nc = container_of(rcu, struct netchannel, rcu_head);
@@ -365,9 +390,11 @@ int netchannel_recv(struct sk_buff *skb)
 
 	skb_queue_tail(&nc->recv_queue, skb);
 	nc->qlen += skb->len;
+	wake_up(&nc->wait);
 
 unlock:
 	rcu_read_unlock();
+	
 	return err;
 }
 
@@ -420,9 +447,68 @@ static struct sk_buff *netchannel_get_sk
 	return skb;
 }
 
-/*
- * Actually it should be something like recvmsg().
- */
+static int netchannel_copy_to_user_tcp(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
+{
+	struct tcphdr *th;
+	int err = -ENODEV;
+	struct socket *sock;
+	struct sock *sk;
+	struct sk_buff *skb;
+
+	skb = netchannel_get_skb(nc, timeout, &err);
+	if (!skb)
+		return err;
+
+	if (!nc->inode)
+		goto err_out_free;
+	sock = SOCKET_I(nc->inode);
+	if (!sock || !sock->sk)
+		goto err_out_free;
+
+	sk = sock->sk;
+
+	__skb_pull(skb, skb->nh.iph->ihl*4);
+
+	skb->h.raw = skb->data;
+
+	th = skb->h.th;
+
+	printk("netchannel: TCP: syn: %u, fin: %u, rst: %u, psh: %u, ack: %u, urg: %u, ece: %u, cwr: %u, res1: %u, doff: %u.\n",
+			th->syn, th->fin, th->rst, th->psh, th->ack, th->urg, th->ece, th->cwr, th->res1, th->doff);
+	
+	if (sk->sk_state == TCP_ESTABLISHED) {
+		struct iovec to;
+		unsigned int copied;
+		
+		to.iov_base = arg;
+		to.iov_len = *len;
+
+		copied = skb->len;
+		if (copied > *len)
+			copied = *len;
+
+		if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+			err = skb_copy_datagram_iovec(skb, 0, &to, copied);
+		} else {
+			err = skb_copy_and_csum_datagram_iovec(skb,0, &to);
+		}
+
+		*len = (err == 0)?copied:0;
+	}
+	
+	nc->qlen -= skb->len;
+
+	err = sk->sk_backlog_rcv(sk, skb);
+	printk("netchannel: TCP: sk_backlog_rcv() ret: %d.\n", err);
+	return err;
+
+err_out_free:
+	nc->qlen -= skb->len;
+	kfree_skb(skb);
+
+	return err;
+}
+
 static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
 {
 	unsigned int copied;
@@ -632,30 +718,6 @@ err_out_free:
 	
 }
 
-static void netchannel_mmap_cleanup(struct netchannel *nc)
-{
-	unsigned int i;
-	struct netchannel_mmap *m = nc->priv;
-
-	for (i=0; i<m->pnum; ++i)
-		__free_page(m->page[i]);
-
-	kfree(m);
-}
-
-static void netchannel_cleanup(struct netchannel *nc)
-{
-	switch (nc->unc.type) {
-		case NETCHANNEL_COPY_USER:
-			break;
-		case NETCHANNEL_MMAP:
-			netchannel_mmap_cleanup(nc);
-			break;
-		default:
-			break;
-	}
-}
-
 static int netchannel_setup(struct netchannel *nc)
 {
 	int ret = 0;
@@ -668,7 +730,17 @@ static int netchannel_setup(struct netch
 	
 	switch (nc->unc.type) {
 		case NETCHANNEL_COPY_USER:
-			nc->nc_read_data = &netchannel_copy_to_user;
+			switch (nc->unc.proto) {
+				case IPPROTO_UDP:
+					nc->nc_read_data = &netchannel_copy_to_user;
+					break;
+				case IPPROTO_TCP:
+					nc->nc_read_data = &netchannel_copy_to_user_tcp;
+					break;
+				default:
+					ret = -EINVAL;
+					break;
+			}
 			break;
 		case NETCHANNEL_MMAP:
 			ret = netchannel_mmap_setup(nc);
@@ -681,15 +753,53 @@ static int netchannel_setup(struct netch
 	return ret;
 }
 
+static int netchannel_bind(struct unetchannel_control *ctl)
+{
+	struct netchannel *nc;
+	int err = -EINVAL, fput_needed;
+	struct netchannel_cache_head *bucket;
+	struct file *file;
+	struct inode *inode;
+
+	file = fget_light(ctl->fd, &fput_needed);
+	if (!file)
+		goto err_out_exit;
+
+	inode = igrab(file->f_dentry->d_inode);
+	if (!inode)
+		goto err_out_fput;
+
+	bucket = netchannel_bucket(&ctl->unc);
+	
+	mutex_lock(&bucket->mutex);
+	
+	nc = netchannel_check_full(&ctl->unc, bucket);
+	if (!nc) {
+		err = -ENODEV;
+		goto err_out_unlock;
+	}
+
+	nc->inode = inode;
+
+	fput_light(file, fput_needed);
+	mutex_unlock(&bucket->mutex);
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
+err_out_fput:
+	fput_light(file, fput_needed);
+err_out_exit:
+	return err;
+}
+
 static int netchannel_create(struct unetchannel *unc)
 {
 	struct netchannel *nc;
 	int err = -ENOMEM;
 	struct netchannel_cache_head *bucket;
 	
-	if (!netchannel_hash_table)
-		return -ENODEV;
-
 	nc = kmem_cache_alloc(netchannel_cache, GFP_KERNEL);
 	if (!nc)
 		return -ENOMEM;
@@ -759,6 +869,11 @@ static int netchannel_remove(struct unet
 	hlist_del_rcu(&nc->node);
 	hit = nc->hit;
 	
+	if (nc->inode) {
+		iput(nc->inode);
+		nc->inode = NULL;
+	}
+	
 	netchannel_put(nc);
 	err = 0;
 
@@ -839,9 +954,11 @@ asmlinkage long sys_netchannel_control(v
 
 	switch (ctl.cmd) {
 		case NETCHANNEL_CREATE:
-		case NETCHANNEL_BIND:
 			ret = netchannel_create(&ctl.unc);
 			break;
+		case NETCHANNEL_BIND:
+			ret = netchannel_bind(&ctl);
+			break;
 		case NETCHANNEL_REMOVE:
 			ret = netchannel_remove(&ctl.unc);
 			break;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 672950e..eb2dc12 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -727,7 +727,10 @@ int tcp_v4_conn_request(struct sock *sk,
 #endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
-	if (((struct rtable *)skb->dst)->rt_flags &
+	if (!skb->dst) {
+		if (MULTICAST(daddr))
+			goto drop;
+	} else if (((struct rtable *)skb->dst)->rt_flags &
 	    (RTCF_BROADCAST | RTCF_MULTICAST))
 		goto drop;
 
@@ -924,15 +927,21 @@ static struct sock *tcp_v4_hnd_req(struc
 	struct iphdr *iph = skb->nh.iph;
 	struct sock *nsk;
 	struct request_sock **prev;
+	int iif;
 	/* Find possible connection requests. */
 	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
 						       iph->saddr, iph->daddr);
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
+	if (!skb->dst)
+		iif = 0;
+	else
+		iif = inet_iif(skb);
+
 	nsk = __inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
 					th->source, skb->nh.iph->daddr,
-					ntohs(th->dest), inet_iif(skb));
+					ntohs(th->dest), iif);
 
 	if (nsk) {
 		if (nsk->sk_state != TCP_TIME_WAIT) {

-- 
	Evgeniy Polyakov
