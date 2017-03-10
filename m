From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Fri, 10 Mar 2017 15:19:13 +0100
Message-ID: <20170310141912.GA5184@penelope.horms.nl>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
 <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
 <20170221152810.GE2694@nanopsycho.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38823 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933791AbdCJOTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 09:19:18 -0500
Received: by mail-wm0-f51.google.com with SMTP id t189so11667245wmt.1
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 06:19:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170221152810.GE2694@nanopsycho.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 04:28:10PM +0100, Jiri Pirko wrote:
> Thu, Feb 02, 2017 at 11:37:34AM CET, simon.horman@netronome.com wrote:
> >Allow dissection of Neighbour Discovery target IP, and source and
> >destination link-layer addresses for neighbour solicitation and
> >advertisement messages.
> >
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >---
> 
> [...]
> 
> >@@ -633,6 +702,18 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> > 						     FLOW_DISSECTOR_KEY_ICMP,
> > 						     target_container);
> > 		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
> >+
> >+		if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ND) &&
> >+		    ip_proto == IPPROTO_IPV6 && key_icmp->code == 0 &&
> 
> IPPROTO_IPV6 say "IPv6-in-IPv4 tunnelling". Please use "NEXTHDR_IPV6"
> instead.

Thanks, will do.

> >+		    (key_icmp->type == NDISC_NEIGHBOUR_SOLICITATION ||
> >+		     key_icmp->type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
> >+			key_nd = skb_flow_dissector_target(flow_dissector,
> >+							   FLOW_DISSECTOR_KEY_ND,
> >+							   target_container);
> >+			if (!(skb_flow_dissect_nd(skb, key_nd, data, nhoff,
> >+						  hlen, ipv6_payload_len)))
> >+				goto out_bad;
> >+		}
> 
> You should put this under "switch (ip_proto) {"

I see that makes sense in terms of the check against ip_proto.
But I added it here to allow checking against key_icmp->code
and key_icmp->type as well.
