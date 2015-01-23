From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Fri, 23 Jan 2015 08:58:44 -0800
Message-ID: <CA+mtBx_z3trTkK2qnVboXv7sJNjMHLr9V+4A=aFqyMo_0p1_Eg@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33578 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbbAWQ6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:58:45 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so2969927igb.2
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 08:58:45 -0800 (PST)
In-Reply-To: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 12:25 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch series adds support for Stateless Transport
> Tunneling protocol.
> STT uses TCP segmentation offload available in most of NIC. On
> packet xmit STT driver appends STT header along with TCP header
> to the packet. For GSO packet GSO parameters are set according
> to tunnel configuration and packet is handed over to networking
> stack. This allows use of segmentation offload available in NICs
>
> Netperf unidirectional test gives ~9.4 Gbits/s performance on 10Gbit
> NIC with 1500 byte MTU with two TCP streams.
>
The reason you're able to get 9.4 Gbit/s with an L2 encapsulation
using STT is that it has less protocol overhead per packet when doing
segmentation compared to VXLAN (without segmentation STT packets will
have more overhead than VXLAN).

A VXLAN packet with TCP/IP has headers
IP|UDP|VXLAN|Ethernet|IP|TCP+options. Assuming TCP is stuffed with
options, this is 20+8+8+16+20+40=112 bytes, or 7.4% MTU. Each STT
segment created in GSO, other than the first, has just IP|TCP headers
which is 20+20=40 bytes or 2.6% MTU. So this explains throughput
differences between VXLAN and STT.

With some clever coding, this same effect can be achieved using a UDP
encapsulation protocol that allows options. Suppose we create a new
option that we'll call Remote Segmentation Offload (RSO). The option
contains sequence number, fragment number that is coming from TCP
header in STT. We'll give this option eight bytes, and we'll also need
Remote Checksum Offload (therefore UDP checksum enabled). The headers
for each segment (except first) in GUE would then be something like
IP|UDP|GUE+options, with overhead  20+8+4+16 bytes=48 bytes, or 3.2%
MTU.

Like STT, RSO requires reassembly. Most of this can probably be done
in GRO. Processing is also a little cheaper since we don't need to
walk down as many protocol layers.

Conceptually, in the presence of packet loss we can recover any
segments as long as the first one in the chain that contains the full
set of headers isn't lost. If the first one is lost, then everything
in that block is lost since there's not enough context for reassembly
(I suspect this is also true in STT).

Tom

> The protocol is documented at
> http://www.ietf.org/archive/id/draft-davie-stt-06.txt
>
> I will send out OVS userspace patch on ovs-dev mailing list.
>
> Pravin B Shelar (3):
>   skbuff: Add skb_list_linearize()
>   net: Add STT tunneling protocol.
>   openvswitch: Add support for STT tunneling.
>
>  include/linux/skbuff.h           |    2 +
>  include/net/stt.h                |   55 ++
>  include/uapi/linux/openvswitch.h |    1 +
>  net/core/skbuff.c                |   35 +
>  net/ipv4/Kconfig                 |   11 +
>  net/ipv4/Makefile                |    1 +
>  net/ipv4/stt.c                   | 1386 ++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/Kconfig          |   10 +
>  net/openvswitch/Makefile         |    1 +
>  net/openvswitch/vport-stt.c      |  214 ++++++
>  10 files changed, 1716 insertions(+)
>  create mode 100644 include/net/stt.h
>  create mode 100644 net/ipv4/stt.c
>  create mode 100644 net/openvswitch/vport-stt.c
>
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
