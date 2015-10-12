From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 4/7] switchdev: introduce possibility to
 defer obj_add/del
Date: Mon, 12 Oct 2015 16:44:36 +0200
Message-ID: <20151012144436.GE2370@nanopsycho.orion>
References: <1444655710-8279-1-git-send-email-jiri@resnulli.us>
 <1444655710-8279-5-git-send-email-jiri@resnulli.us>
 <561BC4F1.5080005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35647 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbJLOoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 10:44:39 -0400
Received: by wicge5 with SMTP id ge5so153396244wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 07:44:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <561BC4F1.5080005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 04:34:25PM CEST, nikolay@cumulusnetworks.com wrote:
>On 10/12/2015 03:15 PM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Similar to the attr usecase, the caller knows if he is holding RTNL and is
>> in atomic section. So let the called to decide the correct call variant.
>> 
>> This allows drivers to sleep inside their ops and wait for hw to get the
>> operation status. Then the status is propagated into switchdev core.
>> This avoids silent errors in drivers.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/switchdev.h   |   1 +
>>  net/switchdev/switchdev.c | 137 +++++++++++++++++++++++++++++++++++++---------
>>  2 files changed, 112 insertions(+), 26 deletions(-)
>> 
>[snip]
>> +
>> +struct switchdev_obj_work {
>> +	struct work_struct work;
>> +	struct net_device *dev;
>> +	struct switchdev_obj obj;
>> +	bool add; /* add of del */
>s/of/or/ ? :-)

will fix, thanks.


>
>> +};
>> +
>> +static void switchdev_port_obj_work(struct work_struct *work)
>> +{
>> +	struct switchdev_obj_work *ow =
>> +			container_of(work, struct switchdev_obj_work, work);
>> +	bool rtnl_locked = rtnl_is_locked();
>> +	int err;
>> +
>> +	if (!rtnl_locked)
>> +		rtnl_lock();
>> +	if (ow->add)
>> +		err = switchdev_port_obj_add_now(ow->dev, &ow->obj);
>> +	else
>> +		err = switchdev_port_obj_del_now(ow->dev, &ow->obj);
>> +	if (err && err != -EOPNOTSUPP)
>> +		netdev_err(ow->dev, "failed (err=%d) to %s object (id=%d)\n",
>> +			   err, ow->add ? "add" : "del", ow->obj.id);
>> +	if (!rtnl_locked)
>> +		rtnl_unlock();
>> +
>> +	dev_put(ow->dev);
>> +	kfree(ow);
>> +}
>> +
>> +static int switchdev_port_obj_work_schedule(struct net_device *dev,
>> +					    const struct switchdev_obj *obj,
>> +					    bool add)
>> +{
>> +	struct switchdev_obj_work *ow;
>> +
>> +	ow = kmalloc(sizeof(*ow), GFP_ATOMIC);
>> +	if (!ow)
>> +		return -ENOMEM;
>> +
>> +	INIT_WORK(&ow->work, switchdev_port_obj_work);
>> +
>This can be called without rtnl, what stops the device from disappearing
>between the above and the hold below ?

You are right. I will have to figure that out. Btw the same issue
already exists for attr_set deferred work.


>
>> +	dev_hold(dev);
>> +	ow->dev = dev;
>> +	memcpy(&ow->obj, obj, sizeof(ow->obj));
>> +	ow->add = add;
>> +
>> +	queue_work(switchdev_wq, &ow->work);
>> +	return 0;
>> +}
>> +
>[snip]
>
