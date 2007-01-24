From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] problem with BPF in PF_PACKET sockets, introduced in
 linux-2.6.19
Date: Wed, 24 Jan 2007 15:21:33 -0800 (PST)
Message-ID: <20070124.152133.61337361.davem@davemloft.net>
References: <200701041747.46358.raivis@mt.lv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, waltje@uWalt.NL.Mugnet.ORG,
	gw4pts@gw4pts.ampr.org, dim@openvz.org, kuznet@ms2.inr.ac.ru
To: raivis@mt.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932879AbXAXXV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 18:21:59 -0500
In-Reply-To: <200701041747.46358.raivis@mt.lv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Raivis Bucis <raivis@mt.lv>
Date: Thu, 4 Jan 2007 17:47:46 +0200

> I believe I have found a bug in PF_PACKET socket filtering
> (introduced in linux-2.6.19). If BPF returns values larger than
> 0x80000000u, run_filter in af_packet.c considers that as error
> instead of simply accepting packet in its full length. sk_filter
> does not have this problem.

Indeed, this bug was introduced by this change:

commit fda9ef5d679b07c9d9097aaf6ef7f069d794a8f9
Author: Dmitry Mishin <dim@openvz.org>
Date:   Thu Aug 31 15:28:39 2006 -0700

    [NET]: Fix sk->sk_filter field access
    
    Function sk_filter() is called from tcp_v{4,6}_rcv() functions with arg
    needlock = 0, while socket is not locked at that moment. In order to avoid
    this and similar issues in the future, use rcu for sk->sk_filter field read
    protection.
    
    Signed-off-by: Dmitry Mishin <dim@openvz.org>
    Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
    Signed-off-by: Kirill Korotaev <dev@openvz.org>

The expected semantics are that sk_run_filter() returns either
"0" which means drop the packet, or a positive 32-bit integer
which states how many bytes of the packet to retain.  If the
returned length is larger than the packet, the packet is left
at it's full length, unchanged, and accepted.

That last case is what was broken by the logic modifications
done by Dmitry Mishin's RCU'ification of socket filters.  He
tries to combine 32-bit signed error code handling with
interpretation of the 32-bit unsigned return value from
sk_run_filter().

So this whole idea to make run_filter() return signed integers
and fail on negative is entirely flawed, it simply cannot work
and retain the expected semantics which have been there forever.

Drop on zero works, and was what the code did originally, and there
was no reason at all to modify the logic here, it was perfect.  The
callers to run_filter() told it what the expected return value should
be if there was no filter hooked up to the socket, and that is the
current length of the packet.  It simulates the case of there actually
being a filter and it saying that the whole packet should be accepted.

This is yet another case of someone doing some logic cleanups to make
the logic nicer to them, and adding a bug in the process.

Here is how I am likely to fix this:

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index da73e8a..594c078 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -428,24 +428,18 @@ out_unlock:
 }
 #endif
 
-static inline int run_filter(struct sk_buff *skb, struct sock *sk,
-							unsigned *snaplen)
+static inline unsigned int run_filter(struct sk_buff *skb, struct sock *sk,
+				      unsigned int res)
 {
 	struct sk_filter *filter;
-	int err = 0;
 
 	rcu_read_lock_bh();
 	filter = rcu_dereference(sk->sk_filter);
-	if (filter != NULL) {
-		err = sk_run_filter(skb, filter->insns, filter->len);
-		if (!err)
-			err = -EPERM;
-		else if (*snaplen > err)
-			*snaplen = err;
-	}
+	if (filter != NULL)
+		res = sk_run_filter(skb, filter->insns, filter->len);
 	rcu_read_unlock_bh();
 
-	return err;
+	return res;
 }
 
 /*
@@ -467,7 +461,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	struct packet_sock *po;
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
-	unsigned snaplen;
+	unsigned int snaplen, res;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -495,8 +489,11 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 
 	snaplen = skb->len;
 
-	if (run_filter(skb, sk, &snaplen) < 0)
+	res = run_filter(skb, sk, snaplen);
+	if (!res)
 		goto drop_n_restore;
+	if (snaplen > res)
+		snaplen = res;
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned)sk->sk_rcvbuf)
@@ -568,7 +565,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	struct tpacket_hdr *h;
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
-	unsigned snaplen;
+	unsigned int snaplen, res;
 	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
 	unsigned short macoff, netoff;
 	struct sk_buff *copy_skb = NULL;
@@ -592,8 +589,11 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 
 	snaplen = skb->len;
 
-	if (run_filter(skb, sk, &snaplen) < 0)
+	res = run_filter(skb, sk, snaplen);
+	if (!res)
 		goto drop_n_restore;
+	if (snaplen > res)
+		snaplen = res;
 
 	if (sk->sk_type == SOCK_DGRAM) {
 		macoff = netoff = TPACKET_ALIGN(TPACKET_HDRLEN) + 16;
