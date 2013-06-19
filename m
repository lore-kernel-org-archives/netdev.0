From: Jerry Chu <hkchu@google.com>
Subject: Re: qlen check in tun.c
Date: Wed, 19 Jun 2013 12:39:34 -0700
Message-ID: <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com>
References: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com>
	<51C12592.6050503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:55173 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964798Ab3FSTjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 15:39:36 -0400
Received: by mail-lb0-f178.google.com with SMTP id y6so4978226lbh.23
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 12:39:35 -0700 (PDT)
In-Reply-To: <51C12592.6050503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason,

On Tue, Jun 18, 2013 at 8:29 PM, Jason Wang <jasowang@redhat.com> wrote:
> On 06/19/2013 10:31 AM, Jerry Chu wrote:
>> In tun_net_xmit() the max qlen is computed as
>> dev->tx_queue_len / tun->numqueues. For multi-queue configuration the
>> latter may be way too small, forcing one to adjust txqueuelen based
>> on number of queues created. (Well the default txqueuelen of
>> 500/TUN_READQ_SIZE already seems too small even for single queue.)
>
> Hi Jerry:
>
> Do you have some test result of this? Anyway, tun allows userspace to
> adjust this value based on its requirement.

Sure, but the default size of 500 is just way too small. queue overflows even
with a simple single-stream throughput test through Openvswitch due to CPU
scheduler anomaly. On our loaded multi-stream test even 8192 can't prevent
queue overflow. But then with 8192 we'll be deep into the "buffer
bloat" territory.
We haven't figured out an optimal strategy for thruput vs latency, but
suffice to
say 500 is too small.

Jerry

>>
>> Wouldn't it be better to simply use dev->tx_queue_len to cap the qlen of
>> each queue? This also seems to be more consistent with h/w multi-queues.
>
> Make sense. Michael, any ideas on this?
>>
>> Also is there any objection to increase MAX_TAP_QUEUES from 8 to 16?
>> Yes it will take up more space in struct tun_struct. But we are
>> hitting the perf limit of 8 queues.
>
> Not only the tun_struct, another issue of this is sizeof(netdev_queue)
> which is 320 currently, if we use 16, it may be greater than 4096 which
> lead high order page allocation. Need a solution such as flex array or
> array of pointers.
>
> Btw, I have draft patch on both, will post as rfc.
>
> Thanks
>> Thanks,
>>
>> Jerry
>
