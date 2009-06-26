From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
 traffic
Date: Fri, 26 Jun 2009 13:02:24 -0700 (PDT)
Message-ID: <20090626.130224.232645797.davem@davemloft.net>
References: <bug-13627-10286@http.bugzilla.kernel.org/>
	<20090626124444.c24d9b38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	olver@hartkopp.net, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbZFZUCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:02:19 -0400
In-Reply-To: <20090626124444.c24d9b38.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 26 Jun 2009 12:44:44 -0700

> It's a post-2.6.30 regression which Paul has bisected down to
> 
>   commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>   Author:     Herbert Xu <herbert@gondor.apana.org.au>
>   AuthorDate: Mon Jun 22 02:25:25 2009 +0000
>   Commit:     David S. Miller <davem@davemloft.net>
>   CommitDate: Tue Jun 23 16:36:25 2009 -0700
> 
>       net: Move rx skb_orphan call to where needed
> 
> (thanks for doing the bisection!)

Then it's good that we partially reverted that change just
the other day :-)

commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jun 22 02:25:25 2009 +0000

    net: Move rx skb_orphan call to where needed
    
    In order to get the tun driver to account packets, we need to be
    able to receive packets with destructors set.  To be on the safe
    side, I added an skb_orphan call for all protocols by default since
    some of them (IP in particular) cannot handle receiving packets
    destructors properly.
    
    Now it seems that at least one protocol (CAN) expects to be able
    to pass skb->sk through the rx path without getting clobbered.
    
    So this patch attempts to fix this properly by moving the skb_orphan
    call to where it's actually needed.  In particular, I've added it
    to skb_set_owner_[rw] which is what most users of skb->destructor
    call.
    
    This is actually an improvement for tun too since it means that
    we only give back the amount charged to the socket when the skb
    is passed to another socket that will also be charged accordingly.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Tested-by: Oliver Hartkopp <olver@hartkopp.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 9f80a76..d16a304 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -448,6 +448,7 @@ static inline void sctp_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
 	struct sctp_ulpevent *event = sctp_skb2event(skb);
 
+	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sctp_sock_rfree;
 	atomic_add(event->rmem_len, &sk->sk_rmem_alloc);
diff --git a/include/net/sock.h b/include/net/sock.h
index 570c7a1..7f5c41c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1250,6 +1250,7 @@ static inline int sk_has_allocations(const struct sock *sk)
 
 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
+	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
 	/*
@@ -1262,6 +1263,7 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 
 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
+	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_rfree;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 5f1d210..de56d39 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -437,8 +437,7 @@ free:
 int ax25_kiss_rcv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
-	skb->sk = NULL;		/* Initially we don't know who it's for */
-	skb->destructor = NULL;	/* Who initializes this, dammit?! */
+	skb_orphan(skb);
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index baf2dc1..60b5728 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2310,8 +2310,6 @@ ncls:
 	if (!skb)
 		goto out;
 
-	skb_orphan(skb);
-
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 5922feb..cb762c8 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -913,9 +913,6 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	/* Clean up the original one to keep it in listen state */
 	irttp_listen(self->tsap);
 
-	/* Wow ! What is that ? Jean II */
-	skb->sk = NULL;
-	skb->destructor = NULL;
 	kfree_skb(skb);
 	sk->sk_ack_backlog--;
 
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 67c99d2..7ba9661 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -196,6 +196,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 	/* Don't forget to refcount it - see ircomm_tty_do_softint() */
 	skb_get(skb);
 
+	skb_orphan(skb);
 	skb->destructor = ircomm_lmp_flow_control;
 
 	if ((self->pkt_count++ > 7) && (self->flow_status == FLOW_START)) {
