From: Yan Vugenfirer <yvugenfi@redhat.com>
Subject: Re: [PATCH net V2] vhost: net: switch to use data copy if pending DMAs exceed the limit
Date: Mon, 17 Mar 2014 19:21:18 +0200
Message-ID: <7ABD5D73-6C1B-423D-9B55-56B351933A86@redhat.com>
References: <1394170107-12018-1-git-send-email-jasowang@redhat.com> <20140310080310.GA754@redhat.com> <53215E22.8020207@redhat.com> <5326998A.6060003@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
        Dmitry Fleytman <dfleytma@redhat.com>, kvm@vger.kernel.org,
        virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Qin Chuanyu <qinchuanyu@huawei.com>
To: Ronen Hod <rhod@redhat.com>
Return-path: <virtio-dev-return-461-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
In-Reply-To: <5326998A.6060003@redhat.com>
List-Id: netdev.vger.kernel.org


On Mar 17, 2014, at 8:43 AM, Ronen Hod <rhod@redhat.com> wrote:

> On 03/13/2014 09:28 AM, Jason Wang wrote:
>> On 03/10/2014 04:03 PM, Michael S. Tsirkin wrote:
>>> On Fri, Mar 07, 2014 at 01:28:27PM +0800, Jason Wang wrote:
>>>>> We used to stop the handling of tx when the number of pending DMAs
>>>>> exceeds VHOST_MAX_PEND. This is used to reduce the memory occupation
>>>>> of both host and guest. But it was too aggressive in some cases, since
>>>>> any delay or blocking of a single packet may delay or block the guest
>>>>> transmission. Consider the following setup:
>>>>> 
>>>>>     +-----+        +-----+
>>>>>     | VM1 |        | VM2 |
>>>>>     +--+--+        +--+--+
>>>>>        |              |
>>>>>     +--+--+        +--+--+
>>>>>     | tap0|        | tap1|
>>>>>     +--+--+        +--+--+
>>>>>        |              |
>>>>>     pfifo_fast   htb(10Mbit/s)
>>>>>        |              |
>>>>>     +--+--------------+---+
>>>>>     |     bridge          |
>>>>>     +--+------------------+
>>>>>        |
>>>>>     pfifo_fast
>>>>>        |
>>>>>     +-----+
>>>>>     | eth0|(100Mbit/s)
>>>>>     +-----+
>>>>> 
>>>>> - start two VMs and connect them to a bridge
>>>>> - add an physical card (100Mbit/s) to that bridge
>>>>> - setup htb on tap1 and limit its throughput to 10Mbit/s
>>>>> - run two netperfs in the same time, one is from VM1 to VM2. Another is
>>>>>   from VM1 to an external host through eth0.
>>>>> - result shows that not only the VM1 to VM2 traffic were throttled but
>>>>>   also the VM1 to external host through eth0 is also throttled somehow.
>>>>> 
>>>>> This is because the delay added by htb may lead the delay the finish
>>>>> of DMAs and cause the pending DMAs for tap0 exceeds the limit
>>>>> (VHOST_MAX_PEND). In this case vhost stop handling tx request until
>>>>> htb send some packets. The problem here is all of the packets
>>>>> transmission were blocked even if it does not go to VM2.
>>>>> 
>>>>> We can solve this issue by relaxing it a little bit: switching to use
>>>>> data copy instead of stopping tx when the number of pending DMAs
>>>>> exceed half of the vq size. This is safe because:
>>>>> 
>>>>> - The number of pending DMAs were still limited (half of the vq size)
>>>>> - The out of order completion during mode switch can make sure that
>>>>>   most of the tx buffers were freed in time in guest.
>>>>> 
>>>>> So even if about 50% packets were delayed in zero-copy case, vhost
>>>>> could continue to do the transmission through data copy in this case.
>>>>> 
>>>>> Test result:
>>>>> 
>>>>> Before this patch:
>>>>> VM1 to VM2 throughput is 9.3Mbit/s
>>>>> VM1 to External throughput is 40Mbit/s
>>>>> CPU utilization is 7%
>>>>> 
>>>>> After this patch:
>>>>> VM1 to VM2 throughput is 9.3Mbit/s
>>>>> Vm1 to External throughput is 93Mbit/s
>>>>> CPU utilization is 16%
>>>>> 
>>>>> Completed performance test on 40gbe shows no obvious changes in both
>>>>> throughput and cpu utilization with this patch.
>>>>> 
>>>>> The patch only solve this issue when unlimited sndbuf. We still need a
>>>>> solution for limited sndbuf.
>>>>> 
>>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>>> Cc: Qin Chuanyu <qinchuanyu@huawei.com>
>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> I thought hard about this.
>>> Here's what worries me: if there are still head of line
>>> blocking issues lurking in the stack, they will still
>>> hurt guests such as windows which rely on timely
>>> completion of buffers, but it makes it
>>> that much harder to reproduce the problems with
>>> linux guests which don't.
>>> And this will make even it harder to figure out
>>> whether zero copy is actually active to diagnose
>>> high cpu utilization cases.
>> Yes.
>>> 
>>> So I think this is a good trick, but let's make
>>> this path conditional on a new debugging module parameter:
>>> how about head_of_line_blocking with default off?
>> Sure. But the head of line blocking was only partially solved in the
>> patch since we only support in-order completion of zerocopy packets.
>> Maybe we need consider switching to out of order completion even for
>> zerocopy skbs?
> 
> Yan, Dima,
> 
> I remember that there is an issue with out-of-order packets and WHQL.
The test considers out of order packets reception as a failure.

Yan.

> 
> Ronen.
> 
>>> This way if we suspect packets are delayed forever
>>> somewhere, we can enable that and see guest networking block.
>>> 
>>> Additionally, I think we should add a way to count zero copy
>>> and non zero copy packets.
>>> I see two ways to implement this: add tracepoints in vhost-net
>>> or add counters in tun accessible with ethtool.
>>> This can be a patch on top and does not have to block
>>> this one though.
>>> 
>> Yes, I post a RFC about 2 years ago, see
>> https://lkml.org/lkml/2012/4/9/478 which only traces generic vhost
>> behaviours. I can refresh this and add some -net specific tracepoints.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
