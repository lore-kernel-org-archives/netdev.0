From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Fri, 10 Mar 2017 16:20:21 +0100
Message-ID: <20170310152020.GA15734@penelope.horms.nl>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
 <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
 <20170221152810.GE2694@nanopsycho.mtl.com>
 <20170310141912.GA5184@penelope.horms.nl>
 <20170310142732.GA1850@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34095 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932759AbdCJPU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 10:20:26 -0500
Received: by mail-wm0-f46.google.com with SMTP id 196so3701245wmm.1
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 07:20:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170310142732.GA1850@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 10, 2017 at 03:27:32PM +0100, Jiri Pirko wrote:
> Fri, Mar 10, 2017 at 03:19:13PM CET, simon.horman@netronome.com wrote:
> >On Tue, Feb 21, 2017 at 04:28:10PM +0100, Jiri Pirko wrote:
> >> Thu, Feb 02, 2017 at 11:37:34AM CET, simon.horman@netronome.com wrote:
> >> >Allow dissection of Neighbour Discovery target IP, and source and
> >> >destination link-layer addresses for neighbour solicitation and
> >> >advertisement messages.
> >> >
> >> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >> >---
> >> 
> >> [...]
> >> 
> >> >@@ -633,6 +702,18 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> >> > 						     FLOW_DISSECTOR_KEY_ICMP,
> >> > 						     target_container);
> >> > 		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
> >> >+
> >> >+		if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ND) &&
> >> >+		    ip_proto == IPPROTO_IPV6 && key_icmp->code == 0 &&
> >> 
> >> IPPROTO_IPV6 say "IPv6-in-IPv4 tunnelling". Please use "NEXTHDR_IPV6"
> >> instead.
> >
> >Thanks, will do.
> >
> >> >+		    (key_icmp->type == NDISC_NEIGHBOUR_SOLICITATION ||
> >> >+		     key_icmp->type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
> >> >+			key_nd = skb_flow_dissector_target(flow_dissector,
> >> >+							   FLOW_DISSECTOR_KEY_ND,
> >> >+							   target_container);
> >> >+			if (!(skb_flow_dissect_nd(skb, key_nd, data, nhoff,
> >> >+						  hlen, ipv6_payload_len)))
> >> >+				goto out_bad;
> >> >+		}
> >> 
> >> You should put this under "switch (ip_proto) {"
> >
> >I see that makes sense in terms of the check against ip_proto.
> >But I added it here to allow checking against key_icmp->code
> >and key_icmp->type as well.
> 
> Sure. Just add under "switch (ip_proto) {" and call a wrapper nd
> function from there. In that function, you check dissector_uses_key and
> other needed things.

Sorry, but I'm still a little unclear on how that interacts with
the dissection of key_icmp.
