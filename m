From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 11/11] mpls: Add MPLS entropy label in
 flow_keys
Date: Fri, 22 May 2015 10:19:14 +0200
Message-ID: <20150522081914.GI2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-12-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33451 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424AbbEVITR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 04:19:17 -0400
Received: by wicmx19 with SMTP id mx19so33621372wic.0
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 01:19:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-12-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:46AM CEST, tom@herbertland.com wrote:
>In flow dissector if an MPLS header contains an entropy label this is
>saved in the new keyid field of flow_keys. The entropy label is
>then represented in the flow hash function input.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>
>---
> include/net/flow_dissector.h |  1 +
> net/core/flow_dissector.c    | 37 +++++++++++++++++++++++++++++++++++++
> 2 files changed, 38 insertions(+)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index f9a3084..65db4eb 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -118,6 +118,7 @@ enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
> 	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_label */
> 	FLOW_DISSECTOR_KEY_GRE_KEYID, /* struct flow_dissector_key_keyid */
>+	FLOW_DISSECTOR_KEY_MPLS_ENTROPY, /* struct flow_dissector_key_keyid */
> 
> 	FLOW_DISSECTOR_KEY_MAX,
> };
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index 20ce55d..da4e895 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -15,6 +15,7 @@
> #include <linux/ppp_defs.h>
> #include <linux/stddef.h>
> #include <linux/if_ether.h>
>+#include <linux/mpls.h>
> #include <net/flow_dissector.h>
> #include <scsi/fc/fc_fcoe.h>
> 
>@@ -286,6 +287,39 @@ ipv6:
> 		}
> 		return true;
> 	}
>+
>+	case htons(ETH_P_MPLS_UC):
>+	case htons(ETH_P_MPLS_MC): {
>+		struct mpls_label *hdr, _hdr[2];
>+mpls:
>+		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
>+					   hlen, &_hdr);
>+		if (!hdr)
>+			return false;
>+
>+		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) ==
>+		     MPLS_LABEL_ENTROPY) {
>+			if (skb_flow_dissector_uses_key(
>+					flow_dissector,
>+					FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {

You have this in your other patches as well. I believe that it not alway
make sense to be strict with 80char/line. In this case, I think that
following format is much better:

			if (skb_flow_dissector_uses_key(flow_dissector,
							FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {

>+				key_keyid = skb_flow_dissector_target(
>+					flow_dissector,
>+					FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
>+					target_container);

				key_keyid = skb_flow_dissector_target(flow_dissector,
								      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
								      target_container);


Another thing is that it might make sense to split __skb_flow_dissect
into multiple (inline) functions.
