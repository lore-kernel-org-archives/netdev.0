From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [RFC 1/3] vsockmon: Add tap functions.
Date: Thu, 9 Jun 2016 17:02:47 +0200
Message-ID: <969687fe-f812-7412-bd06-89b159daa88a@deic.uab.cat>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-2-ggarcia@deic.uab.cat>
 <20160601210703.GF15594@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36557 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbcFIPCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 11:02:51 -0400
Received: by mail-wm0-f67.google.com with SMTP id m124so11365828wme.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 08:02:50 -0700 (PDT)
In-Reply-To: <20160601210703.GF15594@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/01/2016 11:07 PM, Stefan Hajnoczi wrote:
> On Sat, May 28, 2016 at 06:29:05PM +0200, ggarcia@abra.uab.cat wrote:
>> From: Gerard Garcia <ggarcia@deic.uab.cat>
>>
>> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
>> ---
>>   include/net/af_vsock.h      |  13 ++++++
>>   include/uapi/linux/if_arp.h |   1 +
>>   net/vmw_vsock/af_vsock.c    | 105 ++++++++++++++++++++++++++++++++++++++++++++
>>   3 files changed, 119 insertions(+)
>>
>> diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
>> index 15694c9..c4593d8 100644
>> --- a/include/net/af_vsock.h
>> +++ b/include/net/af_vsock.h
>> @@ -187,4 +187,17 @@ struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
>>   					 struct sockaddr_vm *dst);
>>   void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
>>   
>> +/**** TAP ****/
>> +
>> +struct vsock_tap {
>> +	struct net_device *dev;
>> +	struct module *module;
>> +	struct list_head list;
>> +};
>> +
>> +extern int vsock_init_tap(void);
>> +extern int vsock_add_tap(struct vsock_tap *vt);
>> +extern int vsock_remove_tap(struct vsock_tap *vt);
>> +extern void vsock_deliver_tap(struct sk_buff *skb);
> The other function prototypes in this header don't use "extern" either.
> Please drop for consistency.
Ok
>> +
>>   #endif /* __AF_VSOCK_H__ */
>> diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
>> index 4d024d7..869262a 100644
>> --- a/include/uapi/linux/if_arp.h
>> +++ b/include/uapi/linux/if_arp.h
>> @@ -95,6 +95,7 @@
>>   #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
>>   #define ARPHRD_NETLINK	824		/* Netlink header		*/
>>   #define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
>> +#define ARPHRD_VSOCKMON 826		/* Vsock monitor header		*/
> Previous lines use a tab character (^I) before the numeric constant.
> Please follow that style for consistency.
Ok
> I suggest calling it just ARPHRD_VSOCK.  Netlink also uses
> ARPHRD_NETLINK instead of ARPHRD_NLMON.
We define a new header used exclusively by the vsockmon device, nlmon 
copies the netlink header entirely.
I'm not sure if we should *link* the ARPHRD_VSOCK identifier to the 
vsockmon header.
>>   
>>   #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
>>   #define ARPHRD_NONE	  0xFFFE	/* zero header length */
>> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
>> index 6b158ab..ec7a05d 100644
>> --- a/net/vmw_vsock/af_vsock.c
>> +++ b/net/vmw_vsock/af_vsock.c
>> @@ -96,6 +96,7 @@
>>   #include <linux/unistd.h>
>>   #include <linux/wait.h>
>>   #include <linux/workqueue.h>
>> +#include <linux/if_arp.h>
>>   #include <net/sock.h>
>>   #include <net/af_vsock.h>
>>   
>> @@ -2012,6 +2013,110 @@ const struct vsock_transport *vsock_core_get_transport(void)
>>   }
>>   EXPORT_SYMBOL_GPL(vsock_core_get_transport);
>>   
>> +/**** TAP ****/
> Feel free to put this in a separate source file.  The Kbuild can link
> multiple objects into a single kernel module.  That would be cleaner
> than using a big comment to separate it from af_vsock.c code.
I'm following the af_vsock.c style, where different logic is separated 
using this style of comments. It is not a lot of code
so I thought it would be cleaner to have it in the same file.
> I wonder whether this tap mechanism should be generic so that netlink,
> vsock, and other address families can reuse the code.  This is basically
> copied from netlink.
>
>> +static DEFINE_SPINLOCK(vsock_tap_lock);
>> +static struct list_head vsock_tap_all __read_mostly;
>> +
>> +int vsock_init_tap(void) {
>> +	INIT_LIST_HEAD(&vsock_tap_all);
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(vsock_init_tap);
> Can you use LIST_HEAD_INIT() on the vsock_tap_all declaration line to
> eliminate the need for vsock_init_tap() completely?
Yes, I'll do that. I though we may need to do more initialization at 
some point, but for now it is better to just
statically initialize it.
>> +
>> +int vsock_add_tap(struct vsock_tap *vt) {
>> +	if (unlikely(vt->dev->type != ARPHRD_VSOCKMON))
>> +		return -EINVAL;
>> +
>> +	spin_lock(&vsock_tap_lock);
>> +	list_add_rcu(&vt->list, &vsock_tap_all);
>> +	spin_unlock(&vsock_tap_lock);
>> +
>> +	__module_get(vt->module);
> It's slightly safer to get the module before publishing it on the list.
> But in practice I guess the caller is the module so the module won't
> disappear underneath us.
This function is equal to the function in af_netlink.c used by nlmon. As 
you said, in practice the caller is the module
so it won't disappear.
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(vsock_add_tap);
>> +
>> +int __vsock_remove_tap(struct vsock_tap *vt) {
>> +	bool found = false;
>> +	struct vsock_tap *tmp;
>> +
>> +	spin_lock(&vsock_tap_lock);
>> +
>> +	list_for_each_entry(tmp, &vsock_tap_all, list) {
>> +		if (vt == tmp) {
>> +			list_del_rcu(&vt->list);
>> +			found = true;
>> +			goto out;
>> +		}
>> +	}
>> +
>> +	pr_warn("__vsock_remove_tap: %p not found\n", vt);
>> +out:
>> +	spin_unlock(&vsock_tap_lock);
>> +
>> +	if (found)
>> +		module_put(vt->module);
>> +
>> +	return found ? 0 : -ENODEV;
>> +}
>> +
>> +int vsock_remove_tap(struct vsock_tap *vt)
>> +{
>> +	int ret;
>> +
>> +	ret = __vsock_remove_tap(vt);
>> +	synchronize_net();
> module_put() should be called after synchronize_net().  That way we
> guarantee that no one is still accessing vt when the module is put.  The
> caller is probably the module though, so maybe there is an implicit
> reference...
Also, it is equal to the function in af_netlink.c used by nlmon. And as 
before, this function is supposed
to be called from the same module so it can't disappear before calling 
synchronize_net().
>> +
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL_GPL(vsock_remove_tap);
>> +
>> +static int __vsock_deliver_tap_skb(struct sk_buff *skb,
>> +				     struct net_device *dev)
>> +{
>> +	struct sk_buff *vskb;
>> +	int ret = 0;
>> +
>> +	if (skb) {
>> +		dev_hold(dev);
>> +		vskb = skb_clone(skb, GFP_ATOMIC);
> You must handle the case where skb_clone() returns NULL.  In other
> words, we don't have enough memory to capture the packet and just return
> -ENOMEM.
You are right!
>> +		vskb->dev = dev;
>> +		vskb->pkt_type = PACKET_USER;
> I'm not sure if PACKET_USER is correct (or if pkt_type matters at all).
>
> PACKET_USER/PACKET_KERNEL seems to be purely a netlink concept to
> distinguish netlink packets originating from the kernel or userspace.
>
> AF_VSOCK is more like Ethernet where packets come from the host itself
> or from a VM.  I would consider PACKET_HOST and PACKET_OTHERHOST.
>
I'm not sure either if pkt_type matters. I haven't found any code that 
uses it so I'll just leave it unset.
>> +		ret = dev_queue_xmit(vskb);
>> +		if (unlikely(ret > 0))
>> +			ret = net_xmit_errno(ret);
>> +
>> +		dev_put(dev);
>> +	}
>> +
>> +	return ret;
>> +}
>> +
>> +static void __vsock_deliver_tap(struct sk_buff *skb)
>> +{
>> +	int ret;
>> +	struct vsock_tap *tmp;
>> +
>> +	list_for_each_entry_rcu(tmp, &vsock_tap_all, list) {
>> +		ret = __vsock_deliver_tap_skb(skb, tmp->dev);
>> +		if (unlikely(ret))
>> +			break;
>> +	}
>> +}
>> +
>> +void vsock_deliver_tap(struct sk_buff *skb)
>> +{
>> +	rcu_read_lock();
>> +
>> +	if (unlikely(!list_empty(&vsock_tap_all)))
>> +		__vsock_deliver_tap(skb);
>> +
>> +	rcu_read_unlock();
>> +}
>> +EXPORT_SYMBOL_GPL(vsock_deliver_tap);
>> +
>>   MODULE_AUTHOR("VMware, Inc.");
>>   MODULE_DESCRIPTION("VMware Virtual Socket Family");
>>   MODULE_VERSION("1.0.1.0-k");
>> -- 
>> 2.8.3
>>
