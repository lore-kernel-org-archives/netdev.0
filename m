From: Diego Beltrami <diego.beltrami@HIIT.FI>
Subject: Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Tue, 02 Aug 2005 15:01:39 +0300
Message-ID: <1122984099.1214.142.camel__12361.1664552756$1122992734$gmane$org@odysse>
Reply-To: diego.beltrami@HIIT.FI
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-cxEtPhsKh15+QDSHjSKR"
Cc: netdev@oss.sgi.com, infrahip@HIIT.FI, hipl-users@freelists.org,
        hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-cxEtPhsKh15+QDSHjSKR
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Folks,

after sending the first version of BEET patch and having received a
valuable feedback and after the discussion based upon the BEET design,
we now send the new BEET patch which allows for BEET to work without the
inter-family transform (i.e. inner address family different than outer
address family).

The implementation of such a patch is based on the draft you can find at
the following URL:

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt

The patch is attached to the email, but, in case it gives some problems
in applying it, you may also find it at the following URL:

http://infrahip.hiit.fi/beet/beet-patch-v2.0-2.6.12.2

As it was originally designed the BEET patch at the moment works for
only ESP protocol. 
As Pekka Nikader mentioned in one reply [1]: "[...] defining BEET mode
for AH might be pretty tricky. [...] it probably would require some
careful thinking to define the exact semantics, like what addresses
(inner or outer)  are covered by the AH integrity protection, what does
the integrity  protection really assert, etc. ".

As previously written, the inter-family transform has been left out at
the moment since the xfrm architecture doesn't support it. As a result,
as soon as the xfrm architecture will be enhanced, the inter-family case
will be properly included as, for example, it can be useful for
supporting HIP over IPv4 network. But, as already mentioned, this would
require more work in properly designing the xfrm architecture (thing
which we consider necessary in order to make xfrm as generic as
possible).


On the behalf of the BEET development team,

Signed-off-by: Diego Beltrami <diego.beltrami@hiit.fi>


Reference:
[1] http://marc.theaimsgroup.com/?l=linux-netdev&m=112265207304302&w=2

--=-cxEtPhsKh15+QDSHjSKR
Content-Disposition: attachment; filename=beet-patch-v2.0-2.6.12.2
Content-Type: text/plain; name=beet-patch-v2.0-2.6.12.2; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

--- linux-2.6.12.2-orig/Documentation/README.BEET
+++ linux-2.6.12.2/Documentation/README.BEET
@@ -0,0 +1,296 @@
+Linux BEET-mode ESP patch
+
+Authors:        Miika Komu <miika@iki.fi>
+                Kristian Slavov <kristian.slavov@nomadiclab.com>
+                Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+		Abhinav Pathak <abpathak@iitk.ac.in>
+		Diego Beltrami <diego.beltrami@hiit.fi>
+
+Changelog:      May 25, 2005 this document created
+
+
+Description
+-----------
+This patch extends the native Linux 2.6 kernel IPsec to support 
+Bound-End-to-End-Tunnel (BEET) mode for ESP:
+
+Abstract
+
+   This document specifies a new mode, called Bound End-to-End Tunnel
+   (BEET) mode, for IPsec ESP.  The new mode augments the existing ESP
+   tunnel and transport modes.  For end-to-end tunnels, the new mode
+   provides limited tunnel mode semantics without the regular tunnel
+   mode overhead.  The mode is intended to support new uses of ESP,
+   including mobility and multi-address multi-homing.
+
+http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt
+
+BEET mode architecture
+----------------------
+
+Below are some control flow diagrams to illustrate how BEET works.
+
+Sending (inner IPv4, outer IPv4)(4-4)
+=====================================
+inet_sendmsg
+  raw_sendmsg 
+    ip_route_output_flow
+      __ip_route_output_key
+    xfrm_lookup
+      flow_cache_lookup
+        xfrm_policy_lookup // lookup IPsec policy 
+      xfrm_find_bundle   // lookup IPsec SA
+        __xfrm_selector_match
+      xfrm_tmpl_resolve  // only if bundle was not found!
+        xfrm_state_find
+      xfrm_bundle_create // create output (dst) chain if bundle was not found
+        __xfrm4_bundle_create
+  ip_push_pending_frames
+    dst_output(skb)	//this calls skb->dst->output();	
+     xfrm4_output	//This finally returns 4 (NET_XMIT_BYPASS) to dst_output();
+       xfrm4_encap
+       esp_output
+       xfrm_beet_output	//change the ip header to outer.
+    dst_output(skb)
+     ip_output
+       ip_finish_output	Or ip_fragment 	//depending on size of packet
+          // Returns 0 to dst_output(); which makes dst_output to come out of infinite loop.
+  dev_queue_xmit
+
+
+Receiving (inner IPv4, outer IPv4)(4-4)
+===========
+
+net_rx_action()
+e1000_clean()           // dependent on network hardware
+e1000_clean_rx_irq()
+netif_receive_skb()
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ip_rcv() 
+      nf_hook()
+      ip_rcv_finish()
+        ip_route_input()
+        dst_input()->ip_forward() or ip_input()
+    ip_input // remove the IPv4 header
+      ip_input_finish 
+        ret = ipprot->handler(&skb, &nhoff); 
+          xfrm4_rcv()
+            xfrm4_rcv_encap() 
+              xfrm4_parse_spi()
+              xfrm_state_lookup() // lookup IPsec SA  
+	      xfrm_beet_input(skb, x) //To change to inner IP header.
+              nexthdr = x->type->input(x, xfrm.decap, skb) // == esp_input
+                esp_input()          // process ESP based on inner address
+                  returns 0 ;
+              /* beet handling in xfrm_rcv_spi */
+              netif_rx()
+      // ip_input_finish returns 0
+  // netif_receive_skb returns 0
+netif_receive_skb	//Now we have an IPv4 packet. So the input flow is for v4 packet.
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ip_rcv()
+      nf_hook()	//This calls ip_rcv_finish(skb)
+      ip_rcv_finish()	//Here the skb->dst is NULL and so is filled for the input side.
+        ip6_route_input()
+        dst_input()->ip_forward() or ip_input()
+    ip_input // remove the IPv4 header
+      ip_input_finish
+	...
+	 ...
+          ...  
+
+Sending (inner IPv6, outer IPv6)(6-6)
+=============
+
+(When sending the first packet!)
+
+inet_sendmsg
+  rawv6_sendmsg
+    ip6_dst_lookup
+      ip6_route_output
+    xfrm_lookup
+      flow_cache_lookup
+        xfrm_policy_lookup // lookup IPsec policy 
+      xfrm_find_bundle   // lookup IPsec SA
+        __xfrm_selector_match
+      xfrm_tmpl_resolve  // only if bundle was not found!
+        xfrm_state_find
+      xfrm_bundle_create // create output (dst) chain if bundle was not found
+        __xfrm6_bundle_create
+  rawv6_push_pending_frames
+    ip6_push_pending_frames
+      dst_output(skb)
+      	xfrm6_output
+           xfrm6_encap
+           esp6_output
+	   xfrm_beet_output
+      dst_output(skb)
+        ip6_output
+           ip6_output2
+              ip6_output_finish
+    dev_queue_xmit
+
+when are these called?
+    ip6_xmt()
+    dst_output()
+
+
+Receiving (inner IPv6, outer IPv6)(6-6)
+===========
+
+net_rx_action()
+e1000_clean()           // dependent on network hardware
+e1000_clean_rx_irq()
+netif_receive_skb()
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ipv6_rcv() // skb len = 140
+      nf_hook_slow()
+      ip6_rcv_finish()
+        ip6_route_input()
+        dst_input()->ip6_forward() or ip6_input()
+    ip6_input // remove the IPv6 header
+      ip6_input_finish // calls recursively the ->handler = xfrm6_rcv
+        ret = ipprot->handler(&skb, &nhoff); // handler = xfrm6_rcv_spi
+          xfrm6_rcv()
+            xfrm6_rcv_spi() 
+              xfrm_parse_spi()
+              xfrm_state_lookup() // lookup IPsec SA  
+	      xfrm_beet_input(skb, x) //To change to inner IP header.
+              nexthdr = x->type->input(x, xfrm.decap, skb) // == esp6_input
+                esp6_input()          // process ESP
+                  returns 58 (ICMPv6)	//returns the nexthdr in the ipv6 packet.
+              /* beet handling in xfrm_rcv_spi */
+              netif_rx()
+      // ip6_input_finish returns 0
+  // netif_receive_skb returns 0
+netif_receive_skb
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ipv6_rcv() // skb len = 104
+      nf_hook_slow()
+      ip6_rcv_finish()
+        ip6_route_input()
+        dst_input()->ip6_forward() or ip6_input()
+    ip6_input // remove the IPv6 header
+      ip6_input_finish
+        xfrm6_policy_check()
+          ..
+            __xfrm_policy_check
+        ret = ipprot->handler(&skb, &nhoff); // handler = xfrm6_rcv_spi
+tcp_v6_rcv()            // or icmpv6_rcv(), anyway, deliver to upper layer
+
+<this is Kristian's text from ARCHITECTURE, fold into above>
+output path
+ip6_datagram_connect()
+  ip6_dst_lookup() // success
+  xfrm_lookup()  // lookup policy using inner IP, matching selectors in SP and
+                    flow information 
+    xfrm_sk_policy_lookup() // success
+    flow_cache_lookup()     // success
+    xfrm_find_bundle() // check for a bundle, if found use it, or create new
+    xfrm_tmpl_resolve() // when creating new, search for SA for each transform
+                        // once valid SA found, use it to create bundle and link
+                        // to SP. modify skbuff's dst-pointer pointing to next
+                        // xfrmX_output(), after encaps/trans dst is consulted
+                        // to route the packet
+      xfrm_state_find() // 
+        xfrm_selector_match() //
+        km_query() //
+
+
+<insert some diagram here describing everything>
+          app                                           app
+           |                                             |
+          inner                                        inner
+            \                                          /
+             -<xfrm_proc>			      /	
+		     \				     /
+		      \--outer               outer--/
+			     \              /  
+			      \===<wire>===/
+
+
+Files changed
+-------------
+This is a list of changes made by the BEET patch.
+
+include/linux/ipsec.h
+ - IPSEC_MODE_BEET added
+   This is the new type of SA that may be created.
+   XXX note: are we overusing XFRM_MODE_BEET where IPSEC_MODE_BEET should be
+             used instead?
+
+include/linux/xfrm.h
+ - enum XFRM_MODE_{TRANSPORT|TUNNEL|BEET} added
+   Mode needed to distinguish from tunnel mode in xfrm code.
+
+include/net/xfrm.h
+ - u16 beet_family added to struct xfrm_state
+   For the outgoing SA, this is the family of the outer address.
+   For the incoming SA, this is the family of the inner address.
+ - unsigned short family added to struct xfrm_tmpl
+   family is required because the family may differ from the one in the selector
+ - possible change to xfrm_selector_match() (commented out)
+
+net/ipv4/xfrm4_input.c
+ - in xfrm4_rcv_encap() change the 
+   ip header to inner before going for esp test.
+ - in xfrm4_rcv_encap() check x->props.mode for XFRM_MODE_TUNNEL, _BEET
+   checks address family (x->props.beet_family), and makes final adjustments 
+   to packet before requeing it.
+
+net/ipv4/xfrm4_output.c 
+ - xfrm4_encap(), note to fix the BEET case, like xfrm6_encap
+ - xfrm4_output() changes the ip header
+
+net/ipv4/esp4.c 
+ - in esp_init_state(), check if x->props.mode == XFRM_MODE_TUNNEL,
+   then x->props.header_len += sizeof(struct ipv6hdr), not if (x->props.mode)
+
+net/ipv6/esp6.c 
+ - in esp6_init_state(), check if x->props.mode == XFRM_MODE_TUNNEL,
+   then x->props.header_len += sizeof(struct ipv6hdr), not if (x->props.mode)
+
+net/ipv6/xfrm6_input.c
+ - xfrm6-rcv_spi(), changes the 
+   inner ip header before sending to esp decapsulation.
+ - in xfrm6_rcv_spi(), handle x->props.mode = XFRM_MODE_BEET
+   checks address family (x->props.beet_family), makes final adjustments to
+   packet before requeing it.
+
+net/ipv6/xfrm6_output.c 
+ - xfrm6_encap() add ipv4 header vars, check if (x->props.mode==XFRM_MODE_BEET)
+   makes space for appropriate esp header and sends to espX_output where X depends
+   on inner family of beet.
+ - xfrm6_output() change if(x->props.mode) to (x->props.mode==XFRM_MODE_TUNNEL)
+   After esp calculations the ip header is changed
+   to outer ip header.
+
+net/ipv6/xfrm6_policy.c
+ (on output...)
+ - in __xfrm6_bundle_create() added remotebeet, localbeet vars,
+   get the IPv6 headers from xfrm[i]->id.daddr (remote) and
+   xfrm[i]->props.saddr (local)
+   copy IPv4 or IPv6 addresses from remote/localbeet to fl_tunnel.fl4/6_dst/src
+   then do xfrm_dst_lookup() passing in xfrm[i]->props.beet_family
+
+net/key/af_key.c
+ - commented-out code in pfkey_msg2xfrm_state():
+   check x->props.beet_family for x->props.family?
+
+ - parse_ipsecrequest() check if (t->mode==IPSEC_MODE_TUNNEL-1)
+   handle if (t->mode==IPSEC_MODE_BEET-1)
+   populate t->saddr.a4 or t->saddr.a6, t->family, etc
+   This supports adding a new type of beet mode SA.
+
+net/xfrm/Kconfig
+ - added XFRM_BEET config variable option and text
+   This allows you to compile BEET mode into your kernel.
+
+net/xfrm/xfrm_policy.c
+ - note from Miika - fns added just for testing, removed for BEET
+   ipv6_addr_is_hit(), hip_xfrm_handler_notify(), hip_xfrm_handler_acquire(),
+   hip_xfrm_handler_policy_notify(), hip_register_xfrm_km_handler(), etc
--- linux-2.6.12.2-orig/include/linux/ipsec.h
+++ linux-2.6.12.2/include/linux/ipsec.h
@@ -13,6 +13,9 @@
 	IPSEC_MODE_ANY		= 0,	/* We do not support this for SA */
 	IPSEC_MODE_TRANSPORT	= 1,
 	IPSEC_MODE_TUNNEL	= 2
+#ifdef CONFIG_XFRM_BEET
+	,IPSEC_MODE_BEET         = 3
+#endif
 };
 
 enum {
--- linux-2.6.12.2-orig/include/linux/xfrm.h
+++ linux-2.6.12.2/include/linux/xfrm.h
@@ -102,6 +102,15 @@
 	XFRM_SHARE_UNIQUE	/* Use once */
 };
 
+enum
+{
+	XFRM_MODE_TRANSPORT = 0,
+	XFRM_MODE_TUNNEL
+#ifdef CONFIG_XFRM_BEET
+	,XFRM_MODE_BEET
+#endif
+};
+
 /* Netlink configuration messages.  */
 enum {
 	XFRM_MSG_BASE = 0x10,
--- linux-2.6.12.2-orig/include/net/xfrm.h
+++ linux-2.6.12.2/include/net/xfrm.h
@@ -113,6 +113,14 @@
 		xfrm_address_t	saddr;
 		int		header_len;
 		int		trailer_len;
+#ifdef CONFIG_XFRM_BEET
+		/* beet_family_out = family of outer addresses
+		 * beet_family_in  = family of inner addresses
+		 */
+		u16		beet_family_in;
+		u16		beet_family_out;
+		
+#endif
 	} props;
 
 	struct xfrm_lifetime_cfg lft;
@@ -241,6 +249,12 @@
 /* Source address of tunnel. Ignored, if it is not a tunnel. */
 	xfrm_address_t		saddr;
 
+/* family of the addresses. In BEET-mode the family may differ from
+   the one in selector */
+#ifdef CONFIG_XFRM_BEET
+	unsigned short		family;
+#endif
+
 	__u32			reqid;
 
 /* Mode: transport/tunnel */
@@ -835,6 +849,12 @@
 extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
 extern u32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
 extern int xfrm6_output(struct sk_buff *skb);
+#ifdef CONFIG_XFRM_BEET
+extern struct xfrm_state * xfrm_lookup_bydst(u8 mode, xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family);
+extern int xfrm_beet_output(struct sk_buff *skb);
+extern int xfrm_beet_input(struct sk_buff *skb, struct xfrm_state *x);
+
+#endif
 
 #ifdef CONFIG_XFRM
 extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
--- linux-2.6.12.2-orig/net/ipv4/esp4.c
+++ linux-2.6.12.2/net/ipv4/esp4.c
@@ -1,3 +1,13 @@
+/*
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
+ */
+
 #include <linux/config.h>
 #include <linux/module.h>
 #include <net/ip.h>
@@ -23,7 +33,7 @@
 	struct iphdr *top_iph;
 	struct ip_esp_hdr *esph;
 	struct crypto_tfm *tfm;
-	struct esp_data *esp;
+	struct esp_data *esp = x->data;
 	struct sk_buff *trailer;
 	int blksize;
 	int clen;
@@ -31,7 +41,15 @@
 	int nfrags;
 
 	/* Strip IP+ESP header. */
-	__skb_pull(skb, skb->h.raw - skb->data);
+#ifdef CONFIG_XFRM_BEET
+	int hdr_len = skb->h.raw - skb->data + sizeof(*esph) + esp->conf.ivlen;
+	if (x->props.mode == XFRM_MODE_BEET)
+		__skb_pull(skb, hdr_len);
+	else
+		__skb_pull(skb, skb->h.raw - skb->data);
+#else
+        __skb_pull(skb, skb->h.raw - skb->data);
+#endif
 	/* Now skb is pure payload to encrypt */
 
 	err = -ENOMEM;
@@ -39,7 +57,6 @@
 	/* Round to block size */
 	clen = skb->len;
 
-	esp = x->data;
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
 	blksize = (crypto_tfm_alg_blocksize(tfm) + 3) & ~3;
@@ -59,7 +76,14 @@
 	*(u8*)(trailer->tail + clen-skb->len - 2) = (clen - skb->len)-2;
 	pskb_put(skb, trailer, clen - skb->len);
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_BEET)
+		__skb_push(skb, hdr_len);
+	else
+		__skb_push(skb, skb->data - skb->nh.raw);
+#else
 	__skb_push(skb, skb->data - skb->nh.raw);
+#endif
 	top_iph = skb->nh.iph;
 	esph = (struct ip_esp_hdr *)(skb->nh.raw + top_iph->ihl*4);
 	top_iph->tot_len = htons(skb->len + alen);
@@ -428,7 +452,11 @@
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+#else
 	if (x->props.mode)
+#endif
 		x->props.header_len += sizeof(struct iphdr);
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
--- linux-2.6.12.2-orig/net/ipv4/xfrm4_input.c
+++ linux-2.6.12.2/net/ipv4/xfrm4_input.c
@@ -7,6 +7,13 @@
  *	Derek Atkins <derek@ihtfp.com>
  *		Add Encapsulation support
  * 	
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <linux/module.h>
@@ -78,6 +85,25 @@
 			goto drop_unlock;
 
 		xfrm_vec[xfrm_nr].decap.decap_type = encap_type;
+
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_BEET) {
+			/* Change the outer header with the inner data */
+			if (x->props.beet_family_in == AF_INET && x->props.beet_family_out == AF_INET){
+				/* Inner = 4, Outer = 4 */
+				struct iphdr *iph = (struct iphdr *)skb->nh.iph;
+				iph->daddr = x->sel.daddr.a4;
+				iph->saddr = x->sel.saddr.a4;
+				iph->ttl--;
+				iph->tot_len = htons(skb->len);
+				iph->frag_off = htons(IP_DF);
+				iph->check = 0;
+				iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+				
+			} else
+				BUG_ON(1);
+		}
+#endif
 		if (x->type->input(x, &(xfrm_vec[xfrm_nr].decap), skb))
 			goto drop_unlock;
 
@@ -96,7 +122,11 @@
 
 		iph = skb->nh.iph;
 
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
+#else
 		if (x->props.mode) {
+#endif
 			if (iph->protocol != IPPROTO_IPIP)
 				goto drop;
 			if (!pskb_may_pull(skb, sizeof(struct iphdr)))
@@ -115,9 +145,35 @@
 			decaps = 1;
 			break;
 		}
+#ifdef CONFIG_XFRM_BEET
+		else if (x->props.mode == XFRM_MODE_BEET) {
+			struct iphdr *iph = skb->nh.iph;
+			int size = sizeof(struct iphdr);
+
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto drop;
 
-		if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi, &seq)) < 0)
+			skb_push(skb, size);
+
+			memmove(skb->data, skb->nh.raw, size);
+			skb->mac.raw = memmove(skb->data - skb->mac_len,
+					       skb->mac.raw, skb->mac_len);
+			skb->nh.raw = skb->data;
+			iph->tot_len = htons(skb->len);
+			iph->check = 0;
+			iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+			skb->protocol = htons(ETH_P_IP);
+			dst_release(skb->dst);
+			skb->dst = NULL;
+			decaps = 1;
+			
+			break;
+		}
+#endif
+	        if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi, &seq)) < 0)
 			goto drop;
+
 	} while (!err);
 
 	/* Allocate new secpath or COW existing one. */
--- linux-2.6.12.2-orig/net/ipv4/xfrm4_output.c
+++ linux-2.6.12.2/net/ipv4/xfrm4_output.c
@@ -6,6 +6,14 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version
  * 2 of the License, or (at your option) any later version.
+ *
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <linux/skbuff.h>
@@ -26,7 +34,8 @@
  *	check
  *
  * On exit, skb->h will be set to the start of the payload to be processed
- * by x->type->output and skb->nh will be set to the top IP header.
+ * by x->type->output and skb->nh, as well as skb->data, will point to 
+ * the top IP header.
  */
 static void xfrm4_encap(struct sk_buff *skb)
 {
@@ -35,15 +44,36 @@
 	struct iphdr *iph, *top_iph;
 
 	iph = skb->nh.iph;
-	skb->h.ipiph = iph;
+#ifdef CONFIG_XFRM_BEET
+        /*
+         * This is because otherwise the BEET patch crashes in any case with Inner=4
+         */
+        if (x->props.mode != XFRM_MODE_BEET)
+                skb->h.ipiph = iph;
+#else
+        skb->h.ipiph = iph;
+#endif
 
 	skb->nh.raw = skb_push(skb, x->props.header_len);
 	top_iph = skb->nh.iph;
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_TRANSPORT) {
+#else
 	if (!x->props.mode) {
+#endif
+
 		skb->h.raw += iph->ihl*4;
 		memmove(top_iph, iph, iph->ihl*4);
 		return;
+#ifdef CONFIG_XFRM_BEET
+	} else if (x->props.mode == XFRM_MODE_BEET) {
+
+		skb->h.raw = skb->data + sizeof(struct iphdr);
+		memmove(top_iph, iph, iph->ihl*4);
+		return;
+
+#endif /* CONFIG_XFRM_BEET */
 	}
 
 	top_iph->ihl = 5;
@@ -103,7 +133,11 @@
 			goto error_nolock;
 	}
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
+#else
 	if (x->props.mode) {
+#endif
 		err = xfrm4_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
@@ -120,6 +154,21 @@
 	if (err)
 		goto error;
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_BEET) {
+		/* Change the outer header */
+		if (x->props.beet_family_in == AF_INET && x->props.beet_family_out == AF_INET){
+			struct iphdr *iph = (struct iphdr*)skb->data;
+			iph->saddr = x->props.saddr.a4;
+			iph->daddr = x->id.daddr.a4;
+			skb->local_df = 1;	//I am a bit unsure on how to implement this -Abi
+			iph->check = 0;
+			iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+		} else
+			BUG_ON(1);
+	}
+#endif
+
 	x->curlft.bytes += skb->len;
 	x->curlft.packets++;

--- linux-2.6.12.2-orig/net/ipv4/xfrm4_policy.c	2005-06-30 02:00:53.000000000 +0300
+++ linux-2.6.12.2/net/ipv4/xfrm4_policy.c	2005-08-01 15:05:26.000000000 +0300
@@ -6,6 +6,14 @@
  * 	YOSHIFUJI Hideaki @USAGI
  *		Split up af-specific portion
  * 	
+ *
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <asm/bug.h>
@@ -66,6 +74,12 @@
 			}
 		}
 	};
+#ifdef CONFIG_XFRM_BEET
+	union {
+		struct in6_addr *in6;
+		struct in_addr *in;
+	} remotebeet, localbeet;
+#endif
 	int i;
 	int err;
 	int header_len = 0;
@@ -78,6 +92,9 @@
 		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
 		struct xfrm_dst *xdst;
 		int tunnel = 0;
+#ifdef CONFIG_XFRM_BEET
+		unsigned short beet_family = 0;
+#endif
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
@@ -98,11 +115,26 @@
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
+#ifdef CONFIG_XFRM_BEET
+		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
+#else
 		if (xfrm[i]->props.mode) {
+#endif
 			remote = xfrm[i]->id.daddr.a4;
 			local  = xfrm[i]->props.saddr.a4;
 			tunnel = 1;
 		}
+#ifdef CONFIG_XFRM_BEET
+		else if (xfrm[i]->props.mode == XFRM_MODE_BEET) {
+
+			if(xfrm[i]->props.beet_family_out == AF_INET){
+				remotebeet.in = (struct in_addr*)&xfrm[i]->id.daddr;
+				localbeet.in = (struct in_addr*)&xfrm[i]->props.saddr;
+				beet_family = xfrm[i]->props.beet_family_out;
+			} else
+				BUG_ON(1);
+		}
+#endif
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
@@ -113,6 +145,18 @@
 					      &fl_tunnel, AF_INET);
 			if (err)
 				goto error;
+#ifdef CONFIG_XFRM_BEET
+		} else if (beet_family) {
+			fl_tunnel.fl4_dst = remotebeet.in->s_addr;
+			fl_tunnel.fl4_src = localbeet.in->s_addr;
+			
+			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+					      &fl_tunnel, beet_family);
+			/* Without this, the BEET mode crashes
+			   indeterministically -Abi */
+			rt->peer = NULL;
+			rt_bind_peer(rt,1);
+#endif
 		} else
 			dst_hold(&rt->u.dst);
 	}
--- linux-2.6.12.2-orig/net/ipv6/esp6.c
+++ linux-2.6.12.2/net/ipv6/esp6.c
@@ -22,6 +22,16 @@
  * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  * 	
  * 	This file is derived from net/ipv4/esp.c
+ *
+ *
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
+ *
  */
 
 #include <linux/config.h>
@@ -365,7 +375,11 @@
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
 	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+#else
 	if (x->props.mode)
+#endif
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = esp;
 	return 0;
--- linux-2.6.12.2-orig/net/ipv6/xfrm6_input.c
+++ linux-2.6.12.2/net/ipv6/xfrm6_input.c
@@ -64,6 +64,18 @@
 		if (xfrm_state_check_expire(x))
 			goto drop_unlock;
 
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_BEET) {
+			if (x->props.beet_family_in == AF_INET6 && x->props.beet_family_out == AF_INET6){
+				struct ipv6hdr *ip6h = (struct ipv6hdr *)skb->nh.raw;
+				ipv6_addr_copy(&ip6h->daddr,
+					       (struct in6_addr *) &x->sel.daddr.a6);
+				ipv6_addr_copy(&ip6h->saddr,
+					       (struct in6_addr *) &x->sel.saddr.a6);
+			} else
+				BUG_ON(1);
+		}
+#endif
 		nexthdr = x->type->input(x, &(xfrm_vec[xfrm_nr].decap), skb);
 		if (nexthdr <= 0)
 			goto drop_unlock;
@@ -80,7 +92,11 @@
 
 		xfrm_vec[xfrm_nr++].xvec = x;
 
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
+#else
 		if (x->props.mode) { /* XXX */
+#endif
 			if (nexthdr != IPPROTO_IPV6)
 				goto drop;
 			if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
@@ -97,6 +113,33 @@
 			skb->nh.raw = skb->data;
 			decaps = 1;
 			break;
+#ifdef CONFIG_XFRM_BEET
+		} else if (x->props.mode == XFRM_MODE_BEET) {
+			struct ipv6hdr *ip6h = skb->nh.ipv6h;
+			int size = sizeof(struct ipv6hdr);
+			__u16 total = ntohs(ip6h->payload_len);
+
+			/* is the buffer a clone?
+			 * then create identical copy of header of skb */
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto drop;
+
+			/* add data to the start of the buffer */
+			skb_push(skb, size);
+			/* move the raw header into new space */
+			memmove(skb->data, skb->nh.raw, size);
+			/* move MAC header */
+			skb->mac.raw = memmove(skb->data - skb->mac_len,
+					       skb->mac.raw, skb->mac_len);
+			skb->nh.raw = skb->data;
+
+			ip6h->payload_len = htons(total + size);
+			--ip6h->hop_limit;
+			decaps = 1;
+
+			break;
+#endif
 		}
 
 		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) < 0)
--- linux-2.6.12.2-orig/net/ipv6/xfrm6_output.c
+++ linux-2.6.12.2/net/ipv6/xfrm6_output.c
@@ -7,6 +7,14 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version
  * 2 of the License, or (at your option) any later version.
+ *
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <linux/skbuff.h>
@@ -17,6 +25,10 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
+#ifdef CONFIG_XFRM_BEET
+#include <net/ip.h>
+#endif
+
 /* Add encapsulation header.
  *
  * In transport mode, the IP header and mutable extension headers will be moved
@@ -42,7 +54,12 @@
 	skb_push(skb, x->props.header_len);
 	iph = skb->nh.ipv6h;
 
+
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_TRANSPORT) {
+#else
 	if (!x->props.mode) {
+#endif
 		u8 *prevhdr;
 		int hdr_len;
 
@@ -51,6 +68,16 @@
 		skb->h.raw = skb->data + hdr_len;
 		memmove(skb->data, iph, hdr_len);
 		return;
+
+#ifdef CONFIG_XFRM_BEET
+	} else if (x->props.mode == XFRM_MODE_BEET) {
+	        
+		memmove(skb->data, skb->nh.raw, sizeof(struct ipv6hdr));
+		skb->nh.raw = &((struct ipv6hdr *)skb->data)->nexthdr;
+		skb->h.ipv6h = ((struct ipv6hdr *)skb->data) + 1;
+		return;
+
+#endif /* CONFIG_XFRM_BEET */
 	}
 
 	skb->nh.raw = skb->data;
@@ -104,7 +131,11 @@
 			goto error_nolock;
 	}
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
+#else
 	if (x->props.mode) {
+#endif
 		err = xfrm6_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
@@ -121,6 +152,19 @@
 	if (err)
 		goto error;
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_BEET) {
+		/* Change the outer header */
+		if (x->props.beet_family_in == AF_INET6 && x->props.beet_family_out == AF_INET6){
+			/* Inner = 6, Outer = 6 */
+			struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
+			ipv6_addr_copy(&iph->saddr, (struct in6_addr *)&x->props.saddr);
+			ipv6_addr_copy(&iph->daddr, (struct in6_addr *)&x->id.daddr);
+		} else
+			BUG_ON(1);
+	}
+#endif
+
 	x->curlft.bytes += skb->len;
 	x->curlft.packets++;
 
--- linux-2.6.12.2-orig/net/ipv6/xfrm6_policy.c
+++ linux-2.6.12.2/net/ipv6/xfrm6_policy.c
@@ -8,7 +8,14 @@
  * 		IPv6 support
  * 	YOSHIFUJI Hideaki
  * 		Split up af-specific portion
- * 
+ *
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <asm/bug.h>
@@ -84,6 +91,12 @@
 			}
 		}
 	};
+#ifdef CONFIG_XFRM_BEET
+	union {
+		struct in6_addr *in6;
+		struct in_addr *in;
+	} remotebeet, localbeet;
+#endif	
 	int i;
 	int err = 0;
 	int header_len = 0;
@@ -96,6 +109,9 @@
 		struct dst_entry *dst1 = dst_alloc(&xfrm6_dst_ops);
 		struct xfrm_dst *xdst;
 		int tunnel = 0;
+#ifdef CONFIG_XFRM_BEET
+		unsigned short beet_family = 0;
+#endif	
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
@@ -118,11 +134,25 @@
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
+#ifdef CONFIG_XFRM_BEET
+		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
+#else
 		if (xfrm[i]->props.mode) {
+#endif
 			remote = (struct in6_addr*)&xfrm[i]->id.daddr;
 			local  = (struct in6_addr*)&xfrm[i]->props.saddr;
 			tunnel = 1;
 		}
+#ifdef CONFIG_XFRM_BEET
+		else if (xfrm[i]->props.mode == XFRM_MODE_BEET) {
+			if (xfrm[i]->props.beet_family_out == AF_INET6) {
+				beet_family = xfrm[i]->props.beet_family_out;
+				remotebeet.in6 = (struct in6_addr*)&xfrm[i]->id.daddr;
+				localbeet.in6 = (struct in6_addr*)&xfrm[i]->props.saddr;
+			} else
+				BUG_ON(1);
+		}
+#endif
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
@@ -133,6 +163,13 @@
 					      &fl_tunnel, AF_INET6);
 			if (err)
 				goto error;
+#ifdef CONFIG_XFRM_BEET
+		} else if (beet_family) {
+			ipv6_addr_copy(&fl_tunnel.fl6_dst, remotebeet.in6);
+			ipv6_addr_copy(&fl_tunnel.fl6_src, localbeet.in6);
+			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+					      &fl_tunnel, beet_family);
+#endif
 		} else
 			dst_hold(&rt->u.dst);
 	}
--- linux-2.6.12.2-orig/net/key/af_key.c
+++ linux-2.6.12.2/net/key/af_key.c
@@ -12,6 +12,14 @@
  *		Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *		Kazunori MIYAZAWA / USAGI Project <miyazawa@linux-ipv6.org>
  *		Derek Atkins <derek@ihtfp.com>
+ *
+ * Changes:     BEET support
+ *              Abhinav Pathak <abpathak@iitk.ac.in>
+ *              Diego Beltrami <diego.beltrami@hiit.fi>
+ *              Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *              Miika Komu <miika@iki.fi>
+ *              Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <linux/config.h>
@@ -28,6 +36,10 @@
 #include <linux/init.h>
 #include <net/xfrm.h>
 
+#ifdef CONFIG_XFRM_BEET
+#include <linux/xfrm.h>
+#endif
+
 #include <net/sock.h>
 
 #define _X2KEY(x) ((x) == XFRM_INF ? 0 : (x))
@@ -1584,7 +1596,11 @@
 	}
 
 	/* addresses present only in tunnel mode */
+#ifdef CONFIG_XFRM_BEET
+	if (t->mode == IPSEC_MODE_TUNNEL-1) {
+#else
 	if (t->mode) {
+#endif
 		switch (xp->family) {
 		case AF_INET:
 			sin = (void*)(rq+1);
@@ -1612,6 +1628,40 @@
 			return -EINVAL;
 		}
 	}
+#ifdef CONFIG_XFRM_BEET
+	else if (t->mode == IPSEC_MODE_BEET-1) {
+		struct sockaddr *sa;
+
+		sa = (struct sockaddr *)(rq+1);
+		switch(sa->sa_family) {
+		case AF_INET:
+			sin = (struct sockaddr_in *)sa;
+			t->saddr.a4 = sin->sin_addr.s_addr;
+			sin++;
+			if (sin->sin_family != AF_INET)
+				return -EINVAL;
+			t->id.daddr.a4 = sin->sin_addr.s_addr;
+			t->family = AF_INET;
+
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case AF_INET6:
+			sin6 = (struct sockaddr_in6 *)sa;
+			memcpy(t->saddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
+			sin6++;
+			if (sin6->sin6_family != AF_INET6)
+				return -EINVAL;
+			memcpy(t->id.daddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
+			t->family = AF_INET6;
+
+			break;
+#endif /* CONFIG_IPV6 */
+		default:
+			return -EINVAL;
+		}
+	}
+#endif /* CONFIG_XFRM_BEET */
+
 	/* No way to set this via kame pfkey */
 	t->aalgos = t->ealgos = t->calgos = ~0;
 	xp->xfrm_nr++;
@@ -1935,6 +1985,48 @@
 	    (err = parse_ipsecrequests(xp, pol)) < 0)
 		goto out;
 
+#ifdef CONFIG_XFRM_BEET
+	/* lookup the SA (xfrm_state) and copy the inner addresses from
+	 * the policy (xfrm_policy) to the selector within the state
+	 */
+	if (xp->xfrm_vec[0].mode == IPSEC_MODE_BEET-1) {
+		struct xfrm_state *x;
+		if (xp->family == AF_INET6) {
+			if ((x = xfrm_lookup_bydst(XFRM_MODE_BEET, 
+						&xp->xfrm_vec[0].id.daddr,
+						&xp->xfrm_vec[0].saddr,
+						AF_INET6))) {
+				/* Inner = 6, Outer = 6 */
+				x->props.beet_family_out = AF_INET6;
+				x->props.beet_family_in = AF_INET6;
+				/* insert inner addresses into the selector */
+				memcpy(	&x->sel.daddr, &xp->selector.daddr,
+					sizeof(xfrm_address_t));
+				memcpy(	&x->sel.saddr, &xp->selector.saddr,
+					sizeof(xfrm_address_t));
+				x->type = xfrm_get_type(x->id.proto, x->props.beet_family_in);
+			}
+		} else if (xp->family == AF_INET) {
+			if ((x = xfrm_lookup_bydst(XFRM_MODE_BEET, 
+						   &xp->xfrm_vec[0].id.daddr,
+						   &xp->xfrm_vec[0].saddr, 
+						    AF_INET)))
+			{
+				/* Inner = 4, Outer = 4 */
+				x->props.beet_family_out = AF_INET;
+				x->props.beet_family_in = AF_INET;
+				/* insert inner addresses into the selector */
+				memcpy(	&x->sel.daddr, &xp->selector.daddr,
+					sizeof(xfrm_address_t));
+				memcpy(	&x->sel.saddr, &xp->selector.saddr,
+					sizeof(xfrm_address_t));
+				x->type = xfrm_get_type(x->id.proto, x->props.beet_family_in);
+			}
+		} else {
+			BUG_ON(1);
+		}
+	}
+#endif
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
 	if (IS_ERR(out_skb)) {
 		err =  PTR_ERR(out_skb);
--- linux-2.6.12.2-orig/net/xfrm/Kconfig
+++ linux-2.6.12.2/net/xfrm/Kconfig
@@ -10,3 +10,19 @@
 
 	  If unsure, say Y.
 
+config XFRM_BEET
+        bool "IPsec BEET mode"
+        depends on XFRM
+        ---help---
+          IPsec BEET mode is combination of IPsec transport and tunnel mode.
+          Currently, it is used only by HIP.
+
+          If unsure, say N.
+
+config XFRM_BEET_DEBUG
+        bool "IPsec BEET mode debugging"
+        depends on XFRM_BEET
+        ---help---
+          Enables BEET mode debugging via syslog.
+
+          If unsure, say N.
--- linux-2.6.12.2-orig/net/xfrm/xfrm_state.c
+++ linux-2.6.12.2/net/xfrm/xfrm_state.c
@@ -1036,3 +1036,31 @@
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task, NULL);
 }
 
+#ifdef CONFIG_XFRM_BEET
+
+struct xfrm_state *
+xfrm_lookup_bydst(u8 mode, xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family)
+{
+	struct xfrm_state *x;
+	unsigned h = xfrm_dst_hash(daddr, family);
+
+	list_for_each_entry(x, xfrm_state_bydst+h, bydst){
+		
+		if (x->props.family == AF_INET6 &&
+		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
+		    mode == x->props.mode &&
+		    ipv6_addr_equal((struct in6_addr *)saddr, (struct in6_addr *)x->props.saddr.a6)) {
+			return(x);
+		}
+		
+		if (x->props.family == AF_INET &&
+		    daddr->a4 == x->id.daddr.a4 &&
+		    mode == x->props.mode &&
+		    saddr->a4 == x->props.saddr.a4)
+			return(x);
+		
+	}
+	return(NULL);
+}
+
+#endif //CONFIG_XFRM_BEET

--=-cxEtPhsKh15+QDSHjSKR--
