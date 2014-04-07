From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] virtio-net: reset virtqueue affinity when doing cpu
	hotplug
Date: Mon, 7 Apr 2014 08:06:20 +0200
Message-ID: <20140407080620.38f8bcf2@nial.usersys.redhat.com>
References: <1356505614-16683-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<50DACC26.7050409@redhat.com> <50DACF22.5090707@cn.fujitsu.com>
	<50DBC07B.7060303@redhat.com> <50DBC3E2.4090804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: gaowanlong@cn.fujitsu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50DBC3E2.4090804@cn.fujitsu.com>
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

On Thu, 27 Dec 2012 11:43:30 +0800
Wanlong Gao <gaowanlong@cn.fujitsu.com> wrote:

> On 12/27/2012 11:28 AM, Jason Wang wrote:
> > On 12/26/2012 06:19 PM, Wanlong Gao wrote:
> >> On 12/26/2012 06:06 PM, Jason Wang wrote:
> >>> On 12/26/2012 03:06 PM, Wanlong Gao wrote:
> >>>> Add a cpu notifier to virtio-net, so that we can reset the
> >>>> virtqueue affinity if the cpu hotplug happens. It improve
> >>>> the performance through enabling or disabling the virtqueue
> >>>> affinity after doing cpu hotplug.
> >>> Hi Wanlong:
> >>>
> >>> Thanks for looking at this.
> >>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
> >>>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> >>>> Cc: Jason Wang <jasowang@redhat.com>
> >>>> Cc: virtualization@lists.linux-foundation.org
> >>>> Cc: netdev@vger.kernel.org
> >>>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> >>>> ---
> >>>>  drivers/net/virtio_net.c | 39 ++++++++++++++++++++++++++++++++++++++-
> >>>>  1 file changed, 38 insertions(+), 1 deletion(-)
> >>>>
> >>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >>>> index a6fcf15..9710cf4 100644
> >>>> --- a/drivers/net/virtio_net.c
> >>>> +++ b/drivers/net/virtio_net.c
> >>>> @@ -26,6 +26,7 @@
> >>>>  #include <linux/scatterlist.h>
> >>>>  #include <linux/if_vlan.h>
> >>>>  #include <linux/slab.h>
> >>>> +#include <linux/cpu.h>
> >>>>  
> >>>>  static int napi_weight = 128;
> >>>>  module_param(napi_weight, int, 0444);
> >>>> @@ -34,6 +35,8 @@ static bool csum = true, gso = true;
> >>>>  module_param(csum, bool, 0444);
> >>>>  module_param(gso, bool, 0444);
> >>>>  
> >>>> +static bool cpu_hotplug = false;
> >>>> +
> >>>>  /* FIXME: MTU in config. */
> >>>>  #define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
> >>>>  #define GOOD_COPY_LEN	128
> >>>> @@ -1041,6 +1044,26 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
> >>>>  		vi->affinity_hint_set = false;
> >>>>  }
> >>>>  
> >>>> +static int virtnet_cpu_callback(struct notifier_block *nfb,
> >>>> +			       unsigned long action, void *hcpu)
> >>>> +{
> >>>> +	switch(action) {
> >>>> +	case CPU_ONLINE:
> >>>> +	case CPU_ONLINE_FROZEN:
> >>>> +	case CPU_DEAD:
> >>>> +	case CPU_DEAD_FROZEN:
> >>>> +		cpu_hotplug = true;
> >>>> +		break;
> >>>> +	default:
> >>>> +		break;
> >>>> +	}
> >>>> +	return NOTIFY_OK;
> >>>> +}
> >>>> +
> >>>> +static struct notifier_block virtnet_cpu_notifier = {
> >>>> +	.notifier_call = virtnet_cpu_callback,
> >>>> +};
> >>>> +
> >>>>  static void virtnet_get_ringparam(struct net_device *dev,
> >>>>  				struct ethtool_ringparam *ring)
> >>>>  {
> >>>> @@ -1131,7 +1154,14 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
> >>>>   */
> >>>>  static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
> >>>>  {
> >>>> -	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
> >>>> +	int txq;
> >>>> +
> >>>> +	if (unlikely(cpu_hotplug == true)) {
> >>>> +		virtnet_set_affinity(netdev_priv(dev), true);
> >>>> +		cpu_hotplug = false;
> >>>> +	}
> >>>> +
> >>> Why don't you just do this in callback?
> >> Callback can just give us a "hcpu", can't get the virtnet_info from callback. Am I missing something?
> > 
> > Well, I think you can just embed the notifier block into virtnet_info,
> > then use something like container_of in the callback to make the
> > notifier per device. This also solve the concern of Eric.
> 
> Yeah, thank you very much for your suggestion. I'll try it.
> 
> >>> btw. Does qemu/kvm support cpu-hotplug now?
> >> From http://www.linux-kvm.org/page/CPUHotPlug, I saw that qemu-kvm can support hotplug
> >> but failed to merge to qemu.git, right?
> > 
> > Not sure, I just try latest qemu, it even does not have a cpu_set command.
> 
> Adding Igor to CC,
> 
> As I know, hotplug support is cleaned from qemu, and Igor want to rework it but not been completed?
> I'm not sure about that, Igor, could you send out your tech-preview-patches?
CPU hot-add is supported by upstream now, hot-remove is not supported yet,
besides of qemu work it would require quite a work on kvm side as well.

> 
> Thanks,
> Wanlong Gao
> 
> > 
> > Thanks
> >>
> >> Thanks,
> >> Wanlong Gao
> >>
> > 
> > 
> 
