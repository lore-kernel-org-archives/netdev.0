From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 17:05:54 -0400 (EDT)
Message-ID: <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com> <20161103222751.5ae120ed@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, hannes@stressinduktion.org, netdev@vger.kernel.org,
        jtluka@redhat.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:34360 "EHLO
        mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755881AbcKCVGH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 17:06:07 -0400
In-Reply-To: <20161103222751.5ae120ed@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
> To: "Lance Richardson" <lrichard@redhat.com>, fw@strlen.de, hannes@stressinduktion.org
> Cc: netdev@vger.kernel.org, jtluka@redhat.com
> Sent: Thursday, November 3, 2016 4:27:51 PM
> Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in ip_finish_output_gso()
> 
> Hi Hannes, Lance,
> 
> On Wed,  2 Nov 2016 16:36:17 -0400 Lance Richardson <lrichard@redhat.com>
> wrote:
> >  
> > -	if (skb_iif && !(df & htons(IP_DF))) {
> > -		/* Arrived from an ingress interface, got encapsulated, with
> > -		 * fragmentation of encapulating frames allowed.
> > -		 * If skb is gso, the resulting encapsulated network segments
> > -		 * may exceed dst mtu.
> > -		 * Allow IP Fragmentation of segments.
> > -		 */
> > -		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
> > -	}
> 
> Thinking this over, I'm concerned of this change.
> 
> Few months back, we discussed this and got to the conclusion that in the
> "ingress,tunnel,egress" scenario, segments are allowed to be
> fragmented if the original inner ip packet does NOT have the DF.
> 
> See
>   https://patchwork.ozlabs.org/patch/657132/
>   https://patchwork.ozlabs.org/patch/661219/
> 
> I think you expressed that those tunneled skbs already having DF set
> should go through pmtu discovery.
> 
> Suggested patch unconditionally calls skb_gso_validate_mtu().
> 
> Thus we're changing behavior for "ingress,tunnel,egress" scenario of
> the tunneled packets having DF set in the inner iph.
> 
> WDYT?
> 

I'm still digesting the patchwork history, but it seems to me:

   1) If we call skb_gso_validate_mtu() and it returns true, ip_finish_output2() will
      be called, just as before, so nothing changes.

   2) If we were to avoid calling skb_gso_validate_mtu() when it would have returned
      false and call ip_finish_output2() without performing fragmentation, we
      would transmit (or attempt to transmit) a packet that exceeds the configured
      MTU.

   3) If we do call skb_gso_validate_mtu() and it returns false, ip_finish_output_gso()
      will call ip_fragment() to perform needed fragmentation. Whether fragmentation
      actually occurs at this point depends on the value of the DF flag in the
      IP header (and perhaps skb->ignore_df, frag_max_size, etc.).

Is the issue you're pointing out about cases in which the inner IP header has DF set
but the tunnel header does not?

Thanks,

   Lance
