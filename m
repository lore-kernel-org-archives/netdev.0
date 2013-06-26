From: Jason Wang <jasowang@redhat.com>
Subject: Re: qlen check in tun.c
Date: Wed, 26 Jun 2013 13:23:03 +0800
Message-ID: <51CA7AB7.5030108@redhat.com>
References: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com> <51C12592.6050503@redhat.com> <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com> <20130620080725.GB23621@redhat.com> <CAPshTCie4T7ktq=wEoY3M9t=q2Zsujt2PvJ29tF1y+MJnKPujg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826Ab3FZFXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 01:23:17 -0400
In-Reply-To: <CAPshTCie4T7ktq=wEoY3M9t=q2Zsujt2PvJ29tF1y+MJnKPujg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2013 06:23 AM, Jerry Chu wrote:
> On Thu, Jun 20, 2013 at 1:07 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> On Wed, Jun 19, 2013 at 12:39:34PM -0700, Jerry Chu wrote:
>>> Hi Jason,
>>>
>>> On Tue, Jun 18, 2013 at 8:29 PM, Jason Wang <jasowang@redhat.com> wrote:
>>>> On 06/19/2013 10:31 AM, Jerry Chu wrote:
>>>>> In tun_net_xmit() the max qlen is computed as
>>>>> dev->tx_queue_len / tun->numqueues. For multi-queue configuration the
>>>>> latter may be way too small, forcing one to adjust txqueuelen based
>>>>> on number of queues created. (Well the default txqueuelen of
>>>>> 500/TUN_READQ_SIZE already seems too small even for single queue.)
>>>> Hi Jerry:
>>>>
>>>> Do you have some test result of this? Anyway, tun allows userspace to
>>>> adjust this value based on its requirement.
>>> Sure, but the default size of 500 is just way too small. queue overflows even
>>> with a simple single-stream throughput test through Openvswitch due to CPU
>>> scheduler anomaly. On our loaded multi-stream test even 8192 can't prevent
>>> queue overflow. But then with 8192 we'll be deep into the "buffer
>>> bloat" territory.
>>> We haven't figured out an optimal strategy for thruput vs latency, but
>>> suffice to
>>> say 500 is too small.
>>>
>>> Jerry
>> Maybe TSO is off for you?
>> With TSO you can get 64Kbyte packets, 500 of these is 30 Mbytes!
>> We really should consider setting byte limits, not packet limits.
> Sorry for the delay. TSO was on when I was seeing lots of pkts drops.
> But I realized the catch was GRO was off, which caused lots of MTU
> size pkts to pile up on the receive side overflowing the small tuntap
> queue.
>
> I just finished implementing GRE support in the GRO stack. When I
> turned it on, there were much less pkt drops. I do notice now the many
> acks triggered by the thruput tests will cause the tuntap queue to
> overflow.

Looks like you've modified tuntap codes since currently transmit GRE gso
packet were forbidden.
>
> In any case, with a large tx queue there should probably have some
> queue mgmt or BQL logic going with it.

It's not hard to do BQL for tuntap, but since it may cause packets to be
queued in qdisc which seems conflict with
5d097109257c03a71845729f8db6b5770c4bbedc (tun: only queue packets on
device) who just does the queuing in device.

Btw, I suspect this may be another reason to cause the packets to be
dropped in your case.

> Jerry
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
