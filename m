From: Steven Galgano <sgalgano@adjacentlink.com>
Subject: Re: [PATCH] tuntap: add flow control to support back pressure
Date: Thu, 10 Apr 2014 21:42:19 -0400
Message-ID: <5347487B.4040608@adjacentlink.com>
References: <5345FFBC.7020502@adjacentlink.com> <20140410102931.GA12077@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jasowang@redhat.com, xemul@parallels.com,
	wuzhy@linux.vnet.ibm.com, therbert@google.com, yamato@redhat.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Brian Adamson <Brian.Adamson@nrl.navy.mil>,
	Joseph Giovatto <jgiovatto@adjacentlink.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140410102931.GA12077@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2014 06:29 AM, Michael S. Tsirkin wrote:
> On Wed, Apr 09, 2014 at 10:19:40PM -0400, Steven Galgano wrote:
>> Add tuntap flow control support for use by back pressure routing protocols. Setting the new TUNSETIFF flag IFF_FLOW_CONTROL, will signal resources as unavailable when the tx queue limit is reached by issuing a netif_tx_stop_all_queues() rather than discarding frames. A netif_tx_wake_all_queues() is issued after reading a frame from the queue to signal resource availability.
>>
>> Back pressure capability was previously supported by the legacy tun default mode. This change restores that functionality, which was last present in v3.7.
>>
>> Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
>> Tested-by: Joseph Giovatto <jgiovatto@adjacentlink.com>
>> Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
> 
> I don't think it's a good idea.
> 
> This trivial flow control really created more problems than it was worth.
> 
> In particular this blocks all flows so it's trivially easy for one flow
> to block and starve all others: just send a bunch of packets to loopback
> destinations that get queued all over the place.
> 
> Luckily it was never documented so we changed the default and nothing
> seems to break, but we won't be so lucky if we add an explicit API.
> 
> 
> One way to implement this would be with ubuf_info callback this is
> already invoked in most places where a packet might get stuck for a long
> time.  It's still incomplete though: this will prevent head of queue
> blocking literally forever, but a single bad flow can still degrade
> performance significantly.
> 
> Another alternative is to try and isolate the flows that we
> can handle and throttle them.
> 
> It's all fixable but we really need to fix the issues *before*
> exposing the interface to userspace.
> 
> 
> 

It was only after recent upgrades that we picked up a newer kernel and
discovered the change to the default tun mode.

The new default behavior has broken applications that depend on the
legacy behavior. Although not documented, the legacy behavior was well
known at least to those working in the back pressure research community.
The default legacy mode was/is a valid use case although I am not sure
it fits with recent multiqueue support.

When back pressure protocols are running over a tun interface they
require legacy flow control in order to communicate congestion detected
on the physical media they are using. Multiqueues do not apply here.
These protocols only use one queue, so netif_tx_stop_all_queues() is the
necessary behavior.

I'm not tied to the idea of IFF_FLOW_CONTROL. I was aiming for middle
ground where an application controlling the tun interface can state it
wants the legacy flow control behavior understanding its limitations
concerning multiple queues.

What if we resurrect IFF_ONE_QUEUE and use that as a mechanism to
indicate legacy flow control. A tun instance initially configured with
IFF_ONE_QUEUE would not be allowed to attach or detach queues with
TUNSETQUEUE and any additional opens with the same device name would
fail. This mode would use the
netif_tx_stop_all_queues()/netif_tx_wake_all_queues() flow control
mechanism.

If a tun application wants the current default behavior with only a
single queue, it would not set the IFF_ONE_QUEUE flag. Not setting
IFF_MULTI_QUEUE would not imply IFF_ONE_QUEUE.

I'd be happy to implement this change if it is an acceptable solution.
This would allow multiqueue tun development to advance while still
supporting use cases dependent on legacy flow control.

-steve

>> ---
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index ee328ba..268130c 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -783,8 +783,19 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	 * number of queues.
>>  	 */
>>  	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
>> -			  >= dev->tx_queue_len)
>> -		goto drop;
>> +			>= dev->tx_queue_len) {
>> +		if (tun->flags & TUN_FLOW_CONTROL) {
>> +			/* Resources unavailable stop transmissions */
>> +			netif_tx_stop_all_queues(dev);
>> +
>> +			/* We won't see all dropped packets individually, so
>> +			 * over run error is more appropriate.
>> +			 */
>> +			dev->stats.tx_fifo_errors++;
>> +		} else {
>> +			goto drop;
>> +		}
>> +	}
>>  
>>  	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>>  		goto drop;
>> @@ -1362,6 +1373,9 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
>>  			continue;
>>  		}
>>  
>> +		/* Wake in case resources previously signaled unavailable */
>> +		netif_tx_wake_all_queues(tun->dev);
>> +
>>  		ret = tun_put_user(tun, tfile, skb, iv, len);
>>  		kfree_skb(skb);
>>  		break;
>> @@ -1550,6 +1564,9 @@ static int tun_flags(struct tun_struct *tun)
>>  	if (tun->flags & TUN_PERSIST)
>>  		flags |= IFF_PERSIST;
>>  
>> +	if (tun->flags & TUN_FLOW_CONTROL)
>> +		flags |= IFF_FLOW_CONTROL;
>> +
>>  	return flags;
>>  }
>>  
>> @@ -1732,6 +1749,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>  	else
>>  		tun->flags &= ~TUN_TAP_MQ;
>>  
>> +	if (ifr->ifr_flags & IFF_FLOW_CONTROL)
>> +		tun->flags |= TUN_FLOW_CONTROL;
>> +	else
>> +		tun->flags &= ~TUN_FLOW_CONTROL;
>> +
>>  	/* Make sure persistent devices do not get stuck in
>>  	 * xoff state.
>>  	 */
>> @@ -1900,7 +1922,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>  		 * This is needed because we never checked for invalid flags on
>>  		 * TUNSETIFF. */
>>  		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
>> -				IFF_VNET_HDR | IFF_MULTI_QUEUE,
>> +				IFF_VNET_HDR | IFF_MULTI_QUEUE |
>> +				IFF_FLOW_CONTROL,
>>  				(unsigned int __user*)argp);
>>  	} else if (cmd == TUNSETQUEUE)
>>  		return tun_set_queue(file, &ifr);
>> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
>> index e9502dd..bcf2790 100644
>> --- a/include/uapi/linux/if_tun.h
>> +++ b/include/uapi/linux/if_tun.h
>> @@ -36,6 +36,7 @@
>>  #define TUN_PERSIST 	0x0100	
>>  #define TUN_VNET_HDR 	0x0200
>>  #define TUN_TAP_MQ      0x0400
>> +#define TUN_FLOW_CONTROL 0x0800
>>  
>>  /* Ioctl defines */
>>  #define TUNSETNOCSUM  _IOW('T', 200, int) 
>> @@ -70,6 +71,7 @@
>>  #define IFF_MULTI_QUEUE 0x0100
>>  #define IFF_ATTACH_QUEUE 0x0200
>>  #define IFF_DETACH_QUEUE 0x0400
>> +#define IFF_FLOW_CONTROL 0x0010
>>  /* read-only flag */
>>  #define IFF_PERSIST	0x0800
>>  #define IFF_NOFILTER	0x1000
