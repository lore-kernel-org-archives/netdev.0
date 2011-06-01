From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure counters
Date: Wed, 01 Jun 2011 09:13:39 -0700
Message-ID: <16056.1306944819@death>
References: <1306921249-3623-1-git-send-email-jpirko@redhat.com> <4DE63E85.7020508@redhat.com> <20110601135321.GA2909@psychotron.brq.redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:57551 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501Ab1FARYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 13:24:30 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p51Gv4vO003866
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 12:57:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p51HLV0j109372
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 13:24:29 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p51ADocj020136
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 04:13:51 -0600
In-reply-to: <20110601135321.GA2909@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>Wed, Jun 01, 2011 at 03:28:37PM CEST, fbl@redhat.com wrote:
>>On 06/01/2011 06:40 AM, Jiri Pirko wrote:
>>> This patch allows to reset failure counters for all enslaved devices.
>>> 
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>> ---
>>>  Documentation/networking/bonding.txt |    7 +++++++
>>>  drivers/net/bonding/bond_sysfs.c     |   27 +++++++++++++++++++++++++++
>>>  2 files changed, 34 insertions(+), 0 deletions(-)
>>> 
>>> diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>>> index 675612f..2f51d73 100644
>>> --- a/Documentation/networking/bonding.txt
>>> +++ b/Documentation/networking/bonding.txt
>>> @@ -782,6 +782,13 @@ resend_igmp
>>>  
>>>  	This option was added for bonding version 3.7.0.
>>>  
>>> +reset_failure_counters
>>> +
>>> +	This write-only control file will zero failure counters for
>>> +	all slaves.  Note there is no appropriate module parameter for this
>>> +	since it would not make much sense.
>>> +	Write any value to perform reset.
>>
>>nit: many options mention when they were added.
>>i.e. This option was added for bonding version 3.7.1
>
>hmm, is that necessary Jay, Andy?
>
>/me thinks this versioning should be removed at all in the first place...

	The "this dingus was added in version X.Y.Z" is there because
users sometimes read the most recent version of the documentation (that
they get from the internet) and then would become confused when their
older distro driver lacked some option described in the documentation.

	I don't know if this is "good" or "bad" in an absolute sense,
but I stopped getting questions of that sort after I put these notes
into the documentation.  I don't really see a down side, so for this
patch I'd like to see the version go up and one of these notes in the
documentation.

>>
>>fbl
>>
>>>  3. Configuring Bonding Devices
>>>  ==============================
>>>  
>>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>>> index 88fcb25..9b45164 100644
>>> --- a/drivers/net/bonding/bond_sysfs.c
>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>> @@ -1572,6 +1572,32 @@ out:
>>>  static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
>>>  		   bonding_show_resend_igmp, bonding_store_resend_igmp);
>>>  
>>> +static ssize_t
>>> +bonding_store_reset_failure_counters(struct device *d,
>>> +				     struct device_attribute *attr,
>>> +				     const char *buf, size_t count)
>>> +{
>>> +	struct slave *slave;
>>> +	int i;
>>> +	struct bonding *bond = to_bond(d);
>>> +
>>> +	if (!rtnl_trylock())
>>> +		return restart_syscall();
>>> +
>>> +	read_lock(&bond->lock);
>>> +	pr_info("%s: Resetting counters.\n", bond->dev->name);

	I'd stick "failure" in here somewhere so it's clear what's been
reset.  The printk can be done outside the lock as well.

	-J

>>> +	bond_for_each_slave(bond, slave, i)
>>> +		slave->link_failure_count = 0;
>>> +	read_unlock(&bond->lock);
>>> +
>>> +	rtnl_unlock();
>>> +
>>> +	return count;
>>> +}
>>> +
>>> +static DEVICE_ATTR(reset_failure_counters, S_IWUSR, NULL,
>>> +		   bonding_store_reset_failure_counters);
>>> +
>>>  static struct attribute *per_bond_attrs[] = {
>>>  	&dev_attr_slaves.attr,
>>>  	&dev_attr_mode.attr,
>>> @@ -1600,6 +1626,7 @@ static struct attribute *per_bond_attrs[] = {
>>>  	&dev_attr_queue_id.attr,
>>>  	&dev_attr_all_slaves_active.attr,
>>>  	&dev_attr_resend_igmp.attr,
>>> +	&dev_attr_reset_failure_counters.attr,
>>>  	NULL,
>>>  };
>>>  
>>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
