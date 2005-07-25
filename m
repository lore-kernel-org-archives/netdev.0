From: Diego Beltrami <diego.beltrami@HIIT.FI>
Subject: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Mon, 25 Jul 2005 15:41:48 +0300
Message-ID: <1122295307.14873.37.camel__32160.8250299052$1122296037$gmane$org@odysse>
Reply-To: diego.beltrami@HIIT.FI
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: infrahip@HIIT.FI, gurtov@cs.helsinki.fi, jeffrey.m.ahrenholz@boeing.com,
        kristian.slavov@nomadiclab.com, hipl-users@freelists.org,
        hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi folks,

we have been working for three months to implement a new IPsec mode,
the "BEET" mode, for Linux. Below is a link to the BEET specification
and
the abstract:

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt

Abstract

   This document specifies a new mode, called Bound End-to-End Tunnel
   (BEET) mode, for IPsec ESP.  The new mode augments the existing ESP
   tunnel and transport modes.  For end-to-end tunnels, the new mode
   provides limited tunnel mode semantics without the regular tunnel
   mode overhead.  The mode is intended to support new uses of ESP,
   including mobility and multi-address multi-homing.

The BEET mode is required by the Host Identity Protocol (HIP), which
provides authenticated Diffie-Hellman for end-hosts, as well as
mobility and multihoming support. The BEET mode is also useful for
other similar protocols being developed at the IETF.

Ericsson has already developed a BEET patch for *BSD. Our patch
provides the similar functionality, but using the XFRM architecture.
The patch is included at the end of this email and also at the following
URL:
http://hipl.hiit.fi/beet/beet-patch-v1.0-2.6.12.2

We have made some testing in order to assure the quality of the
patch. All the tests passed, and below is a list of them:

* Does not break transport and tunnel mode (with CONFIG_XFRM_BEET
on/off)
* All inner-outer combinations with varying test applications:
  ICMP, ICMPv6, FTP, SSH, nc, nc6
* Works with fragmented packets
* Interoperability with HIPL
* Real machines, virtual machines (vmware)
* Tested with long data streams

The BEET development team:

* Abhinav Pathak <abpathak@iitk.ac.in> (InfraHIP/HIIT)
* Diego Beltrami <diego.beltrami@hiit.fi> (InfraHIP/HIIT)
* Kristian Slavov <kristian.slavov@nomadiclab.com> (Ericsson)
* Miika Komu <miika@iki.fi> (InfraHIP/HIIT)
* Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com> (Boeing)

On the behalf of the BEET development team,

Signed-off-by: Diego Beltrami <diego.beltrami@hiit.fi>




diff -urN linux-2.6.12.2/Documentation/README.BEET
linux-beet-2.6.12.2/Documentation/README.BEET
--- linux-2.6.12.2/Documentation/README.BEET	1970-01-01
02:00:00.000000000 +0200
+++ linux-beet-2.6.12.2/Documentation/README.BEET	2005-07-25
14:39:36.000000000 +0300
@@ -0,0 +1,465 @@
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
+      xfrm_bundle_create // create output (dst) chain if bundle was not
found
+        __xfrm4_bundle_create
+  ip_push_pending_frames
+    dst_output(skb)	//this calls skb->dst->output();	
+     xfrm4_output	//This finally returns 4 (NET_XMIT_BYPASS) to
dst_output();
+       xfrm4_encap
+       esp_output
+       xfrm_beet_output	//change the ip header to outer.
+    dst_output(skb)
+     ip_output
+       ip_finish_output	Or ip_fragment 	//depending on size of packet
+          // Returns 0 to dst_output(); which makes dst_output to come
out of infinite loop.
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
+              nexthdr = x->type->input(x, xfrm.decap, skb) // ==
esp_input
+                esp_input()          // process ESP based on inner
address
+                  returns 0 ;
+              /* beet handling in xfrm_rcv_spi */
+              netif_rx()
+      // ip_input_finish returns 0
+  // netif_receive_skb returns 0
+netif_receive_skb	//Now we have an IPv4 packet. So the input flow is
for v4 packet.
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ip_rcv()
+      nf_hook()	//This calls ip_rcv_finish(skb)
+      ip_rcv_finish()	//Here the skb->dst is NULL and so is filled for
the input side.
+        ip6_route_input()
+        dst_input()->ip_forward() or ip_input()
+    ip_input // remove the IPv4 header
+      ip_input_finish
+	...
+	 ...
+          ...  
+
+
+Sending (inner IPv6, outer IPv4)(6-4)
+=====================================
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
+      xfrm_bundle_create // create output (dst) chain if bundle was not
found
+        __xfrm6_bundle_create
+  rawv6_push_pending_frames
+    ip6_push_pending_frames
+      dst_output(skb)
+      	xfrm6_output
+           xfrm6_encap
+           esp6_output			//esp calculation is done on inner addresses
!!
+	   xfrm_beet_output		//Change the ip header to outer IP Header
+      dst_output(skb)
+     ip_output
+	  ip_finish_output	Or ip_fragment 	//depending on size of packet
+          // Returns 0 to dst_output(); which makes dst_output to come
out of infinite loop.
+    dev_queue_xmit
+
+
+Receiving (inner IPv6, outer IPv4)(6-4)
+===========
+
+net_rx_action()
+e1000_clean()           // dependent on network hardware
+e1000_clean_rx_irq()
+netif_receive_skb()
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ip_rcv() // skb len = 140
+      nf_hook()
+      ip_rcv_finish()
+        ip_route_input()
+        dst_input()->ip_forward() or ip_input()
+    ip_input // remove the IPv6 header
+      ip_input_finish // calls recursively the ->handler = xfrm6_rcv
+        ret = ipprot->handler(&skb, &nhoff); // handler = xfrm6_rcv_spi
+          xfrm4_rcv()
+            xfrm4_rcv_encap() 
+              xfrm4_parse_spi()
+              xfrm_state_lookup() // lookup IPsec SA  
+	      xfrm_beet_input(skb, x) //To change to inner IP header.
+              nexthdr = x->type->input(x, xfrm.decap, skb) // ==
esp6_input
+                esp6_input()          // process ESP based on inner
address
+                  returns 0 ;
+              /* beet handling in xfrm_rcv_spi */
+              netif_rx()
+      // ip6_input_finish returns 0
+  // netif_receive_skb returns 0
+netif_receive_skb
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ip6_rcv() // skb len = 104
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
+tcp_v6_rcv()            // or icmpv6_rcv(), anyway, deliver to upper
layer
+
+
+Sending (inner IPv4, outer IPv6)(4-6)
+=====================================
+
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
+      xfrm_bundle_create // create output (dst) chain if bundle was not
found
+        __xfrm4_bundle_create
+  ip_push_pending_frames
+    dst_output(skb)	//this calls skb->dst->output();	
+     xfrm4_output	//This finally returns 4 (NET_XMIT_BYPASS) to
dst_output();
+       xfrm4_encap
+       esp_output
+       xfrm_beet_output	
+    dst_output(skb)
+      ip6_output
+        ip6_output2
+	  ip6_output_finish	// Returns 0 to dst_output(); which makes
dst_output to come out of infinite loop.
+    dev_queue_xmit
+
+
+Receiving (inner IPv4, outer IPv6)(4-6)
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
+              nexthdr = x->type->input(x, xfrm.decap, skb) // ==
esp_input
+                esp_input()          // process ESP
+                  returns iph->protocol ;
+              /* beet handling in xfrm_rcv_spi */
+              netif_rx()
+      // ip6_input_finish returns 0
+  // netif_receive_skb returns 0
+netif_receive_skb	//Now we have an IPv4 packet. So the input flow is
for v4 packet.
+  deliver_skb()
+  ret = pt_prev->func(skb, skb->dev, pt_prev);
+    ip_rcv()
+      nf_hook()	//This calls ip_rcv_finish(skb)
+      ip_rcv_finish()	//Here the skb->dst is NULL and so is filled for
the input side.
+        ip_route_input()
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
+      xfrm_bundle_create // create output (dst) chain if bundle was not
found
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
+              nexthdr = x->type->input(x, xfrm.decap, skb) // ==
esp6_input
+                esp6_input()          // process ESP
+                  returns 58 (ICMPv6)	//returns the nexthdr in the ipv6
packet.
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
+tcp_v6_rcv()            // or icmpv6_rcv(), anyway, deliver to upper
layer
+
+<this is Kristian's text from ARCHITECTURE, fold into above>
+output path
+ip6_datagram_connect()
+  ip6_dst_lookup() // success
+  xfrm_lookup()  // lookup policy using inner IP, matching selectors in
SP and
+                    flow information 
+    xfrm_sk_policy_lookup() // success
+    flow_cache_lookup()     // success
+    xfrm_find_bundle() // check for a bundle, if found use it, or
create new
+    xfrm_tmpl_resolve() // when creating new, search for SA for each
transform
+                        // once valid SA found, use it to create bundle
and link
+                        // to SP. modify skbuff's dst-pointer pointing
to next
+                        // xfrmX_output(), after encaps/trans dst is
consulted
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
+Files Added
+--------------
+This is a list of the included files for the BEET patch
+
+net/xfrm/xfrm_beet.c
+- This file contains the functions xfrm_beet_input() and
xfrm_beet_output()
+  which deals with the incoming and the outgoing BEET packets,
respectively.
+  The purpose of these functions is to interchange the inner addresses
with 
+  the outer addresses in the IP header (in case of outgoing packets)
and viceversa
+  (in case of incoming packets).
+  The file describes two functions:
+	1. xfrm_beet_input
+		Used in receiving side, changes the ip header to inner ip header
+	2. xfrm_beet_output
+		Used in sending side, changes the ip header to outer ip header
+
+Files changed
+-------------
+This is a list of changes made by the BEET patch.
+
+include/linux/ipsec.h
+ - IPSEC_MODE_BEET added
+   This is the new type of SA that may be created.
+   XXX note: are we overusing XFRM_MODE_BEET where IPSEC_MODE_BEET
should be
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
+   family is required because the family may differ from the one in the
selector
+ - possible change to xfrm_selector_match() (commented out)
+
+net/ipv4/xfrm4_input.c
+ - in xfrm4_rcv_encap() call is made to xfrm_beet_input(), to change
the 
+   ip header to inner before going for esp test.
+ - in xfrm4_rcv_encap() check x->props.mode for XFRM_MODE_TUNNEL, _BEET
+   checks address family (x->props.beet_family), and makes final
adjustments 
+   to packet before requeing it.
+
+net/ipv4/xfrm4_output.c 
+ - xfrm4_encap(), note to fix the BEET case, like xfrm6_encap
+ - xfrm4_output(), added a call to xfrm_beet_output() to change the ip
header
+
+net/ipv4/esp4.c 
+ - in esp_init_state(), check if x->props.mode == XFRM_MODE_TUNNEL,
+   then x->props.header_len += sizeof(struct ipv6hdr), not if
(x->props.mode)
+ - in esp_input(), while returning, if the outer family is AF_INET6,
then return 
+   iph->protocol, else return 0.
+
+net/ipv6/esp6.c 
+ - in esp6_init_state(), check if x->props.mode == XFRM_MODE_TUNNEL,
+   then x->props.header_len += sizeof(struct ipv6hdr), not if
(x->props.mode)
+ - in esp6_input(), while returning, if the outer family is AF_INET,
then 
+   set next header field and return 0, else return ret.
+
+
+net/ipv6/xfrm6_input.c
+ - in xfrm6-rcv_spi(), call is made to xfrm_beet_input(), which changes
to 
+   inner ip header before sending to esp decapsulation.
+ - in xfrm6_rcv_spi(), handle x->props.mode = XFRM_MODE_BEET
+   checks address family (x->props.beet_family), makes final
adjustments to
+   packet before requeing it.
+
+net/ipv6/xfrm6_output.c 
+ - xfrm6_encap() add ipv4 header vars, check if
(x->props.mode==XFRM_MODE_BEET)
+   makes space for appropriate esp header and sends to espX_output
where X depends
+   on inner family of beet.
+ - xfrm6_output() change if(x->props.mode) to
(x->props.mode==XFRM_MODE_TUNNEL)
+   Also a call is made to xfrm_beet_output after esp calculations, to
change the
+   ip header to outer ip header.
+
+net/ipv6/xfrm6_policy.c
+ (on output...)
+ - in __xfrm6_bundle_create() added remotebeet, localbeet vars,
+   get the IPv6 headers from xfrm[i]->id.daddr (remote) and
+   xfrm[i]->props.saddr (local)
+   copy IPv4 or IPv6 addresses from remote/localbeet to
fl_tunnel.fl4/6_dst/src
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
+   ipv6_addr_is_hit(), hip_xfrm_handler_notify(),
hip_xfrm_handler_acquire(),
+   hip_xfrm_handler_policy_notify(), hip_register_xfrm_km_handler(),
etc
diff -urN linux-2.6.12.2/include/linux/ipsec.h
linux-beet-2.6.12.2/include/linux/ipsec.h
--- linux-2.6.12.2/include/linux/ipsec.h	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/include/linux/ipsec.h	2005-07-25
14:39:01.000000000 +0300
@@ -13,6 +13,9 @@
 	IPSEC_MODE_ANY		= 0,	/* We do not support this for SA */
 	IPSEC_MODE_TRANSPORT	= 1,
 	IPSEC_MODE_TUNNEL	= 2
+#ifdef CONFIG_XFRM_BEET
+	,IPSEC_MODE_BEET         = 3
+#endif
 };
 
 enum {
diff -urN linux-2.6.12.2/include/linux/xfrm.h
linux-beet-2.6.12.2/include/linux/xfrm.h
--- linux-2.6.12.2/include/linux/xfrm.h	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/include/linux/xfrm.h	2005-07-25
14:39:01.000000000 +0300
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
diff -urN linux-2.6.12.2/include/net/xfrm.h
linux-beet-2.6.12.2/include/net/xfrm.h
--- linux-2.6.12.2/include/net/xfrm.h	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/include/net/xfrm.h	2005-07-25 15:03:01.000000000
+0300
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
+extern struct xfrm_state * xfrm_lookup_bydst(u8 mode, xfrm_address_t
*daddr, xfrm_address_t *saddr, unsigned short family);
+extern int xfrm_beet_output(struct sk_buff *skb);
+extern int xfrm_beet_input(struct sk_buff *skb, struct xfrm_state *x);
+
+#endif
 
 #ifdef CONFIG_XFRM
 extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
diff -urN linux-2.6.12.2/net/ipv4/esp4.c
linux-beet-2.6.12.2/net/ipv4/esp4.c
--- linux-2.6.12.2/net/ipv4/esp4.c	2005-06-30 02:00:53.000000000 +0300
+++ linux-beet-2.6.12.2/net/ipv4/esp4.c	2005-07-25 14:39:11.000000000
+0300
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
+	int hdr_len = skb->h.raw - skb->data + sizeof(*esph) +
esp->conf.ivlen;
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
@@ -238,7 +262,14 @@
 		skb->nh.iph->tot_len = htons(skb->len);
 	}
 
+#ifdef CONFIG_XFRM_BEET
+	if(x->props.mode == XFRM_MODE_BEET && x->props.beet_family_out ==
AF_INET6)
+		return iph->protocol ;
+	else
+		return 0;
+#else
 	return 0;
+#endif
 
 out:
 	return -EINVAL;
@@ -428,7 +459,11 @@
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key,
esp->conf.key_len))
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
diff -urN linux-2.6.12.2/net/ipv4/xfrm4_input.c
linux-beet-2.6.12.2/net/ipv4/xfrm4_input.c
--- linux-2.6.12.2/net/ipv4/xfrm4_input.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/ipv4/xfrm4_input.c	2005-07-25
14:39:11.000000000 +0300
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
@@ -78,6 +85,14 @@
 			goto drop_unlock;
 
 		xfrm_vec[xfrm_nr].decap.decap_type = encap_type;
+
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_BEET) {
+			/* Change the outer header with the inner data */
+			if (xfrm_beet_input(skb, x))
+				goto drop_unlock;
+		}
+#endif
 		if (x->type->input(x, &(xfrm_vec[xfrm_nr].decap), skb))
 			goto drop_unlock;
 
@@ -96,7 +111,11 @@
 
 		iph = skb->nh.iph;
 
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
+#else
 		if (x->props.mode) {
+#endif
 			if (iph->protocol != IPPROTO_IPIP)
 				goto drop;
 			if (!pskb_may_pull(skb, sizeof(struct iphdr)))
@@ -115,9 +134,69 @@
 			decaps = 1;
 			break;
 		}
+#ifdef CONFIG_XFRM_BEET
+		else if (x->props.mode == XFRM_MODE_BEET) {
+			struct iphdr *iph = skb->nh.iph;
+			struct ipv6hdr *ip6h = skb->nh.ipv6h;
+			int size = 0;
+
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto drop;
+
+			if (x->props.beet_family_in == AF_INET)
+				size = sizeof(struct iphdr);
+			else if (x->props.beet_family_in == AF_INET6)
+				size = sizeof(struct ipv6hdr);
+			else
+				BUG_ON(1);
+
+			skb_push(skb, size);
+
+			memmove(skb->data, skb->nh.raw, size);
+			skb->mac.raw = memmove(skb->data - skb->mac_len,
+					       skb->mac.raw, skb->mac_len);
+			skb->nh.raw = skb->data;
 
-		if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi, &seq)) <
0)
+			switch(x->props.beet_family_in) {
+			case AF_INET:
+
+				iph->tot_len = htons(skb->len);
+				iph->check = 0;
+				iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+				skb->protocol = htons(ETH_P_IP);
+				dst_release(skb->dst);
+				skb->dst = NULL;
+				decaps = 1;
+
+				break;
+			case AF_INET6:
+				ip6h = skb->nh.ipv6h;
+
+				skb->nh.ipv6h->payload_len =
htons(ntohs(skb->nh.ipv6h->payload_len) + size);
+				skb->protocol = htons(ETH_P_IPV6);
+
+				dst_release(skb->dst);
+				skb->dst = NULL;
+				decaps = 1;
+				break;
+			default:
+				BUG_ON(1);
+			}
+			break;
+		}
+		
+		if (x->props.mode == XFRM_MODE_BEET && x->props.beet_family_in ==
AF_INET6) {
+			if ((err = xfrm_parse_spi(skb, skb->nh.ipv6h->nexthdr, &spi, &seq))
< 0)
+				goto drop;
+		} else {
+			if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi, &seq)) <
0)
+				goto drop;
+		}
+#else
+	        if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi,
&seq)) < 0)
 			goto drop;
+#endif
 	} while (!err);
 
 	/* Allocate new secpath or COW existing one. */
diff -urN linux-2.6.12.2/net/ipv4/xfrm4_output.c
linux-beet-2.6.12.2/net/ipv4/xfrm4_output.c
--- linux-2.6.12.2/net/ipv4/xfrm4_output.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/ipv4/xfrm4_output.c	2005-07-25
14:39:11.000000000 +0300
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
  * On exit, skb->h will be set to the start of the payload to be
processed
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
+         * This is because otherwise the BEET patch crashes in any case
with Inner=4
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
@@ -120,6 +154,15 @@
 	if (err)
 		goto error;
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_BEET) {
+		/* Change the outer header */
+		err = xfrm_beet_output(skb);
+		if (err)
+			goto error;
+	}
+#endif
+
 	x->curlft.bytes += skb->len;
 	x->curlft.packets++;
 
diff -urN linux-2.6.12.2/net/ipv4/xfrm4_policy.c
linux-beet-2.6.12.2/net/ipv4/xfrm4_policy.c
--- linux-2.6.12.2/net/ipv4/xfrm4_policy.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/ipv4/xfrm4_policy.c	2005-07-25
15:03:01.000000000 +0300
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
@@ -98,11 +115,28 @@
 
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
+			beet_family = xfrm[i]->props.beet_family_out;
+			if(beet_family == AF_INET6){
+				remotebeet.in6 = (struct in6_addr*)&xfrm[i]->id.daddr;
+				localbeet.in6 = (struct in6_addr*)&xfrm[i]->props.saddr;
+			} else if(beet_family == AF_INET){
+				remotebeet.in = (struct in_addr*)&xfrm[i]->id.daddr;
+				localbeet.in = (struct in_addr*)&xfrm[i]->props.saddr;
+			}
+		}
+#endif
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
@@ -113,6 +147,28 @@
 					      &fl_tunnel, AF_INET);
 			if (err)
 				goto error;
+#ifdef CONFIG_XFRM_BEET
+		} else if (beet_family) {
+			switch(beet_family) {
+			case AF_INET:
+				fl_tunnel.fl4_dst = remotebeet.in->s_addr;
+				fl_tunnel.fl4_src = localbeet.in->s_addr;
+				break;
+			case AF_INET6:
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, remotebeet.in6);
+				ipv6_addr_copy(&fl_tunnel.fl6_src, localbeet.in6);
+				break;
+			default:
+				BUG_ON(1);
+			}
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
diff -urN linux-2.6.12.2/net/ipv6/esp6.c
linux-beet-2.6.12.2/net/ipv6/esp6.c
--- linux-2.6.12.2/net/ipv6/esp6.c	2005-06-30 02:00:53.000000000 +0300
+++ linux-beet-2.6.12.2/net/ipv6/esp6.c	2005-07-25 14:39:11.000000000
+0300
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
@@ -225,6 +235,13 @@
 		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 		skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct
ipv6hdr));
 		ret = nexthdr[1];
+#ifdef CONFIG_XFRM_BEET
+		if(x->props.mode == XFRM_MODE_BEET &&
+		   x->props.beet_family_out == AF_INET) {
+			skb->nh.ipv6h->nexthdr = nexthdr[1];
+			ret = 0;//This is because xfrm4_encap expects 0 if every thing is
correct
+		}
+#endif
 	}
 
 out:
@@ -365,7 +382,11 @@
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key,
esp->conf.key_len))
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
diff -urN linux-2.6.12.2/net/ipv6/xfrm6_input.c
linux-beet-2.6.12.2/net/ipv6/xfrm6_input.c
--- linux-2.6.12.2/net/ipv6/xfrm6_input.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/ipv6/xfrm6_input.c	2005-07-25
14:39:11.000000000 +0300
@@ -64,6 +64,12 @@
 		if (xfrm_state_check_expire(x))
 			goto drop_unlock;
 
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_BEET) {
+			if (xfrm_beet_input(skb, x))
+				goto drop_unlock;
+		}
+#endif
 		nexthdr = x->type->input(x, &(xfrm_vec[xfrm_nr].decap), skb);
 		if (nexthdr <= 0)
 			goto drop_unlock;
@@ -80,7 +86,11 @@
 
 		xfrm_vec[xfrm_nr++].xvec = x;
 
+#ifdef CONFIG_XFRM_BEET
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
+#else
 		if (x->props.mode) { /* XXX */
+#endif
 			if (nexthdr != IPPROTO_IPV6)
 				goto drop;
 			if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
@@ -97,6 +107,64 @@
 			skb->nh.raw = skb->data;
 			decaps = 1;
 			break;
+#ifdef CONFIG_XFRM_BEET
+		} else if (x->props.mode == XFRM_MODE_BEET) {
+			struct iphdr *iph = skb->nh.iph; // miika: this masks input arg
+			struct ipv6hdr *ip6h = skb->nh.ipv6h;
+			int size=0;
+			__u8 proto=0;
+			__u8 hops=0;
+			__u16 total = ntohs(ip6h->payload_len);
+
+			/* is the buffer a clone?
+			 * then create identical copy of header of skb */
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto drop;
+			if (x->props.beet_family_in == AF_INET) {
+				size = sizeof(struct iphdr);
+				proto = ip6h->nexthdr;
+				hops = ip6h->hop_limit;
+			} else if (x->props.beet_family_in == AF_INET6)
+				size = sizeof(struct ipv6hdr);
+			else
+				BUG_ON(1);
+			/* add data to the start of the buffer */
+			skb_push(skb, size);
+			/* move the raw header into new space */
+			memmove(skb->data, skb->nh.raw, size);
+			/* move MAC header */
+			skb->mac.raw = memmove(skb->data - skb->mac_len,
+					       skb->mac.raw, skb->mac_len);
+			skb->nh.raw = skb->data;
+
+			switch(x->props.beet_family_in) {
+			case AF_INET:
+
+				iph = (struct iphdr *)skb->nh.raw;
+
+				skb->protocol = htons(ETH_P_IP);
+				iph->tot_len = htons(skb->len);
+				iph->frag_off = htons(IP_DF);
+				iph->check=0;
+				iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+				dst_release(skb->dst);
+				skb->dst = NULL;
+
+				decaps = 1;
+				break;
+
+			case AF_INET6:
+				ip6h->payload_len = htons(total + size);
+				--ip6h->hop_limit;
+				decaps = 1;
+				break;
+			default:
+				BUG_ON(1);
+			}
+			break;
+#endif
 		}
 
 		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) < 0)
diff -urN linux-2.6.12.2/net/ipv6/xfrm6_output.c
linux-beet-2.6.12.2/net/ipv6/xfrm6_output.c
--- linux-2.6.12.2/net/ipv6/xfrm6_output.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/ipv6/xfrm6_output.c	2005-07-25
14:39:11.000000000 +0300
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
  * In transport mode, the IP header and mutable extension headers will
be moved
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
@@ -121,6 +152,15 @@
 	if (err)
 		goto error;
 
+#ifdef CONFIG_XFRM_BEET
+	if (x->props.mode == XFRM_MODE_BEET) {
+		/* Change the outer header */
+		err = xfrm_beet_output(skb);
+		if (err)
+			goto error;
+	}
+#endif
+
 	x->curlft.bytes += skb->len;
 	x->curlft.packets++;
 
diff -urN linux-2.6.12.2/net/ipv6/xfrm6_policy.c
linux-beet-2.6.12.2/net/ipv6/xfrm6_policy.c
--- linux-2.6.12.2/net/ipv6/xfrm6_policy.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/ipv6/xfrm6_policy.c	2005-07-25
15:03:01.000000000 +0300
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
@@ -118,11 +134,22 @@
 
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
+			beet_family = xfrm[i]->props.beet_family_out;
+			remotebeet.in6 = (struct in6_addr*)&xfrm[i]->id.daddr;
+			localbeet.in6 = (struct in6_addr*)&xfrm[i]->props.saddr;
+		}
+#endif
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
@@ -133,6 +160,23 @@
 					      &fl_tunnel, AF_INET6);
 			if (err)
 				goto error;
+#ifdef CONFIG_XFRM_BEET
+		} else if (beet_family) {
+			switch(beet_family) {
+			case AF_INET:
+				fl_tunnel.fl4_dst = remotebeet.in->s_addr;
+				fl_tunnel.fl4_src = localbeet.in->s_addr;
+				break;
+			case AF_INET6:
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, remotebeet.in6);
+				ipv6_addr_copy(&fl_tunnel.fl6_src, localbeet.in6);
+				break;
+			default:
+				BUG_ON(1);
+			}
+			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+					      &fl_tunnel, beet_family);
+#endif
 		} else
 			dst_hold(&rt->u.dst);
 	}
diff -urN linux-2.6.12.2/net/key/af_key.c
linux-beet-2.6.12.2/net/key/af_key.c
--- linux-2.6.12.2/net/key/af_key.c	2005-06-30 02:00:53.000000000 +0300
+++ linux-beet-2.6.12.2/net/key/af_key.c	2005-07-25 14:39:12.000000000
+0300
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
@@ -1935,6 +1985,78 @@
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
+			else if ((x = xfrm_lookup_bydst(XFRM_MODE_BEET, 
+						&xp->xfrm_vec[0].id.daddr,
+						&xp->xfrm_vec[0].saddr,
+						AF_INET))) {
+				/* Inner = 6, Outer = 4 */
+				x->props.beet_family_out = AF_INET;
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
+			else if ((x = xfrm_lookup_bydst(XFRM_MODE_BEET, 
+						   &xp->xfrm_vec[0].id.daddr,
+						   &xp->xfrm_vec[0].saddr, 
+						    AF_INET6)))
+			{
+				/* Inner = 4, Outer = 6 */
+				x->props.beet_family_out = AF_INET6;
+				x->props.beet_family_in = AF_INET;
+				/* insert inner addresses into the selector */
+				memcpy(	&x->sel.daddr, &xp->selector.daddr,
+					sizeof(xfrm_address_t));
+				memcpy(	&x->sel.saddr, &xp->selector.saddr,
+					sizeof(xfrm_address_t));
+				x->type = xfrm_get_type(x->id.proto, x->props.beet_family_in);
+			}
+			
+		} else {
+			BUG_ON(1);
+		}
+	}
+#endif
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
 	if (IS_ERR(out_skb)) {
 		err =  PTR_ERR(out_skb);
diff -urN linux-2.6.12.2/net/xfrm/Kconfig
linux-beet-2.6.12.2/net/xfrm/Kconfig
--- linux-2.6.12.2/net/xfrm/Kconfig	2005-06-30 02:00:53.000000000 +0300
+++ linux-beet-2.6.12.2/net/xfrm/Kconfig	2005-07-25 15:04:36.000000000
+0300
@@ -10,3 +10,11 @@
 
 	  If unsure, say Y.
 
+config XFRM_BEET
+        bool "IPsec BEET mode"
+        depends on XFRM
+        ---help---
+          IPsec BEET mode is combination of IPsec transport and tunnel
mode.
+          Currently, it is used only by HIP.
+
+          If unsure, say N.
diff -urN linux-2.6.12.2/net/xfrm/Kconfig~
linux-beet-2.6.12.2/net/xfrm/Kconfig~
--- linux-2.6.12.2/net/xfrm/Kconfig~	1970-01-01 02:00:00.000000000 +0200
+++ linux-beet-2.6.12.2/net/xfrm/Kconfig~	2005-07-25 14:39:13.000000000
+0300
@@ -0,0 +1,28 @@
+#
+# XFRM configuration
+#
+config XFRM_USER
+	tristate "IPsec user configuration interface"
+	depends on INET && XFRM
+	---help---
+	  Support for IPsec user configuration interface used
+	  by native Linux tools.
+
+	  If unsure, say Y.
+
+config XFRM_BEET
+        bool "IPsec BEET mode"
+        depends on XFRM
+        ---help---
+          IPsec BEET mode is combination of IPsec transport and tunnel
mode.
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
diff -urN linux-2.6.12.2/net/xfrm/Makefile
linux-beet-2.6.12.2/net/xfrm/Makefile
--- linux-2.6.12.2/net/xfrm/Makefile	2005-06-30 02:00:53.000000000 +0300
+++ linux-beet-2.6.12.2/net/xfrm/Makefile	2005-07-25 14:39:13.000000000
+0300
@@ -2,6 +2,6 @@
 # Makefile for the XFRM subsystem.
 #
 
-obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_input.o
xfrm_algo.o
+obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_input.o
xfrm_algo.o xfrm_beet.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff -urN linux-2.6.12.2/net/xfrm/xfrm_beet.c
linux-beet-2.6.12.2/net/xfrm/xfrm_beet.c
--- linux-2.6.12.2/net/xfrm/xfrm_beet.c	1970-01-01 02:00:00.000000000
+0200
+++ linux-beet-2.6.12.2/net/xfrm/xfrm_beet.c	2005-07-25
15:03:01.000000000 +0300
@@ -0,0 +1,227 @@
+/*
+ * xfrm_beet.c: allows for receiving and transmitting packet in BEET
mode
+ *
+ * Authors:
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
+ */
+
+#include <linux/workqueue.h>
+#include <net/xfrm.h>
+#include <linux/pfkeyv2.h>
+#include <linux/ipsec.h>
+#include <linux/module.h>
+#include <asm/uaccess.h>
+#include <net/ip.h>
+
+#ifdef CONFIG_XFRM_BEET
+
+/* xfrm_beet_output: deals with the outgoing BEET packets.
+ * It changes the outer ip header and correctly set
+ * the header fields
+ *
+ * @skb: structure sk_buff which contains the packet to be transmitted
+ *       skb->data points to the ip header
+*/
+int xfrm_beet_output(struct sk_buff *skb)
+{
+	int err = 0;
+	struct xfrm_state *x = skb->dst->xfrm;
+
+	if (x->props.beet_family_in == AF_INET && x->props.beet_family_out ==
AF_INET){
+		/* Inner = 4, Outer = 4 */
+		struct iphdr *iph = (struct iphdr*)skb->data;
+
+		iph->saddr = x->props.saddr.a4;
+		iph->daddr = x->id.daddr.a4;
+
+		skb->local_df = 1;	//I am a bit unsure on how to implement this -Abi
+
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+	} else if (x->props.beet_family_in == AF_INET &&
x->props.beet_family_out == AF_INET6){
+		/* Inner = 4, Outer = 6 */
+		struct iphdr *iph = (struct iphdr*)skb->data;
+		__u8 protocol, ttl;
+
+		protocol = iph->protocol;
+		ttl = iph->ttl;
+
+		if (skb_headroom(skb) <  sizeof(struct ipv6hdr) - sizeof(struct
iphdr)){
+			if (pskb_expand_head(skb, sizeof(struct ipv6hdr) - sizeof(struct
iphdr),0, GFP_ATOMIC))
+				return -EINVAL;		//Just returning from here.
+
+			skb->len += sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+			skb->nh.raw = skb->h.raw - sizeof(struct ipv6hdr);
+			skb->data = skb->nh.raw;
+
+		} else {
+			skb_push(skb, sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+			skb->nh.raw = skb->h.raw - sizeof(struct ipv6hdr);
+			skb->data = skb->nh.raw;
+		}
+
+		skb->protocol = htons(ETH_P_IPV6);
+
+		skb->nh.ipv6h = (struct ipv6hdr*)(skb->data);
+
+		skb->nh.ipv6h->version = 6;
+		skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct
ipv6hdr));
+		skb->nh.ipv6h->nexthdr =  protocol;
+		skb->nh.ipv6h->hop_limit = ttl;
+		ipv6_addr_copy(&skb->nh.ipv6h->saddr,(struct in6_addr
*)&x->props.saddr);
+		ipv6_addr_copy(&skb->nh.ipv6h->daddr, (struct in6_addr
*)&x->id.daddr);
+
+		skb->nh.ipv6h->priority    = 0;
+		skb->nh.ipv6h->flow_lbl[0] = 0;
+		skb->nh.ipv6h->flow_lbl[1] = 0;
+		skb->nh.ipv6h->flow_lbl[2] = 0;
+
+	} else if (x->props.beet_family_in == AF_INET6 &&
x->props.beet_family_out == AF_INET){
+		/* Inner = 6, Outer = 4 */
+		struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		u8 hop, proto;
+		u16 payload;
+		struct iphdr *ip4;
+		hop = iph->hop_limit;
+		proto = iph->nexthdr;
+
+		payload = ntohs(iph->payload_len) + sizeof(struct iphdr);
+
+		skb_pull(skb, delta);
+
+		skb->protocol = htons(ETH_P_IP);
+		ip4 = (struct iphdr *)skb->data;
+
+		ip4->ihl = (sizeof(struct iphdr) >> 2);
+		ip4->version = 4;
+		ip4->tos = 0;
+		ip4->tot_len = htons(payload);
+		ip4->id = 0;
+		ip4->frag_off = htons(IP_DF);
+		ip4->ttl = hop;
+		ip4->protocol = proto;
+		ip4->check = 0;
+		ip4->saddr = x->props.saddr.a4;
+		ip4->daddr = x->id.daddr.a4;
+		ip4->check = ip_fast_csum((unsigned char *)ip4, ip4->ihl);
+		/* The esp6_output assumes that skb->data points to outer IP header, 
+		 * skb->nh points eventual new ext hdrs and skb->h points to the ESP
header
+		 */
+		skb->nh.raw = skb->data; // there is no extension header
+
+	} else if (x->props.beet_family_in == AF_INET6 &&
x->props.beet_family_out == AF_INET6){
+		/* Inner = 6, Outer = 6 */
+		struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
+		ipv6_addr_copy(&iph->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&iph->daddr, (struct in6_addr *)&x->id.daddr);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(xfrm_beet_output);
+
+
+/* xfrm_beet_input: deals with the incoming BEET packets.
+ * It changes the outer ip header with the corresponding inner ip
header and addresses
+ *
+ * @skb: structure sk_buff. skb->nh.raw points to the outer ip address
+ *       skb->data and skb->h.raw point to the ESP to be decapsulated
+ *
+ * @x  : struct xfrm_state containing the state information
+ *
+*/
+int xfrm_beet_input(struct sk_buff *skb, struct xfrm_state *x)
+{
+	int err = 0;
+
+	if (x->props.beet_family_in == AF_INET && x->props.beet_family_out ==
AF_INET){
+		/* Inner = 4, Outer = 4 */
+		struct iphdr *iph = (struct iphdr *)skb->nh.iph;
+
+		iph->daddr = x->sel.daddr.a4;
+		iph->saddr = x->sel.saddr.a4;
+		iph->ttl--;
+		iph->tot_len = htons(skb->len);
+		iph->frag_off = htons(IP_DF);
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+	} else if (x->props.beet_family_in == AF_INET &&
x->props.beet_family_out == AF_INET6){
+		/* Inner = 4, Outer = 6 */
+		struct iphdr *iph;
+		__u8 proto = skb->nh.ipv6h->nexthdr;
+		__u8 hops = skb->nh.ipv6h->hop_limit;
+		
+		
+		skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr) - sizeof(struct
iphdr);
+		memmove(skb->h.raw, skb->data, skb->len);
+		skb->data = skb->h.raw;
+
+	
+		eth_hdr(skb)->h_proto=htons(ETH_P_IP);
+			
+		iph = (struct iphdr *)skb->nh.raw;
+		memset(iph, 0, sizeof(struct iphdr));
+		iph->daddr = x->sel.daddr.a4;
+		iph->saddr = x->sel.saddr.a4;
+		iph->ttl = hops--;
+		iph->protocol = proto;
+		iph->tot_len = htons(skb->len);
+		iph->frag_off = htons(IP_DF);
+		iph->ihl = 5;
+		iph->version = 4;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+		skb->protocol = htons(ETH_P_IP);
+		
+	} else if (x->props.beet_family_in == AF_INET6 &&
x->props.beet_family_out == AF_INET){
+		/* Inner = 6, Outer = 4 */
+		struct ipv6hdr *ip6h;
+		int proto = skb->nh.iph->protocol;
+		int hops = skb->nh.iph->ttl;
+		int total = skb->len - sizeof(struct iphdr);
+
+		if (skb_tailroom(skb) <  sizeof(struct ipv6hdr) - sizeof(struct
iphdr)){
+			if (pskb_expand_head(skb, 0, sizeof(struct ipv6hdr) - sizeof(struct
iphdr), GFP_ATOMIC))
+				return -EINVAL;		//Just returning from here.
+		}
+
+		skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
+		memmove(skb->h.raw, skb->data, skb->len);
+		skb->data = skb->h.raw;
+		skb->tail += sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+
+		eth_hdr(skb)->h_proto=htons(ETH_P_IPV6);
+		ip6h = skb->nh.ipv6h;
+
+		memset(ip6h, 0, sizeof(struct ipv6hdr));
+		ipv6_addr_copy(&ip6h->saddr, (struct in6_addr *)&x->sel.saddr.a6);
+		ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *)&x->sel.daddr.a6);
+		ip6h->payload_len = htons(total);
+		ip6h->hop_limit = hops-1;
+		ip6h->version = 6;
+		ip6h->nexthdr = proto;
+
+	 	skb->protocol = htons(ETH_P_IPV6);
+
+	} else if (x->props.beet_family_in == AF_INET6 &&
x->props.beet_family_out == AF_INET6){
+		/* Inner = 6, Outer = 6 */
+		struct ipv6hdr *ip6h = (struct ipv6hdr *)skb->nh.raw;
+		ipv6_addr_copy(&ip6h->daddr,
+			       (struct in6_addr *) &x->sel.daddr.a6);
+		ipv6_addr_copy(&ip6h->saddr,
+			       (struct in6_addr *) &x->sel.saddr.a6);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(xfrm_beet_input);
+
+#endif /* CONFIG_XFRM_BEET */
diff -urN linux-2.6.12.2/net/xfrm/xfrm_policy.c
linux-beet-2.6.12.2/net/xfrm/xfrm_policy.c
--- linux-2.6.12.2/net/xfrm/xfrm_policy.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/xfrm/xfrm_policy.c	2005-07-25
14:39:13.000000000 +0300
@@ -11,6 +11,13 @@
  * 		Split up af-specific portion
  *	Derek Atkins <derek@ihtfp.com>		Add the post_input processor
  * 	
+ * Changes: BEET support
+ *          Abhinav Pathak <abpathak@iitk.ac.in>
+ *          Diego Beltrami <diego.beltrami@hiit.fi>
+ *          Kristian Slavov <kristian.slavov@nomadiclab.com>
+ *          Miika Komu <miika@iki.fi>
+ *          Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
+ *
  */
 
 #include <asm/bug.h>
@@ -643,6 +650,10 @@
 		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
 
 		if (tmpl->mode) {
+#ifdef CONFIG_XFRM_BEET
+			if(tmpl->mode == XFRM_MODE_BEET)
+				family = tmpl->family;
+#endif
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
 		}
diff -urN linux-2.6.12.2/net/xfrm/xfrm_state.c
linux-beet-2.6.12.2/net/xfrm/xfrm_state.c
--- linux-2.6.12.2/net/xfrm/xfrm_state.c	2005-06-30 02:00:53.000000000
+0300
+++ linux-beet-2.6.12.2/net/xfrm/xfrm_state.c	2005-07-25
14:39:13.000000000 +0300
@@ -1036,3 +1036,31 @@
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task, NULL);
 }
 
+#ifdef CONFIG_XFRM_BEET
+
+struct xfrm_state *
+xfrm_lookup_bydst(u8 mode, xfrm_address_t *daddr, xfrm_address_t
*saddr, unsigned short family)
+{
+	struct xfrm_state *x;
+	unsigned h = xfrm_dst_hash(daddr, family);
+
+	list_for_each_entry(x, xfrm_state_bydst+h, bydst){
+		
+		if (x->props.family == AF_INET6 &&
+		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr
*)x->id.daddr.a6) &&
+		    mode == x->props.mode &&
+		    ipv6_addr_equal((struct in6_addr *)saddr, (struct in6_addr
*)x->props.saddr.a6)) {
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
