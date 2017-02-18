From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH][CFT] Saner error handling in skb_copy_datagram_iter()
 et.al.
Date: Sat, 18 Feb 2017 02:24:55 +0000
Message-ID: <20170218022455.GA2633@ZenIV.linux.org.uk>
References: <20170212054209.GQ13195@ZenIV.linux.org.uk>
 <2337836.67BmyCWMtR@debian64>
 <20170214013306.GS13195@ZenIV.linux.org.uk>
 <20170217.105420.2167024053308682803.davem@davemloft.net>
 <20170217170315.GE29622@ZenIV.linux.org.uk>
 <20170218000214.GA19777@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rlwinm@sdf.org,
        alexmcwhirter@triadic.us, chunkeey@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36084 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbdBRCZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 21:25:12 -0500
Content-Disposition: inline
In-Reply-To: <20170218000214.GA19777@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 12:02:14AM +0000, Al Viro wrote:
> On Fri, Feb 17, 2017 at 05:03:15PM +0000, Al Viro wrote:
> > On Fri, Feb 17, 2017 at 10:54:20AM -0500, David Miller wrote:
> > > From: Al Viro <viro@ZenIV.linux.org.uk>
> > > Date: Tue, 14 Feb 2017 01:33:06 +0000
> > > 
> > > > OK...  Remaining interesting question is whether it adds a noticable
> > > > overhead.  Could somebody try it on assorted benchmarks and see if
> > > > it slows the things down?  The patch in question follows:
> > > 
> > > That's about a 40 byte copy onto the stack for each invocation of this
> > > thing.  You can benchmark all you want, but it's clear that this is
> > > non-trivial amount of work and will take some operations from fitting
> > > in the cache to not doing so for sure.
> > 
> > In principle, that could be reduced a bit (32 bytes - ->type is never
> > changed, so we don't need to restore it), but that's not much of improvement...
> 
> Actually, I've a better solution.  Namely, analogue of iov_iter_advance()
> for going backwards.  The restriction is that you should never unroll
> further than where you've initially started *or* have the iovec, etc.
> array modified under you.  For iovec/kvec/bio_vec it's trivial, for pipe -
> a bit more convoluted, but still doable.  Then net/core/datagram.c stuff
> could simply use iov_iter_unroll() in case of error - all we need to keep
> track of is how much had we copied and that's easy to do.
> 
> The patch below is completely untested, but if it works it should avoid
> buggering the fast paths at all, still giving the same semantics re
> reverting ->msg_iter both on EINVAL and EFAULT.  Comments?

Incidentally, at least 4 other places in net/* can stop messing with
copying iov_iter just in case we'll need to revert and I'm fairly sure
there's more of the same in the tree.  FWIW, net/rds and net/tipc parts
(on top of the previous patch, also completely untested) follow:

diff --git a/net/rds/recv.c b/net/rds/recv.c
index 9d0666e5fe35..ed407156b3b4 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -564,7 +564,6 @@ int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		goto out;
 
 	while (1) {
-		struct iov_iter save;
 		/* If there are pending notifications, do those - and nothing else */
 		if (!list_empty(&rs->rs_notify_queue)) {
 			ret = rds_notify_queue_get(rs, msg);
@@ -600,7 +599,6 @@ int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		rdsdebug("copying inc %p from %pI4:%u to user\n", inc,
 			 &inc->i_conn->c_faddr,
 			 ntohs(inc->i_hdr.h_sport));
-		save = msg->msg_iter;
 		ret = inc->i_conn->c_trans->inc_copy_to_user(inc, &msg->msg_iter);
 		if (ret < 0)
 			break;
@@ -614,7 +612,7 @@ int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 			rds_inc_put(inc);
 			inc = NULL;
 			rds_stats_inc(s_recv_deliver_raced);
-			msg->msg_iter = save;
+			iov_iter_unroll(&msg->msg_iter, ret);
 			continue;
 		}
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a22be502f1bd..5bfd5d641ba2 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -316,6 +316,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		skb = tipc_buf_acquire(pktsz);
 		if (!skb) {
 			rc = -ENOMEM;
+			iov_iter_unroll(&m->msg_iter, dsz - drem);
 			goto error;
 		}
 		skb_orphan(skb);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 333c5dae0072..1fa220a2fa00 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -688,7 +688,6 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 	struct net *net = sock_net(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
 	struct sk_buff_head pktchain;
-	struct iov_iter save = msg->msg_iter;
 	uint mtu;
 	int rc;
 
@@ -725,7 +724,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 		}
 		__skb_queue_purge(&pktchain);
 		if (rc == -EMSGSIZE) {
-			msg->msg_iter = save;
+			iov_iter_unroll(&msg->msg_iter, dsz);
 			goto new_mtu;
 		}
 		break;
@@ -891,7 +890,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	bool is_connectionless = tipc_sk_type_connectionless(sk);
 	struct sk_buff *skb;
 	struct tipc_name_seq *seq;
-	struct iov_iter save;
+	int size;
 	u32 mtu;
 	long timeo;
 	int rc;
@@ -950,10 +949,9 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	}
 
 	skb_queue_head_init(&pktchain);
-	save = m->msg_iter;
 new_mtu:
 	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
-	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &pktchain);
+	size = rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &pktchain);
 	if (rc < 0)
 		return rc;
 
@@ -974,7 +972,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		}
 		__skb_queue_purge(&pktchain);
 		if (rc == -EMSGSIZE) {
-			m->msg_iter = save;
+			iov_iter_unroll(&m->msg_iter, size);
 			goto new_mtu;
 		}
 		break;
@@ -1049,7 +1047,7 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 	long timeo;
 	u32 dnode;
 	uint mtu, send, sent = 0;
-	struct iov_iter save;
+	int size;
 	int hlen = MIN_H_SIZE;
 
 	/* Handle implied connection establishment */
@@ -1078,10 +1076,9 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 	skb_queue_head_init(&pktchain);
 
 next:
-	save = m->msg_iter;
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
-	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &pktchain);
+	size = rc = tipc_msg_build(mhdr, m, sent, send, mtu, &pktchain);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -1099,7 +1096,7 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 				__skb_queue_purge(&pktchain);
 				tsk->max_pkt = tipc_node_get_mtu(net, dnode,
 								 portid);
-				m->msg_iter = save;
+				iov_iter_unroll(&m->msg_iter, size);
 				goto next;
 			}
 			if (rc != -ELINKCONG)
