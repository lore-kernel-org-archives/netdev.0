From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Fri, 10 Jan 2014 20:07:12 +0100
Message-ID: <52D044E0.1090206@redhat.com>
References: <1389358907-19885-1-git-send-email-dborkman@redhat.com> <CAHA+R7NPyEmSpmojrM6pOsAVq3B6NjVWWCw0oQMPZFdCaDW9sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbaAJTHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 14:07:20 -0500
In-Reply-To: <CAHA+R7NPyEmSpmojrM6pOsAVq3B6NjVWWCw0oQMPZFdCaDW9sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2014 07:51 PM, Cong Wang wrote:
> On Fri, Jan 10, 2014 at 5:01 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> We can create a vxlan device with an explicit underlying carrier.
>> In that case, when the carrier link is being deleted from the
>> system (e.g. due to module unload) we should also clean up all
>> created vxlan devices on top of it since otherwise we're in an
>> inconsistent state in vxlan device. In that case, the user needs
>> to remove all such devices, while in case of other virtual devs
>> that sit on top of physical ones, it is usually the case that
>> these devices do unregister automatically as well and do not
>> leave the burden on the user.
>>
>> This work is not necessary when vxlan device was not created with
>> a real underlying device, as connections can resume in that case
>> when driver is plugged again. But at least for the other cases,
>> we should go ahead and do the cleanup on removal.
>
> So it makes sense to move the notifier register to vxlan_newlink()
> from vxlan_init_module()?

That is probably a design descision ... I didn't want to bloat the
struct vxlan_dev, and by this approach, we can simply batch removals
through unregister_netdevice_many(), that's all.

> ...
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 481f85d..39035ba 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2656,6 +2656,54 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
>>          .fill_info      = vxlan_fill_info,
>>   };
>>
>> +static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
>> +                                            struct net_device *dev)
>> +{
>> +       struct vxlan_dev *vxlan, *next;
>> +       LIST_HEAD(list_kill);
>> +
>> +       BUG_ON(!rtnl_is_locked());
>
>
> This is not necessary at all, it is known that netdev notication
> holds rtnl lock.

We're not in fast-path, and if someone would call that function outside
of the notifier chain, it might be good to check if the lock was taken,
but if there's a strong opinion to not have that, I'll just remove it.

>> +
>> +       list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next) {
>> +               struct vxlan_rdst *dst = &vxlan->default_dst;
>> +
>> +               /* In case we created vxlan device with carrier
>> +                * and we loose the carrier due to module unload
>> +                * we also need to remove vxlan device. In other
>> +                * cases, it's not necessary and remote_ifindex
>> +                * is 0 here, so no matches.
>> +                */
>> +               if (dst->remote_ifindex == dev->ifindex)
>> +                       vxlan_dellink(vxlan->dev, &list_kill);
>> +       }
>> +
>> +       unregister_netdevice_many(&list_kill);
>> +       list_del(&list_kill);
>
>
> I think you need to flush fdb as well?

Seems this is not done through normal rtnl_ops->dellink(); vxlan_dellink()
is what we call there as well ...

>>   static __net_init int vxlan_init_net(struct net *net)
>>   {
>>          struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>> @@ -2673,14 +2721,16 @@ static __net_init int vxlan_init_net(struct net *net)
>>   static __net_exit void vxlan_exit_net(struct net *net)
>>   {
>>          struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>> -       struct vxlan_dev *vxlan;
>> -       LIST_HEAD(list);
>> +       struct vxlan_dev *vxlan, *next;
>> +       LIST_HEAD(list_kill);
>>
>>          rtnl_lock();
>> -       list_for_each_entry(vxlan, &vn->vxlan_list, next)
>> -               unregister_netdevice_queue(vxlan->dev, &list);
>> -       unregister_netdevice_many(&list);
>> +       list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next)
>> +               vxlan_dellink(vxlan->dev, &list_kill);
>> +       unregister_netdevice_many(&list_kill);
>>          rtnl_unlock();
>> +
>> +       list_del(&list_kill);
>
>
> Why these changes in vxlan_exit_net()?

I think this is way cleaner; instead of only doing half the work, we
should remove it in the same way as we remove devices through normal
rtnl ops. In case we would do allocations in future that are being
freed during vxlan_dellink(), we would simply leak them here otherwise.
