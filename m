From: Jason Wang <jasowang@redhat.com>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Tue, 13 Dec 2016 11:43:00 +0800
Message-ID: <60cd312f-86f9-47e9-0c72-f4c2109e2f87@redhat.com>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <20161213042057-mutt-send-email-mst@kernel.org>
 <20161213031243.avq5g5m5r5ylcnnk@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, davem@davemloft.net
To: "Theodore Ts'o" <tytso@mit.edu>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41214 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932176AbcLMDnG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 22:43:06 -0500
In-Reply-To: <20161213031243.avq5g5m5r5ylcnnk@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年12月13日 11:12, Theodore Ts'o wrote:
> On Tue, Dec 13, 2016 at 04:28:17AM +0200, Michael S. Tsirkin wrote:
>> That's unfortunate, of course. It could be a hypervisor or
>> a guest kernel bug. ideas:
>> - does host have mq capability? how many queues?
>> - how about # of msix vectors?
>> - after you send something on tx queues,
>>    are interrupts arriving on rx queues?
>> - is problem rx or tx?
>>    set ip and arp manually and send a packet to known MAC,
>>    does it get there?
> Sorry, I don't know how to debug virtio-net.  Given that it's in a
> cloud environment, I also can't set ip addresses manually, since ip
> addresses are set manually.
>
> If you can send me a patch, I'm happy to apply it and send you back
> results.
>
> I can say that I've had _zero_ problems using pretty much any kernel
> from 3.10 to 4.9 using Google Compute Engine.  The commit I referenced
> caused things to stop working.  So in terms of regression, this is
> definitely a regression, and it's definitely caused by commit
> 449000102901.  Even if it is a hypervisor "bug", I'm pretty sure I
> know what Linus will say if I ask him to revert it.  Linux kernels are
> expected to work around hardware bugs, and breaking users just because
> hardware is "broken" by some definition is generally not considered
> friendly, especially when has been working for years and years before
> some commit "fixed" things.
>
> I would very much like to work with you to fix it, but I will need
> your help, since virtio-net doesn't seem to print any informational
> during the boot sequence, and I don't know how the best way to debug
> it.
>
> Cheers,
>
> 						- Ted

Thanks for reporting this issue. Looks like I blindly set the affinity 
instead of queues during probe. Could you please try the following patch 
to see if it works?

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b425fa1..fe9f772 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1930,7 +1930,9 @@ static int virtnet_probe(struct virtio_device *vdev)
                 goto free_unregister_netdev;
         }

-       virtnet_set_affinity(vi);
+       rtnl_lock();
+       virtnet_set_queues(vi, vi->curr_queue_pairs);
+       rtnl_unlock();

         /* Assume link up if device can't report link status,
            otherwise get link status from config. */
