From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce skb_link_header_size(skb)
Date: Tue, 05 Oct 2004 16:14:19 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162F28B.2050308@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030105000501030001090605"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030105000501030001090605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there ate 13 outstanding changesets in this tree.

Regards,

- Arnaldo

--------------030105000501030001090605
Content-Type: text/plain;
 name="skb_link_header_size.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skb_link_header_size.patch"

===================================================================


ChangeSet@1.2042, 2004-10-05 16:11:14-03:00, acme@conectiva.com.br
  [SKBUFF] introduce skb_link_header_size(skb)
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/net/arcnet/arcnet.c |    8 ++++----
 include/linux/skbuff.h      |    5 +++++
 net/core/dev.c              |    2 +-
 net/ipv4/ip_gre.c           |    3 ++-
 4 files changed, 12 insertions(+), 6 deletions(-)


diff -Nru a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c	2004-10-05 16:11:56 -03:00
+++ b/drivers/net/arcnet/arcnet.c	2004-10-05 16:11:56 -03:00
@@ -478,9 +478,9 @@
 	 */
 	if (!daddr) {
 		*(uint16_t *) skb_push(skb, 2) = type;
-		if (skb->nh.raw - skb->mac.raw != 2)
+		if (skb_link_header_size(skb) != 2)
 			BUGMSG(D_NORMAL, "arcnet_header: Yikes!  diff (%d) is not 2!\n",
-			       (int)(skb->nh.raw - skb->mac.raw));
+			       skb_link_header_size(skb));
 		return -2;	/* return error -- can't transmit yet! */
 	}
 	/* otherwise, we can just add the header as usual. */
@@ -512,10 +512,10 @@
 	uint8_t daddr=0;
 	struct ArcProto *proto;
 
-	if (skb->nh.raw - skb->mac.raw != 2) {
+	if (skb_link_header_size(skb) != 2) {
 		BUGMSG(D_NORMAL,
 		     "rebuild_header: shouldn't be here! (hdrsize=%d)\n",
-		     (int)(skb->nh.raw - skb->mac.raw));
+		     skb_link_header_size(skb));
 		return 0;
 	}
 	type = *(uint16_t *) skb_pull(skb, 2);
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2004-10-05 16:11:56 -03:00
+++ b/include/linux/skbuff.h	2004-10-05 16:11:56 -03:00
@@ -302,6 +302,11 @@
 	       (skb->mac.raw + hdrlen) <= skb->data;
 }
 
+static inline int skb_link_header_size(const struct sk_buff *skb)
+{
+	return skb->nh.raw - skb->mac.raw;
+}
+
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *alloc_skb(unsigned int size, int priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-10-05 16:11:56 -03:00
+++ b/net/core/dev.c	2004-10-05 16:11:56 -03:00
@@ -1735,7 +1735,7 @@
 	__get_cpu_var(netdev_rx_stat).total++;
 
 	skb->h.raw = skb->nh.raw = skb->data;
-	skb->mac_len = skb->nh.raw - skb->mac.raw;
+	skb->mac_len = skb_link_header_size(skb);
 
 	pt_prev = NULL;
 
diff -Nru a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
--- a/net/ipv4/ip_gre.c	2004-10-05 16:11:56 -03:00
+++ b/net/ipv4/ip_gre.c	2004-10-05 16:11:56 -03:00
@@ -621,7 +621,8 @@
 		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 		if (skb->ip_summed == CHECKSUM_HW)
 			skb->csum = csum_sub(skb->csum,
-					     csum_partial(skb->mac.raw, skb->nh.raw-skb->mac.raw, 0));
+					     csum_partial(skb->mac.raw,
+						     	  skb_link_header_size(skb), 0));
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (MULTICAST(iph->daddr)) {


--------------030105000501030001090605--
