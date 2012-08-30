From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH bridge 5/5] bridge: Add sysfs interface to display
 VLANS
Date: Thu, 30 Aug 2012 11:07:24 -0400
Message-ID: <503F81AC.2090201@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <1345750195-31598-6-git-send-email-vyasevic@redhat.com> <20120830122724.GC20228@redhat.com> <503F731C.1070208@redhat.com> <20120830142609.GE21132@redhat.com> <503F7A72.6070101@redhat.com> <20120830144443.GD21646@redhat.com> <503F7DF7.5020606@redhat.com> <20120830150351.GA21739@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455Ab2H3PH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2012 11:07:26 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7UF7QYP010831
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 11:07:26 -0400
In-Reply-To: <20120830150351.GA21739@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2012 11:03 AM, Michael S. Tsirkin wrote:
> On Thu, Aug 30, 2012 at 10:51:35AM -0400, Vlad Yasevich wrote:
>> On 08/30/2012 10:44 AM, Michael S. Tsirkin wrote:
>>> On Thu, Aug 30, 2012 at 10:36:34AM -0400, Vlad Yasevich wrote:
>>>> On 08/30/2012 10:26 AM, Michael S. Tsirkin wrote:
>>>>> On Thu, Aug 30, 2012 at 10:05:16AM -0400, Vlad Yasevich wrote:
>>>>>> On 08/30/2012 08:27 AM, Michael S. Tsirkin wrote:
>>>>>>> On Thu, Aug 23, 2012 at 03:29:55PM -0400, Vlad Yasevich wrote:
>>>>>>>> Add a binary sysfs file that will dump out vlans currently configured on the
>>>>>>>> port.
>>>>
>>>> I initially though of creating a sysfs object per vlan.  That would
>>>> have made it easy to see which vlans are configured without any
>>>> tools.
>>>> But that could result in a lot of objects being created, so I abandoned it.
>>>>
>>>> I did think about a text interface, but due to a page of output
>>>> limitation, I didn't go that route.  The reason is that if someone
>>>> cats the file, they may not see all the vlans configured.  So I
>>>> decided on the binary interface, since a binary interface with a
>>>> tool to read it could avoid the single page limitation.
>>>>
>>>> -vlad
>>>
>>> Maybe it's not needed in sysfs then - expose it to
>>> brctl or whatever.
>>>
>>
>> brctl uses sysfs for almost everything any more :)
>>
>> -vlad
>
> How about a long string of 0 and 1's?
> And a separate one for untagged vlans.

that would work too.  You really don't like the binary interface, huh?

-vlad
>
>>>>>
>>>>>
>>>>>>>
>>>>>>>> ---
>>>>>>>>   include/linux/if_bridge.h |    1 +
>>>>>>>>   net/bridge/br_if.c        |   34 ++++++++++++++++++++++++++++++++++
>>>>>>>>   net/bridge/br_private.h   |    2 ++
>>>>>>>>   net/bridge/br_sysfs_if.c  |   28 ++++++++++++++++++++++++++++
>>>>>>>>   4 files changed, 65 insertions(+), 0 deletions(-)
>>>>>>>>
>>>>>>>> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
>>>>>>>> index ab750dd..d0f869b 100644
>>>>>>>> --- a/include/linux/if_bridge.h
>>>>>>>> +++ b/include/linux/if_bridge.h
>>>>>>>> @@ -20,6 +20,7 @@
>>>>>>>>   #define SYSFS_BRIDGE_PORT_SUBDIR "brif"
>>>>>>>>   #define SYSFS_BRIDGE_PORT_ATTR	"brport"
>>>>>>>>   #define SYSFS_BRIDGE_PORT_LINK	"bridge"
>>>>>>>> +#define SYSFS_BRIDGE_PORT_VLANS "vlans"
>>>>>>>>
>>>>>>>>   #define BRCTL_VERSION 1
>>>>>>>>
>>>>>>>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>>>>>>>> index 90c1038..3963748 100644
>>>>>>>> --- a/net/bridge/br_if.c
>>>>>>>> +++ b/net/bridge/br_if.c
>>>>>>>> @@ -510,6 +510,40 @@ int br_del_port_vlan(struct net_bridge_port *p, unsigned long vlan)
>>>>>>>>   	return 0;
>>>>>>>>   }
>>>>>>>>
>>>>>>>> +size_t br_port_fill_vlans(struct net_bridge_port *p, char* buf,
>>>>>>>> +			unsigned long max, unsigned long skip)
>>>>>>>> +{
>>>>>>>> +	unsigned long *map;
>>>>>>>> +	unsigned short *vid = (unsigned short *)buf;
>>>>>>>> +	unsigned short i;
>>>>>>>> +	int num = 0;
>>>>>>>> +
>>>>>>>> +	if (skip > (VLAN_N_VID+1))
>>>>>>>> +		return -EINVAL;
>>>>>>>> +
>>>>>>>> +	memset(buf, 0, max * sizeof(unsigned short));
>>>>>>>
>>>>>>> Isn't max is in bytes? why is this safe?
>>>>>>>
>>>>>>>> +
>>>>>>>> +	rcu_read_lock();
>>>>>>>> +	map = rcu_dereference(p->vlan_map);
>>>>>>>> +	if (!map)
>>>>>>>> +		goto out;
>>>>>>>> +
>>>>>>>> +	for (i = skip + 1; i < VLAN_N_VID + 1; i++) {
>>>>>>>
>>>>>>> Isn't skip in bytes too? Why do you compare it to i which is
>>>>>>> in dwords?
>>>>>>>
>>>>>>>> +		if (test_bit(i, map)) {
>>>>>>>> +			if (num > max)
>>>>>>>> +				goto out;
>>>>>>>> +
>>>>>>>> +			*vid = i-1;
>>>>>>>> +			vid++;
>>>>>>>> +			num++;
>>>>>>>> +		}
>>>>>>>> +	}
>>>>>>>> +out:
>>>>>>>> +	rcu_read_unlock();
>>>>>>>> +
>>>>>>>> +	return num*sizeof(unsigned short);
>>>>>>>> +}
>>>>>>>> +
>>>>>>>>   void __net_exit br_net_exit(struct net *net)
>>>>>>>>   {
>>>>>>>>   	struct net_device *dev;
>>>>>>>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>>>>>>>> index 5639c1c..cf95cd7 100644
>>>>>>>> --- a/net/bridge/br_private.h
>>>>>>>> +++ b/net/bridge/br_private.h
>>>>>>>> @@ -404,6 +404,8 @@ extern netdev_features_t br_features_recompute(struct net_bridge *br,
>>>>>>>>   	netdev_features_t features);
>>>>>>>>   extern int br_set_port_vlan(struct net_bridge_port *p, unsigned long vid);
>>>>>>>>   extern int br_del_port_vlan(struct net_bridge_port *p, unsigned long vid);
>>>>>>>> +extern size_t br_port_fill_vlans(struct net_bridge_port *p, char *buf,
>>>>>>>> +				unsigned long max, unsigned long skip);
>>>>>>>>
>>>>>>>>   /* br_input.c */
>>>>>>>>   extern int br_handle_frame_finish(struct sk_buff *skb);
>>>>>>>> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
>>>>>>>> index 13b36bd..a81e2ef 100644
>>>>>>>> --- a/net/bridge/br_sysfs_if.c
>>>>>>>> +++ b/net/bridge/br_sysfs_if.c
>>>>>>>> @@ -234,6 +234,29 @@ const struct sysfs_ops brport_sysfs_ops = {
>>>>>>>>   };
>>>>>>>>
>>>>>>>>   /*
>>>>>>>> + * Export the vlan table for a given port as a binary file.
>>>>>>>> + * The records are unsgined shorts.
>>>>>>>> + *
>>>>>>>> + * Returns the number of bytes read.
>>>>>>>> + */
>>>>>>>> +static ssize_t brport_vlans_read(struct file *filp, struct kobject *kobj,
>>>>>>>> +				struct bin_attribute *bin_attr,
>>>>>>>> +				char *buf, loff_t off, size_t count)
>>>>>>>> +{
>>>>>>>> +	struct net_bridge_port *p = to_brport(kobj);
>>>>>>>> +
>>>>>>>> +	return br_port_fill_vlans(p, buf,
>>>>>>>> +				count/sizeof(unsigned short),
>>>>>>>> +				off/sizeof(unsigned short));
>>>>>>>> +}
>>>>>>>> +
>>>>>>>> +static struct bin_attribute port_vlans = {
>>>>>>>> +	.attr = { .name = SYSFS_BRIDGE_PORT_VLANS,
>>>>>>>> +		  .mode = S_IRUGO, },
>>>>>>>> +	.read = brport_vlans_read,
>>>>>>>> +};
>>>>>>>> +
>>>>>>>> +/*
>>>>>>>>    * Add sysfs entries to ethernet device added to a bridge.
>>>>>>>>    * Creates a brport subdirectory with bridge attributes.
>>>>>>>>    * Puts symlink in bridge's brif subdirectory
>>>>>>>> @@ -255,6 +278,11 @@ int br_sysfs_addif(struct net_bridge_port *p)
>>>>>>>>   			return err;
>>>>>>>>   	}
>>>>>>>>
>>>>>>>> +	err = sysfs_create_bin_file(&p->kobj, &port_vlans);
>>>>>>>> +	if (err) {
>>>>>>>> +		return err;
>>>>>>>> +	}
>>>>>>>> +
>>>>>>>>   	strlcpy(p->sysfs_name, p->dev->name, IFNAMSIZ);
>>>>>>>>   	return sysfs_create_link(br->ifobj, &p->kobj, p->sysfs_name);
>>>>>>>>   }
>>>>>>>> --
>>>>>>>> 1.7.7.6
>>>>>>>>
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
