From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: virtio-net: tx queue was stopped
Date: Sun, 15 Mar 2015 09:40:52 +0100
Message-ID: <20150315080138-mutt-send-email-mst@redhat.com>
References: <55052BB3.2080705@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lilijun <jerry.lilijun@huawei.com>,
	"liuyongan@huawei.com" <liuyongan@huawei.com>,
	"lixiao (H)" <lixiao91@huawei.com>,
	virtualization@lists.linux-foundation.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Linhaifeng <haifeng.lin@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296AbbCOIkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2015 04:40:55 -0400
Content-Disposition: inline
In-Reply-To: <55052BB3.2080705@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 02:50:27PM +0800, Linhaifeng wrote:
> Hi,Michael
> 
> I had tested the start_xmit function by the follow code found that the tx queue's state is stopped and can't send any packets anymore.

Why don't you Cc all maintainers on this email?
Pls check the file MAINTAINERS for the full list.
I added Cc for now.

> 
> static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> {
> 	... ...
> 
> 
>         capacity = 10;	//########## test code : force to call netif_stop_queue
> 
>         if (capacity < 2+MAX_SKB_FRAGS) {
>                 netif_stop_queue(dev);

So you changed code to make it think we are out of capacity, now it
stops the queue.

> 
>                 if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
>                         /* More just got used, free them then recheck. */
>                         capacity += free_old_xmit_skbs(vi);
>                         dev_warn(&dev->dev, "free_old_xmit_skbs capacity =%d MAX_SKB_FRAGS=%d", capacity, MAX_SKB_FRAGS);
> 
>                         capacity = 10;		//########## test code : force not to call  netif_start_queue
> 
>                         if (capacity >= 2+MAX_SKB_FRAGS) {
>                                 netif_start_queue(dev);
>                                 virtqueue_disable_cb(vi->svq);
>                         } else {
> 				//########## OTOH if often enter this branch tx queue maybe stopped.
> 			}

and changed it here so it won't restart queue if host consumed
all buffers.
unsurprisingly this makes driver not work.


> 			
>                 }
> 
> 		//########## Should we start queue here? I found that sometimes skb_xmit_done run before netif_stop_queue if this occurred the queue's state is
> 		//########## stopped and have to reload virtio-net module to restore network.

With or without your changes?
Is this the condition you describe?


        if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {

---> at this point, skb_xmit_done runs. this does:
        /* Suppress further interrupts. */
        virtqueue_disable_cb(vq);

        /* We were probably waiting for more output buffers. */
        netif_wake_subqueue(vi->dev, vq2txq(vq));
--->



                netif_stop_subqueue(dev, qnum);

---> queue is now stopped

                if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {

----> this re-enables interrupts, after an interrupt skb_xmit_done
	will run again.

                        /* More just got used, free them then recheck.
 * */
                        free_old_xmit_skbs(sq);
                        if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
                                netif_start_subqueue(dev, qnum);
                                virtqueue_disable_cb(sq->vq);
                        }
                }
        }


I can't see a race condition from your description above.

>         }
> 	
> }
> 
> ping 9.62.1.2 -i 0.1
> 64 bytes from 9.62.1.2: icmp_seq=19 ttl=64 time=0.115 ms
> 64 bytes from 9.62.1.2: icmp_seq=20 ttl=64 time=0.101 ms
> 64 bytes from 9.62.1.2: icmp_seq=21 ttl=64 time=0.094 ms
> 64 bytes from 9.62.1.2: icmp_seq=22 ttl=64 time=0.098 ms
> 64 bytes from 9.62.1.2: icmp_seq=23 ttl=64 time=0.097 ms
> 64 bytes from 9.62.1.2: icmp_seq=24 ttl=64 time=0.095 ms
> 64 bytes from 9.62.1.2: icmp_seq=25 ttl=64 time=0.095 ms
> ....
> ping:  sendmsg:  No buffer space available
> ping:  sendmsg:  No buffer space available
> ping:  sendmsg:  No buffer space available
> ping:  sendmsg:  No buffer space available
> ping:  sendmsg:  No buffer space available
> ping:  sendmsg:  No buffer space available
> ....
> 
> -- 
> Regards,
> Haifeng

I can't say what does your code-changing experiment show.
It might be better to introduce delay by calling something like
cpu_relax at specific points (maybe multiple times in a loop).

-- 
MST
