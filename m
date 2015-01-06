From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Tue, 6 Jan 2015 09:51:59 -0800
Message-ID: <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	<1420552709.32369.50.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:59939 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303AbbAFRwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:52:01 -0500
Received: by mail-wg0-f50.google.com with SMTP id a1so29665372wgh.23
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 09:52:00 -0800 (PST)
In-Reply-To: <1420552709.32369.50.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 5:58 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Scott,
>
> On Do, 2015-01-01 at 19:29 -0800, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To offload IPv4 L3 routing functions to swdev device, the swdev device driver
>> implements two new ndo ops (ndo_switch_fib_ipv4_add/del).  The ops are called
>> by the core IPv4 FIB code when installing/removing FIB entries to/from the
>> kernel FIB.  On install, the driver should return 0 if FIB entry (route) can be
>> installed to device for offloading, -EOPNOTSUPP if route cannot be installed
>> due to device limitations, and other negative error code on failure to install
>> route to device.  On failure error code, the route is not installed to device,
>> and not installed in kernel FIB, and the return code is propagated back to the
>> user-space caller (via netlink).  An -EOPNOTSUPP error code is skipped for the
>> device but installed in the kernel FIB.
>>
>> The FIB entry (route) nexthop list is used to find the swdev device port to
>> anchor the ndo op call.  The route's fib_dev (the first nexthop's dev) is used
>> find the swdev port by recursively traversing the fib_dev's lower_dev list
>> until a swdev port is found.  The ndo op is called on this swdev port.
>>
>> Since the FIB entry is "naked" when push from the kernel, the driver/device
>> is responsible for resolving the route's nexthops to neighbor MAC addresses.
>> This can be done by the driver by monitoring NETEVENT_NEIGH_UPDATE
>> netevent notifier to watch for ARP activity.  Once a nexthop is resolved to
>> neighbor MAC address, it can be installed to the device and the device will
>> do the L3 routing offload in HW, for that nexthop.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/netdevice.h |   22 +++++++++++
>>  include/net/switchdev.h   |   18 +++++++++
>>  net/ipv4/fib_trie.c       |   17 ++++++++-
>>  net/switchdev/switchdev.c |   89 +++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 145 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 679e6e9..b66d22b 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -767,6 +767,8 @@ struct netdev_phys_item_id {
>>  typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>                                      struct sk_buff *skb);
>>
>> +struct fib_info;
>> +
>>  /*
>>   * This structure defines the management hooks for network devices.
>>   * The following hooks can be defined; unless noted otherwise, they are
>> @@ -1030,6 +1032,14 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>   * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>>   *   Called to notify switch device port of bridge port STP
>>   *   state change.
>> + * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
>> + *                                int dst_len, struct fib_info *fi,
>> + *                                u8 tos, u8 type, u32 tb_id);
>> + *   Called to add IPv4 route to switch device.
>> + * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
>> + *                                int dst_len, struct fib_info *fi,
>> + *                                u8 tos, u8 type, u32 tb_id);
>> + *   Called to delete IPv4 route from switch device.
>>   */
>>  struct net_device_ops {
>>       int                     (*ndo_init)(struct net_device *dev);
>> @@ -1189,6 +1199,18 @@ struct net_device_ops {
>>                                                           struct netdev_phys_item_id *psid);
>>       int                     (*ndo_switch_port_stp_update)(struct net_device *dev,
>>                                                             u8 state);
>> +     int                     (*ndo_switch_fib_ipv4_add)(struct net_device *dev,
>> +                                                        __be32 dst,
>> +                                                        int dst_len,
>> +                                                        struct fib_info *fi,
>> +                                                        u8 tos, u8 type,
>> +                                                        u32 tb_id);
>> +     int                     (*ndo_switch_fib_ipv4_del)(struct net_device *dev,
>> +                                                        __be32 dst,
>> +                                                        int dst_len,
>> +                                                        struct fib_info *fi,
>> +                                                        u8 tos, u8 type,
>> +                                                        u32 tb_id);
>>  #endif
>>  };
>
> At this point I would like to start the discussion about handling of the
> table ids/vrfs (again :) ): as I can see it, this version just passes
> table ids down to the driver layer and the rocker driver filters them by
> local/main table? This seems to be mostly fine for a first version but
> does not feel like it will integrate well with the rest of the linux
> networking ecosystem.
>
> Will hardware have the capabilities to do programmable matches like "ip
> rule" is currently capable to do? Should we plan for that? Do we want to
> support hardware which does support multiple tables/VRFs?

Good questions, thanks for bringing these up.

>
> I would like to present a first suggestion:
> My take on this would be strive towards an integration with ip-rule, so
> we add tables which will be offloaded to hardware. This happens only in
> situations where those tables will be the first match for incoming
> packets specified with an in-interface filter which has the capability
> to do the offloading (for example). The determination if the table is
> capable for hardware offloading should be done automatically, so if
> later hardware will be capable of doing ip rule like matches, we can
> just expand the check which flags the tables accordingly.

Sounds like a good suggestion to me.  We need to think about what the
swdev API looks like to the switch device driver.  Could you take a
stab at defining what integration with ip-rule looks like, code-wise,
at the swdev API layer?

With the rocker device we're prototyping with, the standard LPM on IP
dst is the normal L3 routing table structure.  Within that, table
priorities could be handled, so routes in one table take precedence
over routes in another table.  If we want to do policy routing, then
we'd need to use the ACL table in rocker to match on other fields
besides just IP dst.

> Anyway, if hardware supports multiple tables or VRFs, it is better to
> manage pass in a pointer where drivers can embed private data for
> management, I think.
>
> Thanks,
> Hannes
>
>
>
