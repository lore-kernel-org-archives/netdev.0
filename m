From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH 5/5] virtio_net: XDP support for adjust_head
Date: Thu, 12 Jan 2017 15:26:56 -0800
Message-ID: <587810C0.6070507@gmail.com>
References: <20170112213919.3039.54165.stgit@john-Precision-Tower-5810>
 <20170112214519.3039.27879.stgit@john-Precision-Tower-5810>
 <20170113002221-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36596 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbdALX1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 18:27:09 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so5351314pfd.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 15:27:08 -0800 (PST)
In-Reply-To: <20170113002221-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-12 02:22 PM, Michael S. Tsirkin wrote:
> On Thu, Jan 12, 2017 at 01:45:19PM -0800, John Fastabend wrote:
>> Add support for XDP adjust head by allocating a 256B header region
>> that XDP programs can grow into. This is only enabled when a XDP
>> program is loaded.
>>
>> In order to ensure that we do not have to unwind queue headroom push
>> queue setup below bpf_prog_add. It reads better to do a prog ref
>> unwind vs another queue setup call.
>>
>> At the moment this code must do a full reset to ensure old buffers
>> without headroom on program add or with headroom on program removal
>> are not used incorrectly in the datapath. Ideally we would only
>> have to disable/enable the RX queues being updated but there is no
>> API to do this at the moment in virtio so use the big hammer. In
>> practice it is likely not that big of a problem as this will only
>> happen when XDP is enabled/disabled changing programs does not
>> require the reset. There is some risk that the driver may either
>> have an allocation failure or for some reason fail to correctly
>> negotiate with the underlying backend in this case the driver will
>> be left uninitialized. I have not seen this ever happen on my test
>> systems and for what its worth this same failure case can occur
>> from probe and other contexts in virtio framework.
> 
> Could you explain about this a bit more?
> Thanks!
> 

Sure. There are two existing paths and this patch adds a third one
where the driver basically goes through this reset path. First one
is on probe the other one is on the freeze/restore path.

The virtnet_freeze() path eventually free's the memory for rq/sq
(receive queues and send queues).

	virtnet_freeze()
		...
		remove_vq_common()
			...
			virtnet_dev_vqs()
				vdev->config->del_vqs()
				virtnet_free_queues <- this does a kfree


On virtnet_restore() path we then have to reallocate and reneg with
backend.

	virtnet_retore()
		...
		init_vqs()
			...
			virtnet_alloc_queues() <- alloc sq/rq
		virtnet_find_vqs()
			(allocates callbacks/names/vqs)

So the above allocs could fail and leave the device in a FAILED
state. This can happen today on probe or freeze/restore paths and
after this patch possibly on XDP load. Although as noted I have not
seen it happen in any of the above cases.

Second failure mode could happen if virtio_finalize_features() fails.
This seems unlikely because in order to probe successfully we had to
finalize the features successfully earlier. But it could I guess happen
based on return codes. Again never seen this actually happen. This is
called in probe case, freeze/restore case, and XDP now as well.

Does that help? Also I need to send a v2 to fix a spelling mistake and
to convert a 'unsigned' to 'unsigned int' per checkpatch warning. Always
better to run checkpatch before submitting vs after.

Thanks,
John
