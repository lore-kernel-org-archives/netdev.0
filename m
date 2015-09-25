From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Thu, 24 Sep 2015 22:29:43 -0700
Message-ID: <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
 <1443081769-11193-3-git-send-email-jiri@resnulli.us> <20150925043640.GB18915@ketchup.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35879 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbIYFaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 01:30:04 -0400
Received: by oibi136 with SMTP id i136so53394397oib.3
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 22:30:03 -0700 (PDT)
In-Reply-To: <20150925043640.GB18915@ketchup.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 9:36 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Hi Jiri,
>
> On Sep. Thursday 24 (39) 10:02 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Now, the memory allocation in prepare/commit state is done separatelly
>> in each driver (rocker). Introduce the similar mechanism in generic
>> switchdev code, in form of queue. That can be used not only for memory
>> allocations, but also for different items. Abort item destruction
>> is handled as well.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
> [...]
>
>>  /**
>>   * struct switchdev_ops - switchdev operations
>>   *
>> @@ -94,9 +110,11 @@ struct switchdev_ops {
>>       int     (*switchdev_port_attr_get)(struct net_device *dev,
>>                                          struct switchdev_attr *attr);
>>       int     (*switchdev_port_attr_set)(struct net_device *dev,
>> -                                        struct switchdev_attr *attr);
>> +                                        struct switchdev_attr *attr,
>> +                                        struct switchdev_trans *trans);
>>       int     (*switchdev_port_obj_add)(struct net_device *dev,
>> -                                       struct switchdev_obj *obj);
>> +                                       struct switchdev_obj *obj,
>> +                                       struct switchdev_trans *trans);
>>       int     (*switchdev_port_obj_del)(struct net_device *dev,
>>                                         struct switchdev_obj *obj);
>>       int     (*switchdev_port_obj_dump)(struct net_device *dev,
>
> This version is better than the current state, but it's too bad we
> didn't get feedback yet on the real purpose of this 2-phase model...

Hmmm...I think I missed the question about the 2-phase model.  Let me
see if I can answer it here.

We got here first when working with stacked drivers and we wanted to
propagate an change (attr set or obj add) down the stack in a safe way
as to not leave hardware or software in an inconsistent state when
unexpected things happen.  The simple stacked driver example was two
switch ports bonded.  Setting an attr on the bond would propagate down
to each switch port.  If the setting stuck on the first port, but
didn't on the second port, we didn't want to have to go back and undo
the setting on the first port.  It gets messy real fast trying to
handle the undo operation.  So 2-phase model was suggested by davem to
solve the problem in a generic way.  First phase was to check with
each device in the stack if the operation is OK, and second phase
would commit operation.  The second phase cannot fail; the first phase
already said everything was OK to proceed.  That means no running out
of hardware resources in phase 2.  Phase 1 should have check/reserved
the resources.  And no OOM situations in phase 2.  And so on for other
detectable failures.

Stacked driver case is one case where the 2-phase model strives to
maintain hw/sw consistency.  I could see it working for batch
operations also, although we don't have any examples of batch
processing yet (in switchdev).

I'd rather keep 2-phase not optional, or at least make it some what of
a pain for drivers to opt-out of 2-phase.  Forcing the driver to see
both phases means the driver needs to put some code to skip phase 1
(and hopefully has some persistent comment explaining why its being
skipped).  Something like:

/* I'm skipping phase 1 prepare for this operation.  I have infinite hardware
 * resources and I'm not setting any persistent state in the driver or device
 * and I don't need any dynamic resources from the kernel, so its impossible
 * for me to fail phase 2 commit.  Nothing to prepare, sorry.
 */

-scott
