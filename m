From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] flow_dissector: add mpls support
Date: Mon, 27 Mar 2017 22:39:06 +0200
Message-ID: <20170327203906.GI1869@nanopsycho.orion>
References: <20170327181342.GA3230@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35929 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdC0UrG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:47:06 -0400
Received: by mail-wr0-f193.google.com with SMTP id u1so16853824wra.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 13:47:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170327181342.GA3230@nvt-d.home.kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 27, 2017 at 08:13:42PM CEST, benjamin.lahaise@netronome.com wrote:
>Add support for parsing MPLS flows to the flow dissector in preparation for
>adding MPLS match support to cls_flower.
>
>Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
>Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
>Reviewed-by: Simon Horman <simon.horman@netronome.com>
>Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index ac97030..00d704f 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -41,6 +41,13 @@ struct flow_dissector_key_vlan {
> 	u16	padding;
> };
> 
>+struct flow_dissector_key_mpls {
>+	u32	mpls_ttl : 8,
                        ^ remove this space
           ^^^^^        
         unnecessary tab

>+		mpls_bos : 1,
>+		mpls_tc : 3,
>+		mpls_label : 20;
>+};
>+
> struct flow_dissector_key_keyid {
> 	__be32	keyid;
              ^^ also tab not necessary


Other than this nits, the patch looks good to me.
Reviewed-by: Jiri Pirko <jiri@mellanox.com>



> };
>@@ -169,6 +176,7 @@ enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
> 	FLOW_DISSECTOR_KEY_ENC_CONTROL, /* struct flow_dissector_key_control */
> 	FLOW_DISSECTOR_KEY_ENC_PORTS, /* struct flow_dissector_key_ports */
>+	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
> 
> 	FLOW_DISSECTOR_KEY_MAX,
> };
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index 5f3ae92..15185d8 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -126,9 +126,11 @@ __skb_flow_dissect_mpls(const struct sk_buff *skb,
> {
> 	struct flow_dissector_key_keyid *key_keyid;
> 	struct mpls_label *hdr, _hdr[2];
>+	u32 entry, label;
> 
> 	if (!dissector_uses_key(flow_dissector,
>-				FLOW_DISSECTOR_KEY_MPLS_ENTROPY))
>+				FLOW_DISSECTOR_KEY_MPLS_ENTROPY) &&
>+	    !dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_MPLS))
> 		return FLOW_DISSECT_RET_OUT_GOOD;
> 
> 	hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
>@@ -136,8 +138,25 @@ __skb_flow_dissect_mpls(const struct sk_buff *skb,
> 	if (!hdr)
> 		return FLOW_DISSECT_RET_OUT_BAD;
> 
>-	if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
>-	    MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
>+	entry = ntohl(hdr[0].entry);
>+	label = (entry & MPLS_LS_LABEL_MASK) >> MPLS_LS_LABEL_SHIFT;
>+
>+	if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_MPLS)) {
>+		struct flow_dissector_key_mpls *key_mpls;
>+
>+		key_mpls = skb_flow_dissector_target(flow_dissector,
>+						     FLOW_DISSECTOR_KEY_MPLS,
>+						     target_container);
>+		key_mpls->mpls_label = label;
>+		key_mpls->mpls_ttl = (entry & MPLS_LS_TTL_MASK)
>+					>> MPLS_LS_TTL_SHIFT;
>+		key_mpls->mpls_tc = (entry & MPLS_LS_TC_MASK)
>+					>> MPLS_LS_TC_SHIFT;
>+		key_mpls->mpls_bos = (entry & MPLS_LS_S_MASK)
>+					>> MPLS_LS_S_SHIFT;
>+	}
>+
>+	if (label == MPLS_LABEL_ENTROPY) {
> 		key_keyid = skb_flow_dissector_target(flow_dissector,
> 						      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
> 						      target_container);
>
