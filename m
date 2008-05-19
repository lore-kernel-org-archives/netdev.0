From: James Chapman <jchapman@katalix.com>
Subject: [PATCH] L2TP: avoid skb truesize bug if headroom is increased
Date: Mon, 19 May 2008 21:09:08 +0100
Message-ID: <200805192009.m4JK98DO003387@quickie.katalix.com>
Cc: bc-info@styx.cabel.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:35761 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764299AbYESUJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 16:09:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user reported seeing occasional bugs such as the following when
using the L2TP driver.

  SKB BUG: Invalid truesize (272) len=72, sizeof(sk_buff)=208

When L2TP adds its header in the transmit path, it might need to
increase the headroom of the skb. In some cases, the increased
headroom trips a kernel bug when the skb is freed because the skb has
grown beyond its truesize value. The fix is to increase the truesize
by the amount of headroom added, after orphaning the skb.

While here, fix a misleading comment.

Thanks to Iouri Kharon <bc-info@styx.cabel.net> for the initial
report and testing the fix.

Signed-off-by: James Chapman <jchapman@katalix.com>

 drivers/net/pppol2tp.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 7935991..8db342f 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -980,6 +980,8 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	__wsum csum = 0;
 	struct udphdr *uh;
 	unsigned int len;
+	int old_headroom;
+	int new_headroom;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
@@ -1001,16 +1003,18 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 
 	/* Check that there's enough headroom in the skb to insert IP,
 	 * UDP and L2TP and PPP headers. If not enough, expand it to
-	 * make room. Note that a new skb (or a clone) is
-	 * allocated. If we return an error from this point on, make
-	 * sure we free the new skb but do not free the original skb
-	 * since that is done by the caller for the error case.
+	 * make room. Adjust truesize.
 	 */
 	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
 		sizeof(struct udphdr) + hdr_len + sizeof(ppph);
+	old_headroom = skb_headroom(skb);
 	if (skb_cow_head(skb, headroom))
 		goto abort;
 
+	new_headroom = skb_headroom(skb);
+	skb_orphan(skb);
+	skb->truesize += new_headroom - old_headroom;
+
 	/* Setup PPP header */
 	__skb_push(skb, sizeof(ppph));
 	skb->data[0] = ppph[0];
@@ -1065,7 +1069,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	/* Get routing info from the tunnel socket */
 	dst_release(skb->dst);
 	skb->dst = dst_clone(__sk_dst_get(sk_tun));
-	skb_orphan(skb);
 	skb->sk = sk_tun;
 
 	/* Queue the packet to IP for output */
