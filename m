From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 1/5] net: Add rx-vxlan feature bit
Date: Sat, 2 Aug 2014 11:16:32 -0700
Message-ID: <CAEP_g=-tHYAmLF1Mq6C1vHW6U_3+Pn_MXVU3C8v+zvF-RrfD0Q@mail.gmail.com>
References: <1406930085-26445-1-git-send-email-azhou@nicira.com>
 <1406930085-26445-2-git-send-email-azhou@nicira.com> <CA+mtBx8p-kx7O45fmMgR-DAz_xMSCW_hDdv80yT-RcxbxhZ0og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:42566 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754723AbaHBSQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 14:16:54 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so7139548qga.22
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2014 11:16:53 -0700 (PDT)
In-Reply-To: <CA+mtBx8p-kx7O45fmMgR-DAz_xMSCW_hDdv80yT-RcxbxhZ0og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 2, 2014 at 8:53 AM, Tom Herbert <therbert@google.com> wrote:
> On Fri, Aug 1, 2014 at 2:54 PM, Andy Zhou <azhou@nicira.com> wrote:
>> Add a ndo feature bit that controls turning on and off NIC VXLAN
>> receive offload
>>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>  Documentation/networking/netdev-features.txt     |    5 +++++
>>  drivers/net/ethernet/emulex/benet/be_main.c      |    6 ++++--
>>  drivers/net/ethernet/intel/i40e/i40e_main.c      |    1 +
>>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   11 ++++++++---
>>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    7 +++++--
>>  include/linux/netdev_features.h                  |    4 ++++
>>  net/core/ethtool.c                               |    1 +
>>  7 files changed, 28 insertions(+), 7 deletions(-)
>>
>> diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
>> index f310ede..6436768 100644
>> --- a/Documentation/networking/netdev-features.txt
>> +++ b/Documentation/networking/netdev-features.txt
>> @@ -165,3 +165,8 @@ This requests that the NIC receive all possible frames, including errored
>>  frames (such as bad FCS, etc).  This can be helpful when sniffing a link with
>>  bad packets on it.  Some NICs may receive more packets if also put into normal
>>  PROMISC mode.
>> +
>> +*   rx-vxlan
>> +NIC can parse udp tunneled frames. The NIC may make use of the inner frame
>> +information, in addition to the outer UDP frame to verify, offload(RX)
>> +and steer the packet.
>
> Sorry Andy, I still don't like this feature! I am worried that we are
> opening a can of worms in encouraging HW vendors to focus on narrow
> protocol specific features as opposed to general features that can be
> applied to a wider range of protocols.
>
> For UDP tunneling protocols where source port is set to a hash this
> should sufficient for the most common purposes of RSS and ECMP. This
> is precisely why we are interested in UDP encapsulation in the first
> place, existing NICs and switches support it. Any extra value in HW
> parsing VXLAN for steering is marginal (at least not a compelling
> reason for me run out and buy new NICs).
>
> This functionality might have merit for UDP flows where the source
> port cannot be arbitrary, like what would be needed to get the UDP
> flow to work over a stateful NAT. An example of this might be in QUIC.
> In the case the 5-tuple might not be sufficient the inner flow, but a
> device could conceivably parse the packet and use the QUIC connection
> identifier for flow identification and steering. However, if this
> becomes a real HW feature we would need a different interface anyway.
> QUIC is implemented in user space and to the kernel is just another
> UDP socket. The correct interface would probably be to configure the
> capability in ethtool, not through the UDP stack.

This actually is a patch against ethtool :)

I think this is probably getting somewhat ideological or at least use
case-specific. I understand your goal is to be generic where possible
but enough examples have come up in this discussion that it seems like
there shouldn't be much of an argument about whether this is useful at
this point. Things like the cost/benefit of buying a new NIC or how
QUIC would use it in the future seem a little beside the point,
honestly.

In any case, this specific patch is just about giving people the
ability to control VXLAN offloads, which I think should make you happy
given that it is already present in the stack and on by default. I
think Andy has done his best to take your comments into account to
make this as clean as possible and on the larger point we probably
just need to move on.
