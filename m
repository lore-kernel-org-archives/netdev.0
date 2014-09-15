From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Mon, 15 Sep 2014 12:15:26 -0700
Message-ID: <CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38357 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529AbaIOTP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:15:27 -0400
Received: by mail-ig0-f173.google.com with SMTP id l13so4509855iga.12
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 12:15:27 -0700 (PDT)
In-Reply-To: <CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 11:08 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
> [...]
>> * Notes
>>   - This patch set does not implement GSO for FOU. The UDP encapsulation
>>     code assumes TEB, so that will need to be reimplemented.
>
> Can you please clarify this point little further? Specifically, today
> few NICs are
> advertizing NETIF_F_GSO_UDP_TUNNEL when they are practically GSO
> capable only w.r.t to VXLAN. What happens when such NIC expose this
> cap and a large guest frame goes through GRE over UDP or alike tunneling?
>
My interpretation is that NETIF_F_GSO_UDP_TUNNEL means L3/L4
encapsulation over UDP, not VXLAN. If the NIC implements things
properly following the generic interface then I believe it should work
with various flavors of UDP encapsulation (FOU, GUE, VXLAN, VXLAN-gpe,
geneve, LISP, L2TP, nvgre, or whatever else people might dream up).
This presumes that any encapsulation headers doesn't require any per
segment update (so no GRE csum for instance). The stack will set up
inner headers as needed, which should enough to provide to devices the
offsets inner IP and TCP header which are needed for the the TSO
operation (outer IP and UDP can be deduced also).

>>   - I really don't expect/want devices to have special support for any
>>     of this. Generic checksum offload mechanisms (NETIF_HW_CSUM
>>     and use of CHECKSUM_COMPLETE) should be sufficient. RSS and flow
>>     steering is provided by commonly implemented UDP hashing. GRO/GSO
>>     seem fairly comparable with LRO/TSO already.
>
> Again, today NICs are advertizing checksum offloads capability in
> enc_hw_features but aren't capable to compute (say) the TCP checksum
> of the inner
> packet regardless of which actual tunneling is used (e.g VXLAN vs
> GRE), a bit inconsistent?

I doubt this is true of all NICs! For instance, a NIC that implements
NETIF_F_HW_CSUM should have no problem computing an encapsulated
checksums in just about any scenario. Both, checksum offload and TSO
can be supported for arbitrary flavors of UDP encapsulation if NICs
use protocol agnostic means as opposed to protocol specific means that
require a lot of parsing the packets themselves. Look at the long
standing comments in sk_buff about why protocol specific methods like
CHECKSUM_UNNECESSARY and NETIF_F_IP_CSUM are bad ideas. With the
emergence of encapsulation these are now *really* bad ideas!

If devices are interpreting NETIF_F_GSO_UDP_TUNNEL as VXLAN would
break when presented with any other flavor of UDP encapsulation, then
we should probably define NETIF_F_GSO_VXLAN_TUNNEL just for that case
to maintain backwards compatibility.
