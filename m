From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Wed, 23 Sep 2015 17:56:12 +0200
Message-ID: <20150923155612.GC11681@nanopsycho.orion>
References: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
 <1442995078-10491-3-git-send-email-jiri@resnulli.us>
 <CAE4R7bBuN1Qtj+DSW1cCfYCNzDTix0t0J-zRz+yjtc7jj=NLRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34315 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755724AbbIWP4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:56:15 -0400
Received: by wicfx3 with SMTP id fx3so245423621wic.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:56:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBuN1Qtj+DSW1cCfYCNzDTix0t0J-zRz+yjtc7jj=NLRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 23, 2015 at 05:46:44PM CEST, sfeldma@gmail.com wrote:
>On Wed, Sep 23, 2015 at 12:57 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Now, the memory allocation in prepare/commit state is done separatelly
>> in each driver (rocker). Introduce the similar mechanism in generic
>> switchdev code, in form of queue. That can be used not only for memory
>> allocations, but also for different items. Commit/abort item destruction
>> is handled as well.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> v1-v2:
>> - added comment blocks to exported functions as suggested by Scott
>> - made switchdev_trans_init and switchdev_trans_items_destroy static
>> - added documentation for this to switchdev.txt as suggested by Scott
>
>[cut]
>
>> @@ -232,10 +304,13 @@ static int __switchdev_port_obj_add(struct net_device *dev,
>>   */
>>  int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
>>  {
>> +       struct switchdev_trans trans;
>>         int err;
>>
>>         ASSERT_RTNL();
>>
>> +       switchdev_trans_init(&trans);
>> +
>>         /* Phase I: prepare for obj add. Driver/device should fail
>>          * here if there are going to be issues in the commit phase,
>>          * such as lack of resources or support.  The driver/device
>> @@ -244,7 +319,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
>>          */
>>
>>         obj->trans_ph = SWITCHDEV_TRANS_PREPARE;
>> -       err = __switchdev_port_obj_add(dev, obj);
>> +       err = __switchdev_port_obj_add(dev, obj, &trans);
>>         if (err) {
>>                 /* Prepare phase failed: abort the transaction.  Any
>>                  * resources reserved in the prepare phase are
>> @@ -253,7 +328,8 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
>>
>>                 if (err != -EOPNOTSUPP) {
>>                         obj->trans_ph = SWITCHDEV_TRANS_ABORT;
>> -                       __switchdev_port_obj_add(dev, obj);
>> +                       __switchdev_port_obj_add(dev, obj, &trans);
>> +                       switchdev_trans_items_destroy(&trans);
>>                 }
>>
>>                 return err;
>> @@ -265,8 +341,9 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
>>          */
>>
>>         obj->trans_ph = SWITCHDEV_TRANS_COMMIT;
>> -       err = __switchdev_port_obj_add(dev, obj);
>> +       err = __switchdev_port_obj_add(dev, obj, &trans);
>>         WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
>> +       switchdev_trans_items_destroy(&trans);
>
>Before this patchset, rocker would BUG_ON that the list was empty
>after commit.  This was really helpful in finding bugs in the driver
>as it meant the commit and prepare phases didn't follow the same code
>path.  (Everything the driver queued in prepare was dequeued in
>commit, so the list should be empty after commit).
>
>Should this last switchdev_trans_items_destroy(&trans) be replaced with:
>
>    BUG_ON(!list_empty(&trans.item_list));

Sounds reasonable. Will change this.

Thanks!
