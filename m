From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v3 0/3] virtio_net: enabling tx interrupts
Date: Tue, 02 Dec 2014 03:44:55 +0008
Message-ID: <1417491415.4405.3@smtp.corp.redhat.com>
References: <1413787824-16130-1-git-send-email-mst@redhat.com>
	<547C3F8C.8000006@redhat.com> <20141201104808.GA16661@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141201104808.GA16661@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, Dec 1, 2014 at 6:48 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> On Mon, Dec 01, 2014 at 06:14:36PM +0800, Jason Wang wrote:
>>  
>>  
>>  On 10/20/2014 02:52 PM, Michael S. Tsirkin wrote:
>>  >RFC patches to enable tx interrupts.
>>  >This is to demonstrate how this can be done without
>>  >core virtio changes, and to make sure I understand
>>  >the new APIs correctly.
>>  >
>>  >Testing TBD, I was asked for a version for early testing.
>>  >
>>  >Applies on top of patch: "virtio_net: fix use after free"
>>  >that I recently sent.
>>  >
>>  >Changes from v3:
>>  >	clean up code, address issues raised by Jason
>>  >Changes from v1:
>>  >         address comments by Jason Wang, use delayed cb everywhere
>>  >         rebased Jason's patch on top of mine and include it (with 
>> some tweaks)
>>  >
>>  >Jason Wang (1):
>>  >   virtio-net: optimize free_old_xmit_skbs stats
>>  >
>>  >Michael S. Tsirkin (2):
>>  >   virtio_net: enable tx interrupt
>>  >   virtio_net: bql
>>  >
>>  >  drivers/net/virtio_net.c | 144 
>> +++++++++++++++++++++++++++++++++--------------
>>  >  1 file changed, 101 insertions(+), 43 deletions(-)
>>  >
>>  
>>  I've run a full tests on this series and see huge regression when 
>> zerocopy
>>  is disabled. Looks like the reason is zerocopy could coalescing tx
>>  completion which greatly reduce the number of tx interrupts.
> 
> I think you refer to this code:
> 
>         /*
>          * Trigger polling thread if guest stopped submitting new
>          * buffers:
>          * in this case, the refcount after decrement will eventually
>          * reach 1.
>          * We also trigger polling periodically after each 16 packets
>          * (the value 16 here is more or less arbitrary, it's tuned to
>          * trigger
>          * less than 10% of times).
>          */
>         if (cnt <= 1 || !(cnt % 16))
>                 vhost_poll_queue(&vq->poll);
> 
> ?
> This seems unrelated to interrupt coalescing.

Well, this in fact tries to coalesce 16 packets per tx irq.

More important, zerocopy depends on host nics tx completion.
This means, if host nic coalesces several packets per irq,
zerocopy will probably also do this. vhost_zerocopy_signal_used()
will try to coalesce the tx intrs.
> 
> We can easily enable something similar for all tx
> packets, without need for guest configuration.

We can, but we lose the an interface for user to tune for 
their applications.
> 
> If it's not clear how to do this, let me know, I'll try to put out a
> patch like this in a couple of days.

We can just do this through harding coding the tx-frames to 16 
through interrupt coalescing. I don't see obvious differences.
And in my test of RFCv4, I just use tx-frames 16 to get the result.

Without a timer for coalescing, I suspect how much this can help
for e.g 1 session of TCP_RR. It just has at most 1 packet pending
during the test. So in fact no tx completion could be coalesced 
in this case.
> 
> 
>>  I will post RFC V4 shortly with interrupt coalescing support. In 
>> this
>>  version I remove the tx packet cleanup in ndo_start_xmit() since it 
>> may
>>  reduce the effects of interrupt coalescing.
> 
> Maybe split this in a separate patch?

I can, but since just two minor changes compared to V3. Maybe just
document the differences is ok for you?
