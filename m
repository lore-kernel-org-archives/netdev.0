From: Tom Herbert <therbert@google.com>
Subject: Re: [net v2 2/3] i40e: Fix Rx checksum error counter
Date: Wed, 7 Jan 2015 13:34:32 -0800
Message-ID: <CA+mtBx_CXMyRkHhaMpWFuVo5OD=ejN=ZohidczXoC9w-1owaFQ@mail.gmail.com>
References: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1420594317-6191-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<CA+mtBx-VgUCCxnkayoqR6AwYXu_mfzbtGZzH+oeT3wrOznzWGg@mail.gmail.com>
	<C40BE8378EF49C44B9184714DBC8EF2992D9668D@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: "Singhai, Anjali" <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:51349 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755095AbbAGVec convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 16:34:32 -0500
Received: by mail-ig0-f178.google.com with SMTP id b16so2030166igk.5
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 13:34:32 -0800 (PST)
In-Reply-To: <C40BE8378EF49C44B9184714DBC8EF2992D9668D@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 12:14 PM, Singhai, Anjali
<anjali.singhai@intel.com> wrote:
> On Tue, 6 Jan 2015 21:43:57 -0800
> Tom Herbert <therbert@google.com> wrote:
>> > @@ -1337,15 +1335,19 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
>> >                                           skb->protocol == htons(ETH_P_8021AD))
>> >                                           ? VLAN_HLEN : 0;
>> >
>> > -               rx_udp_csum = udp_csum(skb);
>> > -               iph = ip_hdr(skb);
>> > -               csum = csum_tcpudp_magic(
>> > -                               iph->saddr, iph->daddr,
>> > -                               (skb->len - skb_transport_offset(skb)),
>> > -                               IPPROTO_UDP, rx_udp_csum);
>> > +               if ((ip_hdr(skb)->protocol == IPPROTO_UDP) &&
>> > +                   (udp_hdr(skb)->check != 0)) {
>> > +                       rx_udp_csum = udp_csum(skb);
>>
>> Doesn't this compute the whole checksum of the packet making the fact
>> that device verified inner checksum pretty much irrelevant? It would
>> probably be just as well to return CHECKSUM_NONE and let the stack
>> deal with it and remove all this complexity.
>
> This is only calculating outer UDP csum, inner csums are offloaded and so is the outer IP csum. Overall this is less work than asking the stack to do all of those by marking it as CHECKSUM_UNNECESSARY. We do have a patch in line to use csum_level but I believe even with that we would be asking the stack to do more work than necessary if we indicate that only inner checksums are offloaded. With our HW we are able to offload 3 out of 4 csums.

The stack will only compute the checksum over the packet zero or one
times. The fact that the driver is doing it instead of the stack makes
little difference, once the decision is made to checksum the packet
the performance gains of offloading are lost. If you defer to the
stack then this complex code is removed and there is the possibility
that the checksum doesn't even need to be calculated at all (like UDP
packet is bad or no listener for port).

What does "we are able to offload 3 out of 4 csums" mean?

Thanks,
Tom
