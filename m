From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [Patch] sctp: add receive buffer accounting to sctp (fwd)
Date: Thu, 3 Mar 2005 00:32:12 +0530 (IST)
Message-ID: <Pine.LNX.4.61.0503030027590.8076@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nhorman@redhat.com, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please apply the following SCTP patch submitted by Neil.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Thanks
Sridhar

---------- Forwarded message ----------
Date: Tue, 1 Mar 2005 13:34:06 -0500
From: nhorman@redhat.com
To: lksctp-developers@lists.sourceforge.net
Cc: sri@us.ibm.com
Subject: [Patch] sctp: add receive buffer accounting to sctp

Patch to add recieve buffer accounting to sctp.  Current implmentation is open
to DOS attack, which can result in lowmem exhaustion, due to chunk backlog
queuing.  This patch adds receive buffer accounting which drops chunks in
sctp_rcv when sockets sk_rmem_alloc value exceeds sockets sk_rcvbuff value.

Signed-off-by: Neil Horman <nhorman@redhat.com

  input.c |   22 ++++++++++++++++++++++
  1 files changed, 22 insertions(+)


--- linux-2.6.9/net/sctp/input.c.rcvbuf	2005-02-23 14:19:18.065451507 -0500
+++ linux-2.6.9/net/sctp/input.c	2005-02-23 14:13:28.490573936 -0500
@@ -96,6 +96,21 @@ static inline int sctp_rcv_checksum(stru
  	return 0;
  }

+/* The free routine for skbuffs that sctp receives */
+static void sctp_rfree(struct sk_buff *skb)
+{
+	atomic_sub(sizeof(struct sctp_chunk),&skb->sk->sk_rmem_alloc);
+	sock_rfree(skb);
+}
+
+/* The ownership wrapper routine to do receive buffer accounting */
+static void sctp_rcv_set_owner_r(struct sk_buff *skb, struct sock *sk)
+{
+	skb_set_owner_r(skb,sk);
+	skb->destructor = sctp_rfree;
+	atomic_add(sizeof(struct sctp_chunk),&sk->sk_rmem_alloc);
+}
+
  /*
   * This is the routine which IP calls when receiving an SCTP packet.
   */
@@ -175,6 +190,11 @@ int sctp_rcv(struct sk_buff *skb)
  	rcvr = asoc ? &asoc->base : &ep->base;
  	sk = rcvr->sk;

+	if ((sk) && (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)) {
+		goto discard_release;
+	}
+
+
  	/* SCTP seems to always need a timestamp right now (FIXME) */
  	if (skb->stamp.tv_sec == 0) {
  		do_gettimeofday(&skb->stamp);
@@ -195,6 +215,8 @@ int sctp_rcv(struct sk_buff *skb)
  		goto discard_release;
  	}

+	sctp_rcv_set_owner_r(skb,sk);
+
  	/* Remember what endpoint is to handle this packet. */
  	chunk->rcvr = rcvr;

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/
