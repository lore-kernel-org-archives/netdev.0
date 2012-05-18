From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Fri, 18 May 2012 17:58:47 +0800
Message-ID: <4FB61D57.4030103@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>  <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com>  <1337100630.8220.4.camel@oc3660625478.ibm.com> <4FB317C8.90002@redhat.com>  <1337181027.10741.13.camel@oc3660625478.ibm.com>  <20120516151444.GC9934@redhat.com>  <1337189525.10741.24.camel@oc3660625478.ibm.com>  <4FB4677A.8020402@redhat.com> <1337268862.10741.58.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337268862.10741.58.camel@oc3660625478.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2012 11:34 PM, Shirley Ma wrote:
> On Thu, 2012-05-17 at 10:50 +0800, Jason Wang wrote:
>> The problem is we may stop the tx queue when there no enough capacity
>> to
>> place packets, at this moment  we depends on the tx interrupt to
>> re-enable the tx queue. So if we didn't poll the vhost during
>> callback,
>> guest may lose the tx interrupt to re-enable the tx queue which could
>> stall the whole tx queue.
> VHOST_MAX_PEND should handle the capacity.
>
> Hasn't the above situation been handled in handle_tx() code?:
> ...
>                          if (unlikely(num_pends>  VHOST_MAX_PEND)) {
>                                  tx_poll_start(net, sock);
>                                  set_bit(SOCK_ASYNC_NOSPACE,&sock->flags);
>                                  break;
>                          }
> ...
>
> Thanks
> Shirley

It may not help in because:

- tx polling depends on skb_orphan() which is often called by device 
driver when it place the packet into the queue of the devices instead 
of  when the packets were sent. So it was too early for vhost to be 
notified.

- it only works when the pending DMAs exceeds VHOST_MAX_PEND, it's 
highly possible that guest needs to be notified when the pending packets 
isn't so much.

So this piece of code may not help and could be removed and we need to 
poll the virt-queue during zerocopy callback ( through it could be 
further optimized but may not be easy).
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
