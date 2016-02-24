From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/9] Introduce devlink infrastructure
Date: Wed, 24 Feb 2016 08:19:58 +0100
Message-ID: <20160224071958.GB2151@nanopsycho.orion>
References: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
 <1456242694-29463-2-git-send-email-jiri@resnulli.us>
 <20160223211948.GT38500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35791 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757716AbcBXHUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 02:20:00 -0500
Received: by mail-wm0-f47.google.com with SMTP id c200so255056973wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 23:20:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223211948.GT38500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 10:19:48PM CET, jarod@redhat.com wrote:
>On Tue, Feb 23, 2016 at 04:51:26PM +0100, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Introduce devlink infrastructure for drivers to register and expose to
>> userspace via generic Netlink interface.
>> 
>> There are two basic objects defined:
>> devlink - one instance for every "parent device", for example switch ASIC
>> devlink port - one instance for every physical port of the device.
>> 
>> This initial portion implements basic get/dump of objects to userspace.
>> Also, port splitter and port type setting is implemented.
>...
>> +/**
>> + *	devlink_alloc - Allocate new devlink instance resources
>> + *
>> + *	@ops: ops
>> + *	@priv_size: size of user private data
>> + *
>> + *	Allocate new devlink instance resources, including devlink index
>> + *	and name.
>> + */
>> +struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
>> +{
>> +	static atomic_t dev_counter = ATOMIC_INIT(0);
>> +	struct devlink *devlink;
>> +
>> +	devlink = kzalloc(sizeof(*devlink) + priv_size, GFP_KERNEL);
>> +	if (!devlink)
>> +		return NULL;
>> +	devlink->ops = ops;
>> +	devlink_net_set(devlink, &init_net);
>> +
>> +different_name:
>> +	devlink->index = atomic_inc_return(&dev_counter);
>> +	if (devlink->index < 0) {
>> +		/* wrapped */
>> +		atomic_dec(&dev_counter);
>> +		kfree(devlink);
>> +		return NULL;
>> +	}
>> +	/* atomic_inc_return makes it start at 1, make it start at 0 */
>> +	devlink->index--;
>> +
>> +	dev_set_name(&devlink->dev, DEVLINK_GENL_NAME "%d", devlink->index);
>> +	if (devlink_name_exists(devlink_net(devlink), devlink_name(devlink)))
>> +		goto different_name;
>> +
>> +	INIT_LIST_HEAD(&devlink->port_list);
>> +	device_initialize(&devlink->dev);
>> +	devlink->dev.class = &devlink_class;
>> +	devlink->dev.platform_data = devlink;
>> +	return devlink;
>> +}
>> +EXPORT_SYMBOL_GPL(devlink_alloc);
>
>The increment then decrement bit feels... Clunky and a little confusing.
>Why not just atomic_read(&dev_counter) before different_name:, then an
>atomic_inc_return(&dev_counter) under the if clause before the goto, and
>eliminate the devlink->index-- bit?

If I split it it would not be atomic op anymore. But the
devlink->index-- is just to adjust the start, nothing else.
This is copied from nl80211 code.
