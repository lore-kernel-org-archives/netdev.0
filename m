From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] net: limit maximum number of packets to mark with xmit_more
Date: Fri, 25 Aug 2017 15:33:48 -0700
Message-ID: <CAKgT0UdC_8hTbc-p6cQPNy4=gbFnodZ3ZyKts329Yu8kiv-ZWw@mail.gmail.com>
References: <20170825152449.29790-1-jacob.e.keller@intel.com>
 <E0D909EE5BB15A4699798539EA149D7F07793B3E@ORSMSX103.amr.corp.intel.com> <20170825085816.3425a70c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:38473 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934274AbdHYWdt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:33:49 -0400
Received: by mail-qk0-f196.google.com with SMTP id o63so1001156qkb.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 15:33:49 -0700 (PDT)
In-Reply-To: <20170825085816.3425a70c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 8:58 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 25 Aug 2017 15:36:22 +0000
> "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com> wrote:
>
>> On 8/25/17 11:25 AM, Jacob Keller wrote:
>> > Under some circumstances, such as with many stacked devices, it is
>> > possible that dev_hard_start_xmit will bundle many packets together, and
>> > mark them all with xmit_more.
>> >
>> > Most drivers respond to xmit_more by skipping tail bumps on packet
>> > rings, or similar behavior as long as xmit_more is set. This is
>> > a performance win since it means drivers can avoid notifying hardware of
>> > new packets repeat daily, and thus avoid wasting unnecessary PCIe or other
>> > bandwidth.
>> >
>> > This use of xmit_more comes with a trade off because bundling too many
>> > packets can increase latency of the Tx packets. To avoid this, we should
>> > limit the maximum number of packets with xmit_more.
>> >
>> > Driver authors could modify their drivers to check for some determined
>> > limit, but this requires all drivers to be modified in order to gain
>> > advantage.
>> >
>> > Instead, add a sysctl "xmit_more_max" which can be used to configure the
>> > maximum number of xmit_more skbs to send in a sequence. This ensures
>> > that all drivers benefit, and allows system administrators the option to
>> > tune the value to their environment.
>> >
>> > Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
>> > ---
>> >
>> > Stray thoughts and further questions....
>> >
>> > Is this the right approach? Did I miss any other places where we should
>> > limit? Does the limit make sense? Should it instead be a per-device
>> > tuning nob instead of a global? Is 32 a good default?
>>
>> I actually like the idea of a per-device knob.  A xmit_more_max that's
>> global in a system with 1GbE devices along with a 25/50GbE or more just
>> doesn't make much sense to me.  Or having heterogeneous vendor devices
>> in the same system that have different HW behaviors could mask issues
>> with latency.
>>
>> This seems like another incarnation of possible buffer-bloat if the max
>> is too high...
>>
>> >
>> >   Documentation/sysctl/net.txt |  6 ++++++
>> >   include/linux/netdevice.h    |  2 ++
>> >   net/core/dev.c               | 10 +++++++++-
>> >   net/core/sysctl_net_core.c   |  7 +++++++
>> >   4 files changed, 24 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
>> > index b67044a2575f..3d995e8f4448 100644
>> > --- a/Documentation/sysctl/net.txt
>> > +++ b/Documentation/sysctl/net.txt
>> > @@ -230,6 +230,12 @@ netdev_max_backlog
>> >   Maximum number  of  packets,  queued  on  the  INPUT  side, when the interface
>> >   receives packets faster than kernel can process them.
>> >
>> > +xmit_more_max
>> > +-------------
>> > +
>> > +Maximum number of packets in a row to mark with skb->xmit_more. A value of zero
>> > +indicates no limit.
>>
>> What defines "packet?"  MTU-sized packets, or payloads coming down from
>> the stack (e.g. TSO's)?
>
> xmit_more is only a hint to the device. The device driver should ignore it unless
> there are hardware advantages. The device driver is the place with HW specific
> knowledge (like 4 Tx descriptors is equivalent to one PCI transaction on this device).
>
> Anything that pushes that optimization out to the user is only useful for benchmarks
> and embedded devices.

Actually I think I might have an idea what is going on here and I
agree that this is probably something that needs to be fixed in the
drivers. Especially since the problem isn't so much the skbs but
descriptors in the descriptor ring.

If I am not mistaken the issue is most drivers will honor the
xmit_more unless the ring cannot enqueue another packet. The problem
is if the clean-up is occurring on a different CPU than transmit we
can cause the clean-up CPU/device DMA to go idle by not providing any
notifications to the device that new packets are present. What we
should probably do is look at adding another condition which is to
force us to flush the packet if we have used over half of the
descriptors in a given ring without notifying the device. Then that
way we can be filling half while the device is processing the other
half which should result in us operating smoothly.

- Alex
