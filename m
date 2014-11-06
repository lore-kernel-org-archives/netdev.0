From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net 0/5] Implement ndo_gso_check() for vxlan nics
Date: Thu, 6 Nov 2014 08:06:06 -0800
Message-ID: <CA+mtBx87o1Lo2zpMyUGC_P+7+DmXnZyA2NF0-GYCEWiRh6VJQg@mail.gmail.com>
References: <CAJ3xEMhxabp1EKbFPfvoZEFt=CQKFNcNrURGMX=7miDwmK9Y-A@mail.gmail.com>
	<20141105.163825.1433973842938441546.davem@davemloft.net>
	<20141106010501.GA18339@gmail.com>
	<20141105.211558.969082848816106943.davem@davemloft.net>
	<CA+mtBx-Js62X3BpfjQkcsh=w=-cgvSyM5ueCpufGVv0uu1nphw@mail.gmail.com>
	<CF9D1877D81D214CB0CA0669EFAE020C68CC79EF@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Joe Stringer <joestringer@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	dept-gelinuxnicdev <Dept-GELinuxNICDev@qlogic.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Sathya Perla <Sathya.Perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:49301 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKFQGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:06:07 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so3286280iec.3
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 08:06:06 -0800 (PST)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C68CC79EF@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The inner headers are reset in iptunnel_handle_offloads. This called
in the xmit encapsulation function (GRE, fou, VXLAN, etc.) before
added in encapsulation headers, so the inner headers will point to the
encapsulation payload, i.e. the encapsulated packet. The headers are
only on the first encapsulation, so with nested tunnels the inner
headers point to encapsulated packet. Since VXLAN and NVGRE have same
size of encapsulation (8 UDP + 8 header),   skb_inner_mac_header(skb)
- skb_transport_header(skb) should always be 16.


On Wed, Nov 5, 2014 at 10:16 PM, Sathya Perla <Sathya.Perla@emulex.com> wrote:
>> -----Original Message-----
>> From: Tom Herbert [mailto:therbert@google.com]
>>
>> On Wed, Nov 5, 2014 at 6:15 PM, David Miller <davem@davemloft.net>
>> wrote:
>> > From: Joe Stringer <joestringer@nicira.com>
>> > Date: Wed, 5 Nov 2014 17:06:46 -0800
>> >
>> >> My impression was that the changes are more likely to be
>> >> hardware-specific (like the i40e changes) rather than software-specific,
>> >> like changes that might be integrated into the helper.
>> >
>> > I think there is more commonality amongst hardware capabilities,
>> > and this is why I want the helper to play itself out.
>> >
>> >> That said, I can rework for one helper. The way I see it would be the
>> >> same code as these patches, as "vxlan_gso_check(struct sk_buff *)" in
>> >> drivers/net/vxlan.c which would be called from each driver. Is that what
>> >> you had in mind?
>> >
>> > Yes.
>>
>> Note that this code is not VXLAN specific, it will also accept NVGRE
>> and GRE/UDP with keyid and TEB. I imagine all these cases should be
>> indistinguishable to the hardware so they probably just work (which
>> would be cool!). It might be better to name and locate the helper
>> function to reflect that.
>
> Tom, I'm confused as to how the value of (skb_inner_mac_header(skb) - skb_transport_header(skb))
> would be the same for VxLAN and NVGRE encapsulated packets. Wouldn't this value be 16 for VxLAN
> and 8 for NVGRE?
>
The inner headers are reset in iptunnel_handle_offloads. This is
called in the xmit encapsulation functions (GRE, fou, VXLAN, etc.)
before adding in encapsulation headers (skb_push), so the
mac_inner_header will point to the encapsulation payload, i.e. the
encapsulated packet. This should not change after being set, although
inner network and inner transport can. The headers are only set on the
first encapsulation, so with nested tunnels the inner headers point to
the innermost encapsulated packet. Since VXLAN and NVGRE have same
size of encapsulation (8 UDP + 8 header),   skb_inner_mac_header(skb)
- skb_transport_header(skb) should always be 16.

Tom

> thks,
> -Sathya
