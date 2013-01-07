From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 2/2] virtio-net: reset virtqueue affinity when doing
	cpu hotplug
Date: Mon, 07 Jan 2013 15:55:09 +0800
Message-ID: <50EA7F5D.7050907@redhat.com>
References: <1357542900-15557-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<1357542900-15557-2-git-send-email-gaowanlong@cn.fujitsu.com>
	<50EA792F.1010408@redhat.com> <50EA7DC0.20605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: gaowanlong@cn.fujitsu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50EA7DC0.20605@cn.fujitsu.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 01/07/2013 03:48 PM, Wanlong Gao wrote:
> On 01/07/2013 03:28 PM, Jason Wang wrote:
>> On 01/07/2013 03:15 PM, Wanlong Gao wrote:
>>> Add a cpu notifier to virtio-net, so that we can reset the
>>> virtqueue affinity if the cpu hotplug happens. It improve
>>> the performance through enabling or disabling the virtqueue
>>> affinity after doing cpu hotplug.
>>> Adding the notifier block to virtnet_info is suggested by
>>> Jason, thank you.
>>>
>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>>> Cc: Jason Wang <jasowang@redhat.com>
>>> Cc: Eric Dumazet <erdnetdev@gmail.com>
>>> Cc: virtualization@lists.linux-foundation.org
>>> Cc: netdev@vger.kernel.org
>>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>>> ---
>>>  drivers/net/virtio_net.c | 30 ++++++++++++++++++++++++++++++
>>>  1 file changed, 30 insertions(+)
>>>
>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>> index b483fb5..9547b4c 100644
>>> --- a/drivers/net/virtio_net.c
>>> +++ b/drivers/net/virtio_net.c
>>> @@ -26,6 +26,7 @@
>>>  #include <linux/scatterlist.h>
>>>  #include <linux/if_vlan.h>
>>>  #include <linux/slab.h>
>>> +#include <linux/cpu.h>
>>>  
>>>  static int napi_weight = 128;
>>>  module_param(napi_weight, int, 0444);
>>> @@ -123,6 +124,9 @@ struct virtnet_info {
>>>  
>>>  	/* Does the affinity hint is set for virtqueues? */
>>>  	bool affinity_hint_set;
>>> +
>>> +	/* CPU hot plug notifier */
>>> +	struct notifier_block nb;
>>>  };
>>>  
>>>  struct skb_vnet_hdr {
>>> @@ -1051,6 +1055,23 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>>>  	}
>>>  }
>>>  
>>> +static int virtnet_cpu_callback(struct notifier_block *nfb,
>>> +			        unsigned long action, void *hcpu)
>>> +{
>>> +	struct virtnet_info *vi = container_of(nfb, struct virtnet_info, nb);
>>> +	switch(action) {
>>> +	case CPU_ONLINE:
>>> +	case CPU_ONLINE_FROZEN:
>>> +	case CPU_DEAD:
>>> +	case CPU_DEAD_FROZEN:
>>> +		virtnet_set_affinity(vi, true);
>>> +		break;
>>> +	default:
>>> +		break;
>>> +	}
>>> +	return NOTIFY_OK;
>>> +}
>>> +
>> I think you'd better fix the .ndo_select_queue() as well (as Michael
>> said in your V1) since it currently uses smp processor id which may not
>> work very well in this case also.
> The bug is we can't get the right txq if the CPU IDs are not consecutive,
> right? Do you have any good idea about fixing this? 
>
> Thanks,
> Wanlong Gao

The point is make the virtqueue private to a specific cpu when the
number of queue pairs is equal to the number of cpus. So after you bind
the vq affinity to a specific cpu, you'd better use the reverse mapping
of this affinity to do .ndo_select_queue(). One possible idea, as
Michael suggested, is a per-cpu structure to record the preferable
virtqueue and do both .ndo_select_queue() and affinity hint setting
based on this.
>
>> Thanks
>>>  static void virtnet_get_ringparam(struct net_device *dev,
>>>  				struct ethtool_ringparam *ring)
>>>  {
>>> @@ -1509,6 +1530,13 @@ static int virtnet_probe(struct virtio_device *vdev)
>>>  		}
>>>  	}
>>>  
>>> +	vi->nb.notifier_call = &virtnet_cpu_callback;
>>> +	err = register_hotcpu_notifier(&vi->nb);
>>> +	if (err) {
>>> +		pr_debug("virtio_net: registering cpu notifier failed\n");
>>> +		goto free_recv_bufs;
>>> +	}
>>> +
>>>  	/* Assume link up if device can't report link status,
>>>  	   otherwise get link status from config. */
>>>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
>>> @@ -1553,6 +1581,8 @@ static void virtnet_remove(struct virtio_device *vdev)
>>>  {
>>>  	struct virtnet_info *vi = vdev->priv;
>>>  
>>> +	unregister_hotcpu_notifier(&vi->nb);
>>> +
>>>  	/* Prevent config work handler from accessing the device. */
>>>  	mutex_lock(&vi->config_lock);
>>>  	vi->config_enable = false;
>>
