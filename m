From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] syncppp needs to pullup headers
Date: Fri, 3 Oct 2003 11:43:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003114347.31ee740b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In 2.6.0-test6 wan syncppp driver claims to be a "new" protocol and handle shared skb's
but it needs to make sure data is contiguous before overlaying headers.  
It is not a serious problem because the sync drivers never generate nonlinear skbuff's
anyway.

Don't have hardware that uses this, so could someone please do a sanity 
test on this.

diff -Nru a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
--- a/drivers/net/wan/syncppp.c	Fri Oct  3 11:28:11 2003
+++ b/drivers/net/wan/syncppp.c	Fri Oct  3 11:28:11 2003
@@ -236,7 +236,7 @@
 		sp->ipkts++;
 	}
 
-	if (skb->len <= PPP_HEADER_LEN) {
+	if (!pskb_may_pull(skb, PPP_HEADER_LEN)) {
 		/* Too small packet, drop it. */
 		if (sp->pp_flags & PP_DEBUG)
 			printk (KERN_DEBUG "%s: input packet is too small, %d bytes\n",
@@ -473,7 +473,7 @@
 	u8 *p, opt[6];
 	u32 rmagic;
 
-	if (len < 4) {
+	if (!pskb_may_pull(skb, sizeof(struct lcp_header))) {
 		if (sp->pp_flags & PP_DEBUG)
 			printk (KERN_WARNING "%s: invalid lcp packet length: %d bytes\n",
 				dev->name, len);
@@ -707,7 +707,9 @@
 	struct cisco_packet *h;
 	struct net_device *dev = sp->pp_if;
 
-	if (skb->len != CISCO_PACKET_LEN && skb->len != CISCO_BIG_PACKET_LEN) {
+	if (!pskb_may_pull(skb, sizeof(struct cisco_packet))
+	    || (skb->len != CISCO_PACKET_LEN
+		&& skb->len != CISCO_BIG_PACKET_LEN)) {
 		if (sp->pp_flags & PP_DEBUG)
 			printk (KERN_WARNING "%s: invalid cisco packet length: %d bytes\n",
 				dev->name,  skb->len);
@@ -1211,8 +1213,7 @@
 	struct net_device *dev = sp->pp_if;
 	int len = skb->len;
 
-	if (len < 4) 
-	{
+	if (!pskb_may_pull(skb, sizeof(struct lcp_header))) {
 		if (sp->pp_flags & PP_DEBUG)
 			printk (KERN_WARNING "%s: invalid ipcp packet length: %d bytes\n",
 				dev->name,  len);
