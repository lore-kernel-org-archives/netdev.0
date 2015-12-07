From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Mon, 7 Dec 2015 09:52:31 -0800
Message-ID: <CALx6S35EU0G2dBdKPgjEv22qNTOs8ieYYUoP6ABHV1Evb48pCA@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34420 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbbLGRwc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:52:32 -0500
Received: by igvg19 with SMTP id g19so84058260igv.1
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 09:52:32 -0800 (PST)
In-Reply-To: <CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2015 at 9:29 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Dec 7, 2015 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>> Having decided to take Dave Miller's advice to push our hardware guys in the direction of generic checksum offload, I found I wasn't quite sure exactly what's being encouraged.  After discussing the subject with a colleague, some questions crystallised.  I expect it's mostly a result of misunderstandings on my part, but here goes:
>>
>
> Hi Edward, thanks for looking into this.
>
>> 1) Receive checksums.  Given that CHECKSUM_UNNECESSARY conversion exists (and is a cheap operation), what is the advantage to the stack of using CHECKSUM_COMPLETE if the packet happens to be a protocol which CHECKSUM_UNNECESSARY conversion can handle?  As I see it, CHECKSUM_UNNECESSARY is strictly better as the stack is told "the first csum_level+1 checksums are good" *and* (indirectly) "here is the whole-packet checksum, which you can use to help with anything beyond csum_level+1".  Is it not, then, best for a device only to use CHECKSUM_COMPLETE for protocols the conversion doesn't handle?  (I agree that having that fallback of CHECKSUM_COMPLETE is a good thing, sadly I don't think our new chip does that.  (But maybe firmware can fix it.))
>>
> Checksum unnecessary conversion works great but it's applicability is
> limited. This only helps in encapsulation when the UDP checksum can be
> enabled, but due to restrictions of other devices we may need to
> communicate with (e.g. Cisco switches) it might not be usable. Also,
> checksum conversion is not relevant to many other protocols we want to
> run like GRE, IPIP, SIT, MPLS/IP, etc., and does not help with IPv6
> extension headers. CHECKSUM_COMPLETE is the really closet thing to a
> universal solution.
>
>> 2) Transmit checksums.  While many protocols permit using 0 in the outer checksum, it doesn't seem prudent to assume all will.  Besides, many NICs will still have IP and TCP/UDP checksum offload hardware, if only to support less enlightened operating systems; why not use it?  Would it not be better for a device to have both NETIF_F_HW_CSUM *and* NETIF_F_IP[|V6]_CSUM, and be smart enough to fill in IP checksum, TCP/UDP checksum and one encapsulated checksum of your choice (i.e. whatever csum_start and friends asked for)?  (Again, I agree that having a NETIF_F_IP_CSUM device do specific magic for a list of specific encapsulation protocols is unsatisfactory.  Sadly, guess what our new chip does!  (But maybe firmware can fix it.))
>>
> It's analogous to CHECKSUM_COMPLETE, NETIF_F_HW_CSUM works for all
> cases of checksum offload and any combination of protocol layering.
> NETIF_F_IP[V6]_CSUM is limited and requires a lot of logic in both
> driver and HW to implement correctly. I can't help you with these less
> enlightening operating systems, maybe if they see the advantages of a
> protocol generic offload model they'll "get with the program" as Dave
> might say? In any case I do not believe we should be at all
> constrained in building Linux interfaces or capabilities by the design
> decisions made in other operating systems.
>
>> 3) Related to the above, what does a NETIF_F_HW_CSUM device do when transmitting an unencapsulated packet (let's say it's UDP) currently?  Will it simply get no checksum offload at all?  Will csum_start point at the regular UDP checksum (and the stack will do the IP header checksum)?  Again, a device that does both HW_ and IP_CSUM could cope with this (do the IP and UDP checksums as per NETIF_F_IP_CSUM, and just don't ask for a 'generic' HW_CSUM), though that would require more checksum flags (there's no way for CHECKSUM_PARTIAL to say "do your IP-specific stuff but ignore csum_start and friends).
>>
> The NETIF_F_*_CSUM flags only describe the capabilities of the device,
> the interface between the stack and the driver to offload the checksum
> of a particular packet is solely the csum_start and csum_offset fields
> in the skb (non-GSO case). It is up to the driver to decide whether
> the particular checksum can actually be offloaded, but in any case it
> must set the correct checksum (through skb_checksum_help if
> necessary).
>
>> 4) Where, precisely, should I tell our hardware guys to stuff the protocol-specific encapsulated checksum offloads they're so proud of having added to our new chip? ;)
>
> Tell them that if the support generic checksum you're marketing guys
> will be able to list at least fifteen protocols in the product specs
> that can be checksum offloaded to the device instead of just one or
> two like the competition ;-)
>

Here is a list of protocols I came up with that you could claim are
supported for checksum offload with protocol generic mechanisms:

VXLAN
VXLAN-GPE
GUE
Geneve
GRE (over IP or UDP)
MPLS (over IP or UDP)
IPIP
SIT
L2TP (over IP or UDP)
GTP
NVGRE
DCCP
LISP
IPv6 extension headers
PPPoE
ICMP

You mostly can double this list if you want to by list each protocol
individually as being supported for both IPv4 and IPv6.

> Thanks,
> Tom
> .
>>
>> --
>> Edward Cree, not speaking for Solarflare Communications
>> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
