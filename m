From: Christopher White <chris@logicalelegance.com>
Subject: Re: [PATCH net-next] LISP: Locator/Identifier Separation Protocol
Date: Fri, 30 May 2014 08:07:13 -0700
Message-ID: <312043C7-F7FE-4F59-BD80-7CFE35710D5A@logicalelegance.com>
References: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com> <CA+mtBx--drm2PLO5jrfN=6J-8OnAvaP6HefHo-Ck7EqH-d3scw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:48673 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbaE3PHQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 11:07:16 -0400
In-Reply-To: <CA+mtBx--drm2PLO5jrfN=6J-8OnAvaP6HefHo-Ck7EqH-d3scw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Tom, I will address these and resubmit. I assume vxlan has been updated already?

-Chris

On May 29, 2014, at 5:13 PM, Tom Herbert <therbert@google.com> wrote:

> On Thu, May 29, 2014 at 2:05 PM, Christopher White
> <chris@logicalelegance.com> wrote:
>> This is a static tunnel implementation of LISP as described in RFC 6830:
>>  http://tools.ietf.org/html/rfc6830
>> 
>> This driver provides point-to-point LISP dataplane
>> encapsulation/decapsulation for statically configured endpoints. It provides
>> support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are not
>> supported yet. Instance ID is supported on a per device basis.
>> 
> 
> Hi Chris,
> 
> Please look at my recent patches to standardize checksum handling for
> UDP tunnel implementations. This should also include configuration to
> enable UDP4 csums, as well as enabling zero csums in TX or RX for UDP6
> when you implement v6 support. Some more specific comments are inline.
> 
> Thanks,
> Tom
> 
>> +static int handle_offloads(struct sk_buff *skb)
>> +{
>> +       if (skb_is_gso(skb)) {
>> +               int err = skb_unclone(skb, GFP_ATOMIC);
>> +               if (unlikely(err))
>> +                       return err;
>> +
>> +               skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
>> +       } else if (skb->ip_summed != CHECKSUM_PARTIAL) {
>> +               skb->ip_summed = CHECKSUM_NONE;
>> +       }
>> +
>> +       return 0;
>> +}
>> +
> This should now just call iptunnel_handle_offloads with maybe setting
> type to be SKB_GSO_UDP_TUNNEL_CSUM. See vxlan.c and my patches to
> support UDP tunnels with csums.
> 
>> +       /* If the NIC driver gave us an encapsulated packet
>> +        * with the encapsulation mark, the device checksummed it
>> +        * for us. Otherwise force the upper layers to verify it.
>> +        */
>> +       if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
>> +           !skb->encapsulation)
>> +               skb->ip_summed = CHECKSUM_NONE;
>> +
> Checksum validation for UDP tunnels is now done in UDP so this should
> be unnecessary.
