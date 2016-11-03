From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 22:34:34 +0100
Message-ID: <ce29c141-65d1-c1b2-dc45-a9752fb614d8@stressinduktion.org>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
 <20161103222751.5ae120ed@halley>
 <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, jtluka@redhat.com
To: Lance Richardson <lrichard@redhat.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36931 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752794AbcKCVei (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 17:34:38 -0400
In-Reply-To: <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.11.2016 22:05, Lance Richardson wrote:
>> From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
>> To: "Lance Richardson" <lrichard@redhat.com>, fw@strlen.de, hannes@stressinduktion.org
>> Cc: netdev@vger.kernel.org, jtluka@redhat.com
>> Sent: Thursday, November 3, 2016 4:27:51 PM
>> Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in ip_finish_output_gso()
>>
>> Hi Hannes, Lance,
>>
>> On Wed,  2 Nov 2016 16:36:17 -0400 Lance Richardson <lrichard@redhat.com>
>> wrote:
>>>  
>>> -	if (skb_iif && !(df & htons(IP_DF))) {
>>> -		/* Arrived from an ingress interface, got encapsulated, with
>>> -		 * fragmentation of encapulating frames allowed.
>>> -		 * If skb is gso, the resulting encapsulated network segments
>>> -		 * may exceed dst mtu.
>>> -		 * Allow IP Fragmentation of segments.
>>> -		 */
>>> -		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
>>> -	}
>>
>> Thinking this over, I'm concerned of this change.
>>
>> Few months back, we discussed this and got to the conclusion that in the
>> "ingress,tunnel,egress" scenario, segments are allowed to be
>> fragmented if the original inner ip packet does NOT have the DF.



>>
>> See
>>   https://patchwork.ozlabs.org/patch/657132/
>>   https://patchwork.ozlabs.org/patch/661219/
>>
>> I think you expressed that those tunneled skbs already having DF set
>> should go through pmtu discovery.
>>
>> Suggested patch unconditionally calls skb_gso_validate_mtu().
>>
>> Thus we're changing behavior for "ingress,tunnel,egress" scenario of
>> the tunneled packets having DF set in the inner iph.
>>
>> WDYT?
>>
> 
> I'm still digesting the patchwork history, but it seems to me:
> 
>    1) If we call skb_gso_validate_mtu() and it returns true, ip_finish_output2() will
>       be called, just as before, so nothing changes.
> 
>    2) If we were to avoid calling skb_gso_validate_mtu() when it would have returned
>       false and call ip_finish_output2() without performing fragmentation, we
>       would transmit (or attempt to transmit) a packet that exceeds the configured
>       MTU.
> 
>    3) If we do call skb_gso_validate_mtu() and it returns false, ip_finish_output_gso()
>       will call ip_fragment() to perform needed fragmentation. Whether fragmentation
>       actually occurs at this point depends on the value of the DF flag in the
>       IP header (and perhaps skb->ignore_df, frag_max_size, etc.).
> 
> Is the issue you're pointing out about cases in which the inner IP header has DF set
> but the tunnel header does not?

Correct, but we should maybe redefine the code a bit. From my
understanding we can now create an ICMP storm in case every fragment gets.

I think for net this is currently fine and we certainly don't want to
generate oversized datagrams.

I fear the more special case logic we add the sooner or later it will
bite us again. :/

Right now, I see the problem we might end up generating lots of error
callbacks for large gso segments. Maybe we can also just abort after
fragmenting the first frame generated an error. Florian? Or just
overoptimize and jump to the last one, which could have a different size. :)

Anyway, the best thing would be that vxlan etc. inherits the inner DF bit.

The problem to solve here is that for some time we generated oversized
packets on the wire, which is absolutely a no-go. If we now start to
break things for people with "wrong" configuration, we could also get
more complains. Currently I think this is the only way out, unfortunately.

Any other ideas?
