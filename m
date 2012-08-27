From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve fragmentation
 handling
Date: Mon, 27 Aug 2012 12:41:15 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208271238170.5279@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>    
 <1344542943-11588-6-git-send-email-kaber@trash.net>    <1345190795.3069.228.camel@localhost>
  <Pine.GSO.4.63.1208181423050.17600@stinky-local.trash.net>  
 <1345405069.3069.241.camel@localhost>   <Pine.GSO.4.63.1208192141570.3016@stinky-local.trash.net>
  <1345587697.3069.297.camel@localhost>  <Pine.GSO.4.63.1208262318550.16771@stinky-local.trash.net>
 <1346062428.3069.398.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346062428.3069.398.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Aug 2012, Jesper Dangaard Brouer wrote:

>>> When loading "nf_conntrack_ipv6" I run into issues.
>>>
>>> When sending a fragmented UDP packet.  With these patches, the IPVS
>>> stack will no longer see the fragmented packets, but instead see one
>>> large SKB.  This will trigger a MTU path check in e.g.
>>> ip_vs_dr_xmit_v6() and an ICMPv6 too big packet is send back.
>>>
>>>  IPVS: ip_vs_dr_xmit_v6(): frag needed
>>>
>>> Perhaps we could change/fix the MTU check in IPVS?
>>> (This would also solve issues I've seen with TSO/GSO frames, hitting
>>> this code path).
>>
>> I guess this should use the same check as in IPv6 output, check
>> whether IP6CB(skb)->max_frag_size is != 0 and > MTU and only send
>> an ICMPv6 error in that case.
>
> Hans have (already) proposed this solution:
>
>  if ((!skb->local_df && skb->len > mtu && !skb_is_gso(skb)) ||
>      (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)) {
>
> And I have tested it works.
> But I'm not sure about, if we really need the "!skb->local_df" check ?

Not necessarily, alternatively you could use:

if ((!IP6CB(skb)->frag_max_size &&
      (skb->len > mtu && !skb_is_gso(skb)) ||
     IP6CB(skb)->frag_max_size > mtu)

We just need to make sure that if frag_max_size is set that skb->len
is ignored. Either way is fine, but I'd suggest to keep it similar to
the variant used in IPv6.

> Thus, we should extend you patchset with a patch, that also address the
> MTU checks in IPVS.

Can you send over a patch for inclusion in the patchset? Besides this, its
ready for submission.
