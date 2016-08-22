From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Mon, 22 Aug 2016 16:51:35 +0200
Message-ID: <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        buytenh@wantstofly.org, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com, Pravin B Shelar <pshelar@nicira.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38832 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbcHVOvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:51:39 -0400
Received: by mail-wm0-f45.google.com with SMTP id o80so148605771wme.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 07:51:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 07:11:27AM -0600, David Ahern wrote:
> On 8/22/16 6:21 AM, Simon Horman wrote:
> >> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> >> index 1ecbd7715f6d..6d78f162a88b 100644
> >> --- a/net/openvswitch/actions.c
> >> +++ b/net/openvswitch/actions.c
> >> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >>  		skb->mac_len);
> >>  	skb_reset_mac_header(skb);
> >>  
> >> +	/* for GSO: set MPLS as network header and encapsulated protocol
> >> +	 * header as inner network header
> >> +	 */
> >> +	skb_set_network_header(skb, skb->mac_len);
> >> +	skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
> >> +
> >>  	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
> >>  	*new_mpls_lse = mpls->mpls_lse;
> > 
> > Is the above calculation correct if push_mpls() is called multiple times?
> > 
> 
> No. Does OVS support more than 1? I really need someone who is familiar with the OVS code to make sure it works for all use cases. e.g., set skb_set_inner_network_header() before pushing a series of MPLS labels.

Yes that is supported.

The scheme that OvS uses so far is that mac_len denotes the number of bytes
from the start of the MAC header until its end. In the absence of MPLS that
will be the beginning of the network header. And in the presence of MPLS it
will be the beginning of the MPLS label stack. The network header is... the
network header. This allows the MAC header, MPLS label stack and network
header to be tracked.

Pravin (CCed) may have different ideas but I wonder if the above scheme can
be preserved while also meeting the needs of your new MPLS GSO scheme if
you set skb_set_network_header() and skb_set_inner_network_header() in
net/openvswitch/actions.c:do_output().

It may also be possible to teach OvS to use skb_set_network_header to
denote the beginning of the MPLS LSE and skb_set_inner_network_header to
denote the network header in the presence of MPLS. Which is my current
understanding of what you are trying to achieve. But I think its likely
that I misunderstand things as it seems strange to me to pretend that an
MPLS LSE is a network header and the outer most network header is an inner
network header
