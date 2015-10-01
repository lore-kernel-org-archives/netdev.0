From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Wed, 30 Sep 2015 21:27:21 -0700
Message-ID: <CAE4R7bBooYJTBTUpb6zCRfoZs4N9VW1exfFBZgY5B1FmdQVtpg@mail.gmail.com>
References: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
 <20150925043640.GB18915@ketchup.lan> <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
 <20150924.225508.2124748200966556070.davem@davemloft.net> <20150925150303.GA21567@ketchup.mtl.sfl>
 <20150930185652.GA2455@ketchup.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
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
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36721 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbJAE1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 00:27:42 -0400
Received: by obcgx8 with SMTP id gx8so48574259obc.3
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 21:27:41 -0700 (PDT)
In-Reply-To: <20150930185652.GA2455@ketchup.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 11:56 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Hi all,
>
> On Sep. Friday 25 (39) 11:03 AM, Vivien Didelot wrote:
>> On Sep. Thursday 24 (39) 10:55 PM, David Miller wrote:
>> > From: Scott Feldman <sfeldma@gmail.com>
>> > Date: Thu, 24 Sep 2015 22:29:43 -0700
>> >
>> > > I'd rather keep 2-phase not optional, or at least make it some what of
>> > > a pain for drivers to opt-out of 2-phase.  Forcing the driver to see
>> > > both phases means the driver needs to put some code to skip phase 1
>> > > (and hopefully has some persistent comment explaining why its being
>> > > skipped).  Something like:
>> > >
>> > > /* I'm skipping phase 1 prepare for this operation.  I have infinite hardware
>> > >  * resources and I'm not setting any persistent state in the driver or device
>> > >  * and I don't need any dynamic resources from the kernel, so its impossible
>> > >  * for me to fail phase 2 commit.  Nothing to prepare, sorry.
>> > >  */
>> >
>> > I agree with Scott here.
>> >
>> > If you can opt out of something, you can not think about it and thus
>> > more likely get it wrong.
>> >
>> > I can just see a driver not implementing prepare at all and then doing
>> > stupid things in commit when they hit some resource limit or whatever,
>> > rather than taking care of such issues in prepare.
>>
>> OK, I have no experience with stacked devices nor what it actually looks
>> like, but I understand that it is a redundant setup where it makes sense
>> to ensure that an operation is feasible before programming the hardware.
>>
>> I agree with both of you on imposing switchdev drivers such notion.
>>
>> I was confused with the rtnl lock (from bridge netlink requests) which
>> seemed to limit a lot the usage of this prepare phase.
>>
>> I don't know the batch mode neither, but I can think about a potentially
>> powerful usage of the prepare phase in Marvell switches (or any basic
>> home router switches), please tell me if the following is feasible:
>>
>> Every hardware VLANs I know of are programmed with all port membership
>> in one shot. This is not feasible today with the bridge command. If I
>> could bundle in one request the equivalent of ("VID 100: 0u 1u 5t"):
>>
>>     bridge vlan add master dev swp0 vid 100 pvid untagged
>>     bridge vlan add master dev swp1 vid 100 pvid untagged
>>     bridge vlan add master dev swp5 vid 100 # cpu
>>
>> In such case the prepare phase could be great to allocate and populate a
>> VLAN entry structure (i.e. struct mv88e6xxx_vtu_stu_entry) before
>> programming the hardware *just once*. Is that doable?
>
> May I get answers for this? I'd need that in order to suggest a next
> step for the prepare phase in DSA drivers.

You know we're just making this all up as we go, right?  ;)

Actually, bringing real-world examples us think about solutions, so thank you.

A partial answer to your question, I guess, is to consider
switchdev_port_obj_add(dev, obj), which is basically:

   switchdev_port_obj_add(dev, obj)
       dev->ops->switchdev_port_obj_add(dev, obj, PREPARE)
       if no err
           dev->ops->switchdev_port_obj_add(dev, obj, COMMIT)
       else
           // abort transaction

Seems you could make a batch version that iterates over list of devs
to add the same obj:

   switchdev_port_obj_add_batch(devs, obj)
       for dev in devs:
           dev->ops->switchdev_port_obj_add(dev, obj, PREPARE)
       if no errs:
           for dev in devs:
               dev->ops->switchdev_port_obj_add(dev, obj, COMMIT)
       else
           // abort transaction (on all devs)

Who calls this _batch version with a list of devs is TBD.   Not sure
if you can get the -batch and -force options in iproute2 ip cmd to get
you here.

And as I look back at your example, you really have two diff objs in
your cmd list.  First obj is vlan 100 pvid untagged, second obj is
vlan 100.  Would this be two batches?  Oh, hmmm, maybe the batch
version iterates over list of {dev, obj} tuples.  Something like
(sorry, my pseudo code is turning into python):

   switchdev_port_obj_add_batch(dev_objs)
       for dev, obj in dev_objs.items:
           dev->ops->switchdev_port_obj_add(dev, obj, PREPARE)
       if no errs:
           for dev, obj in dev_objs.items:
               dev->ops->switchdev_port_obj_add(dev, obj, COMMIT)
       else
           // abort transaction (on all devs)

Does this help?  Maybe we should walk before running and focus on
getting non-batch ops working and then revisit?
