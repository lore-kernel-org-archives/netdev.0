From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC PATCH 03/12] xdp: add bpf_redirect helper function
Date: Tue, 11 Jul 2017 10:09:19 -0400
Message-ID: <CAHashqA8UYWAX7TDVrnGiTCA3zN5RGyiOQ3CcJpFDNnMemRnoQ@mail.gmail.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
 <20170707173522.9984.73677.stgit@john-Precision-Tower-5810>
 <8cf998a4-dadb-0a1a-0f3d-9a4f8ca39287@mellanox.com> <5963B81A.5070008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34970 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755627AbdGKOJp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 10:09:45 -0400
Received: by mail-qk0-f195.google.com with SMTP id 16so185232qkg.2
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 07:09:45 -0700 (PDT)
In-Reply-To: <5963B81A.5070008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 1:23 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 07/09/2017 06:37 AM, Saeed Mahameed wrote:
>>
>>
>> On 7/7/2017 8:35 PM, John Fastabend wrote:
>>> This adds support for a bpf_redirect helper function to the XDP
>>> infrastructure. For now this only supports redirecting to the egress
>>> path of a port.
>>>
>>> In order to support drivers handling a xdp_buff natively this patches
>>> uses a new ndo operation ndo_xdp_xmit() that takes pushes a xdp_buff
>>> to the specified device.
>>>
>>> If the program specifies either (a) an unknown device or (b) a device
>>> that does not support the operation a BPF warning is thrown and the
>>> XDP_ABORTED error code is returned.
>>>
>>> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
>>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>>> ---
>
> [...]
>
>>>
>>> +static int __bpf_tx_xdp(struct net_device *dev, struct xdp_buff *xdp)
>>> +{
>>> +    if (dev->netdev_ops->ndo_xdp_xmit) {
>>> +        dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
>>
>> Hi John,
>>
>> I have some concern here regarding synchronizing between the
>> redirecting device and the target device:
>>
>> if the target device's NAPI is also doing XDP_TX on the same XDP TX
>> ring which this NDO might be redirecting xdp packets into the same
>> ring, there would be a race accessing this ring resources (buffers
>> and descriptors). Maybe you addressed this issue in the device driver
>> implementation of this ndo or with some NAPI tricks/assumptions, I
>> guess we have the same issue for if you run the same program to
>> redirect traffic from multiple netdevices into one netdevice, how do
>> you synchronize accessing this TX ring ?
>
> The implementation uses a per cpu TX ring to resolve these races. And
> the pair of driver interface API calls, xdp_do_redirect() and xdp_do_flush_map()
> must be completed in a single poll() handler.
>
> This comment was included in the header file to document this,
>
> /* The pair of xdp_do_redirect and xdp_do_flush_map MUST be called in the
>  * same cpu context. Further for best results no more than a single map
>  * for the do_redirect/do_flush pair should be used. This limitation is
>  * because we only track one map and force a flush when the map changes.
>  * This does not appear to be a real limitation for existing software.
>  */
>
> In general some documentation about implementing XDP would probably be
> useful to add in Documentation/networking but this IMO goes beyond just
> this patch series.
>
>>
>> Maybe we need some clear guidelines in this ndo documentation stating
>> how to implement this ndo and what are the assumptions on those XDP
>> TX redirect rings or from which context this ndo can run.
>>
>> can you please elaborate.
>
> I think the best implementation is to use a per cpu TX ring as I did in
> this series. If your device is limited by the number of queues for some
> reason some other scheme would need to be devised. Unfortunately, the only
> thing I've come up for this case (using only this series) would both impact
> performance and make the code complex.
>
> A nice solution might be to constrain networking "tasks" to only a subset
> of cores. For 64+ core systems this might be a good idea. It would allow
> avoiding locking using per_cpu logic but also avoid networking consuming
> slices of every core in the system. As core count goes up I think we will
> eventually need to address this.I believe Eric was thinking along these
> lines with his netconf talk iirc. Obviously this work is way outside the
> scope of this series though.

I agree that it is outside the scope of this series, but I think it is
important to consider the impact of the output queue selection in both
a heterogenous and homogenous driver setup and how tx could be
optimized or even considered to be more reliable and I think that was
part of Saeed's point.

I got base redirect support for bnxt_en working yesterday, but for it
and other drivers that do not necessarily create a ring/queue per core
like ixgbe there is probably a bit more to work in each driver to
properly track output tx rings/queues than what you have done with
ixgbe.

>
>
>> Thanks,
>> Saeed.
>>
