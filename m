From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Wed, 6 Jan 2016 19:23:41 +0000
Message-ID: <568D69BD.6070504@solarflare.com>
References: <5672D466.6050900@solarflare.com>
 <CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
 <5673E2F6.2000209@solarflare.com>
 <CALx6S35n+dt-F6m3TvW6KfbDq883Uzvi_unduDgPcT2H-Cf7ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:23857 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751653AbcAFTYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 14:24:06 -0500
In-Reply-To: <CALx6S35n+dt-F6m3TvW6KfbDq883Uzvi_unduDgPcT2H-Cf7ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/12/15 19:41, Tom Herbert wrote:
> Drivers indicate that can do NETIF_F_IP[V6]_CSUM for encapsulation by
> setting enc_features. This is checked in validate_xmit_skb so that if
> drive can't handle encapsulated checksum skb_checksum_help is called
> there.
In that case, why is udp_set_csum ever looking at skb_dst(skb)->dev->features
 in the first place?  Shouldn't it just always set up checksum offload, and
 rely on it getting fixed up in validate_xmit_skb()?
> On Fri, Dec 18, 2015 at 2:41 AM, Edward Cree <ecree@solarflare.com> wrote:
>> On 17/12/15 18:06, Tom Herbert wrote:
>>> I'm not sure that we need bits in VXLAN or any other encapsulation. It
>>> should be sufficient in udp_set_csum that if we already have
>>> CHECKSUM_PARTIAL that can always be used to do local checksum offload.
>> My understandingis that otherwise iptunnel_handle_offloads() will do the
>>  inner checksum in sw, because csum_help will be passed as true.  It will
>>  call skb_checksum_help().
I'm beginning to think that csum_help should just go away, and all tunnels
 that have both inner and outer checksums should make sure they support LCO.
 I don't see any situation in which it should be necessary for
 iptunnel_handle_offloads to call skb_checksum_help, now that we never need
 to offload the outer checksum.
As far as I can tell from a quick LXR search, the protocols which sometimes
 pass csum_help as true are:
* FOU.  Calls udp_set_csum, so will get LCO support for free.
* GRE.  The GRE header has its own checksum, but it uses ones complement, so
 ip_gre.c:build_header needs to implement LCO.  Probably we want a helper
 function for LCO, that does everything except fill in the outer pseudo-
 header sum, which can then be called by both GRE and udp_set_csum.
* Geneve.  This goes through udp_tunnel_xmit_skb, so udp_set_csum gets
 called, so Geneve will get LCO support for free.
* VXLAN.  Like Geneve, goes through udp_tunnel_xmit_skb, so gets LCO support
 for free.
So, if we implement LCO for GRE, we can then drop the csum_help argument to
 iptunnel_handle_offloads() entirely, and act as though it's always false.
Also, of course, we need to do the same stuff for the IPv6 versions: add LCO
 to udp6_set_csum(), and to the IPv6-GRE implementation, which appears to be
 the call to ip_compute_csum() inside ip6gre_xmit2().  Although, it looks
 like IPv6-GRE has so little in common with other tunnel code, that simply
 leaving it as it is wouldn't break anything.  If anyone is actually *using*
 GRE over IPv6 (the spec explicitly says it doesn't cover IPv6) and wants
 the performance boost, they can implement LCO for it themselves :)
The only remaining problem is GSO: I haven't got quite as far yet with
 understanding that path.  But I don't _think_ implementing LCO for non-GSO
 will break GSO.  In which case we can get the non-GSO side working first,
 then try to implement the GSO version later.
> I don't think this right for skbuff.h that should just describe the
> interface. LCO has no interface like checksum-unnecessary conversion.
> Checksumming, encapsulation, segmentation offloads are complex enough
> now there should really be a Linux doc on this maybe modeled after
> scaling.txt. That's probably more than you bargained for in this
> patch, but if someone wants to learn how this infrastructure really
> works, writing a doc is a good way! :-)
I'm making some attempt to write a doc for checksumming and encapsulation.
 But I'd prefer to punt on segmentation because that's a whole other thing
 and I don't know any of the code yet - and I don't think it blocks any of
 the csum/encap work.  (Though that work will need to be done again for the
 segmentation offload path, I think.)  So I'll leave that bit for someone
 else to document ;)
Can I claim that canonically the only part of the TX stack that should look
 at the netdev offload features is validate_xmit_skb(), and everything else
 should just assume all features are supported?  (Like the udp_set_csum bit
 I started this email with.)  This would seem like the Right Thing, as it
 mirrors the new rule for device drivers that they should have sw fallbacks
 rather than trying to tell the stack exactly what they support.
Of course, that does include all the functions validate_xmit_skb() _calls_,
 which appears to include the entirety of GSO.  But like I say, I'm
 pretending GSO doesn't exist for now...

-Edward
