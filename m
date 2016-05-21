From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: Missing INET6_PROTO_FINAL in l2tp_ip6_protocol?
Date: Sat, 21 May 2016 23:02:52 +0300
Message-ID: <20160521230252.27931eee@halley>
References: <20160521155003.1410579f@halley>
	<9bd1a821-17ea-778a-b0c7-4e9e35f9fcc1@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35610 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcEUUC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 16:02:58 -0400
Received: by mail-wm0-f51.google.com with SMTP id i142so25684456wmf.0
        for <netdev@vger.kernel.org>; Sat, 21 May 2016 13:02:58 -0700 (PDT)
In-Reply-To: <9bd1a821-17ea-778a-b0c7-4e9e35f9fcc1@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 May 2016 17:55:59 +0200 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On 21.05.2016 14:50, Shmulik Ladkani wrote:
> > Hi,
> > 
> > inet6_protocol's INET6_PROTO_FINAL flag denotes handler is expected not
> > to request resubmission for local delivery.
> > 
> > For an INET6_PROTO_FINAL handler, the following actions gets executed
> > prior delivery, in ip6_input_finish:
> > 
> > 			nf_reset(skb);
> > 
> > 			skb_postpull_rcsum(skb, skb_network_header(skb),
> > 					   skb_network_header_len(skb));
> > 
> > For some reason, l2tp_ip6_protocol handler is NOT marked as
> > INET6_PROTO_FINAL. Probably an oversight.
> > 
> > Since 'l2tp_ip6_recv' never results in a resubmission, the above actions
> > are not applied to skbs passed to l2tp_ip6.
> > 
> > Any reason why l2tp_ip6_protocol should NOT be marked INET6_PROTO_FINAL?  
> 
> I don't see any specific reason why it shouldn't be a INET6_PROTO_FINAL.
> Anyway, receive path of L2TPv3 without UDP encapsulation doesn't deal
> with checksums anyway, as far as I know.
> 
> > What's the consequences not executing the above actions for l2tp_ip6
> > packets?  
> 
> Probably not a whole lot in this case.

OK, so the skb_postpull_rcsum is irrelevant for IPPROTO_L2TP over ipv6.

However, one more thing WRT to INET6_PROTO_FINAL not being set - we're
also missing the multicast filtering of 'ip6_input_finish':

			if (ipv6_addr_is_multicast(&hdr->daddr) &&
			    !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,
			    &hdr->saddr) &&
			    !ipv6_is_mld(skb, nexthdr, skb_network_header_len(skb)))
				goto discard;

I assume no reason to allow multicast daddr which aren't in the mc_list
(or saddr excluded) to pass up into 'l2tp_ip6_recv'?
