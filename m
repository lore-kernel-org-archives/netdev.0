From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [SKBUFF] introduce skb_valid_link_header(skb, hdrlen)
Date: Mon, 04 Oct 2004 13:35:14 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41617BC2.7010004@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020704050702080000070909"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020704050702080000070909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Nowadays only the netfilter folks use such thing, in an
open coded way, but this seems useful for other cases, so I've
moved it to skbuff.h, abstracting another direct reference to
the skb "wannabe-private" headers.

	Now there are eleven outstanding changesets in this tree.

Best Regards,

- Arnaldo

--------------020704050702080000070909
Content-Type: text/plain;
 name="skb_valid_link_header.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skb_valid_link_header.patch"

===================================================================


ChangeSet@1.2040, 2004-10-04 13:21:41-03:00, acme@amd64.kerneljanitors.org
  [SKBUFF] introduce skb_valid_link_header(skb, hdrlen)
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/message/fusion/mptlan.c |    2 +-
 include/linux/skbuff.h          |    7 +++++++
 net/bridge/br_netfilter.c       |    2 +-
 net/ipv4/netfilter/ipt_mac.c    |    5 ++---
 net/ipv6/netfilter/ip6t_eui64.c |   10 ++++------
 net/ipv6/netfilter/ip6t_mac.c   |    5 ++---
 6 files changed, 17 insertions(+), 14 deletions(-)


diff -Nru a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
--- a/drivers/message/fusion/mptlan.c	2004-10-04 13:23:51 -03:00
+++ b/drivers/message/fusion/mptlan.c	2004-10-04 13:23:51 -03:00
@@ -770,7 +770,7 @@
 
 	pSendReq = (LANSendRequest_t *) mf;
 
-	/* Set the mac.raw pointer, since this apparently isn't getting
+	/* Set the link header pointer, since this apparently isn't getting
 	 * done before we get the skb. Pull the data pointer past the mac data.
 	 */
 	skb_set_link_header(skb);
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2004-10-04 13:23:51 -03:00
+++ b/include/linux/skbuff.h	2004-10-04 13:23:51 -03:00
@@ -295,6 +295,13 @@
 	skb->mac.raw = skb->data;
 }
 
+static inline int skb_valid_link_header(const struct sk_buff *skb,
+					const int hdrlen)
+{
+	return skb->mac.raw >= skb->head &&
+	       (skb->mac.raw + hdrlen) <= skb->data;
+}
+
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *alloc_skb(unsigned int size, int priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
diff -Nru a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c	2004-10-04 13:23:51 -03:00
+++ b/net/bridge/br_netfilter.c	2004-10-04 13:23:51 -03:00
@@ -759,7 +759,7 @@
 #ifdef CONFIG_NETFILTER_DEBUG
 	/* Be very paranoid. This probably won't happen anymore, but let's
 	 * keep the check just to be sure... */
-	if (skb->mac.raw < skb->head || skb->mac.raw + ETH_HLEN > skb->data) {
+	if (!skb_valid_link_header(skb, ETH_HLEN)) {
 		printk(KERN_CRIT "br_netfilter: Argh!! br_nf_post_routing: "
 				 "bad mac.raw pointer.");
 		goto print_error;
diff -Nru a/net/ipv4/netfilter/ipt_mac.c b/net/ipv4/netfilter/ipt_mac.c
--- a/net/ipv4/netfilter/ipt_mac.c	2004-10-04 13:23:51 -03:00
+++ b/net/ipv4/netfilter/ipt_mac.c	2004-10-04 13:23:51 -03:00
@@ -30,10 +30,9 @@
     const struct ipt_mac_info *info = matchinfo;
 
     /* Is mac pointer valid? */
-    return (skb->mac.raw >= skb->head
-	    && (skb->mac.raw + ETH_HLEN) <= skb->data
+    return (skb_valid_link_header(skb, ETH_HLEN) &&
 	    /* If so, compare... */
-	    && ((memcmp(eth_hdr(skb)->h_source, info->srcaddr, ETH_ALEN)
+	    ((memcmp(eth_hdr(skb)->h_source, info->srcaddr, ETH_ALEN)
 		== 0) ^ info->invert));
 }
 
diff -Nru a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
--- a/net/ipv6/netfilter/ip6t_eui64.c	2004-10-04 13:23:51 -03:00
+++ b/net/ipv6/netfilter/ip6t_eui64.c	2004-10-04 13:23:51 -03:00
@@ -32,12 +32,10 @@
     unsigned char eui64[8];
     int i=0;
 
-     if ( !(skb->mac.raw >= skb->head
-                && (skb->mac.raw + ETH_HLEN) <= skb->data)
-                && offset != 0) {
-                        *hotdrop = 1;
-                        return 0;
-                }
+    if (!skb_valid_link_header(skb, ETH_HLEN) && offset != 0) {
+        *hotdrop = 1;
+        return 0;
+    }
     
     memset(eui64, 0, sizeof(eui64));
 
diff -Nru a/net/ipv6/netfilter/ip6t_mac.c b/net/ipv6/netfilter/ip6t_mac.c
--- a/net/ipv6/netfilter/ip6t_mac.c	2004-10-04 13:23:51 -03:00
+++ b/net/ipv6/netfilter/ip6t_mac.c	2004-10-04 13:23:51 -03:00
@@ -32,10 +32,9 @@
     const struct ip6t_mac_info *info = matchinfo;
 
     /* Is mac pointer valid? */
-    return (skb->mac.raw >= skb->head
-	    && (skb->mac.raw + ETH_HLEN) <= skb->data
+    return (skb_valid_link_header(skb, ETH_HLEN) &&
 	    /* If so, compare... */
-	    && ((memcmp(eth_hdr(skb)->h_source, info->srcaddr, ETH_ALEN)
+	    ((memcmp(eth_hdr(skb)->h_source, info->srcaddr, ETH_ALEN)
 		== 0) ^ info->invert));
 }
 


--------------020704050702080000070909--
