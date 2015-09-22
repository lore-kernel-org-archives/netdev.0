From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] switchdev: introduce tranction enfra
 and for pre-commit split
Date: Tue, 22 Sep 2015 08:12:50 +0200
Message-ID: <20150922061250.GA2253@nanopsycho.orion>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bArD_uYEnsQtvYg94qsydtEJAjYwC9Q3ZfaZH8Wqs0SEQ@mail.gmail.com>
 <20150921080949.GC2141@nanopsycho.orion>
 <20150921171357.GA11812@ketchup.mtl.sfl>
 <20150921182539.GB2291@nanopsycho>
 <20150922013627.GA15460@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38351 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbbIVGMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 02:12:54 -0400
Received: by wiclk2 with SMTP id lk2so7774372wic.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 23:12:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150922013627.GA15460@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 22, 2015 at 03:36:28AM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Hi Jiri,
>
>On Sep. Monday 21 (39) 08:25 PM, Jiri Pirko wrote:
>> Mon, Sep 21, 2015 at 07:13:58PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>> >Hi Jiri, Scott,
>> >
>> >On Sep. Monday 21 (39) 10:09 AM, Jiri Pirko wrote:
>> >> Mon, Sep 21, 2015 at 09:23:24AM CEST, sfeldma@gmail.com wrote:
>> >> >On Sat, Sep 19, 2015 at 5:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >> >> Jiri Pirko (6):
>> >> >>   switchdev: rename "trans" to "trans_ph".
>> >> >>   switchdev: introduce transaction infrastructure for attr_set and
>> >> >>     obj_add
>> >> >>   rocker: switch to local transaction phase enum
>> >> >>   switchdev: move transaction phase enum under transaction structure
>> >> >>   rocker: use switchdev transaction queue for allocated memory
>> >> >>   switchdev: split commit and prepare phase into two callbacks
>> >> >
>> >> >Patches compile, but first test bombs.  Cut-and-paste of dump at end
>> >> >of this email.
>> >> 
>> >> Told you :)
>> >> 
>> >> 
>> >> >
>> >> >I'm not sure I'm liking this patchset because it looks like a way for
>> >> >switchdev drivers to easily opt-out of the prepare-commit transaction
>> >> >model by simply not implementing the *_pre op.  I would rather drivers
>> >> >explicitly handle the PREPARE phase in code, even if that means
>> >> >skipping it gracefully (in code) with a comment (in code) explaining
>> >> >why it does not matter for this device/operation.  That's what DSA had
>> >> >done, mostly because it was a retro-fit.
>> >> 
>> >> Each driver should handle this inside it. If it does not need prepare
>> >> state, it simply does not implement it. That is the same for all cb,
>> >> ndos, netdev notifiers, etc. It is much cleaner and nicer to have these as
>> >> separate callbacks. Implementing multiple callback in one is just ugly,
>> >> sorry.
>> >
>> >This is true, (in DSA) we don't have to implement the prepare phase if
>> >we fully support the feature in hardware.
>> >
>> >To give a real example, Marvell switch drivers currently implement all
>> >add/del/dump calls for VLAN FDB (where VID 0 means the port itself). No
>> >prepare phase needed.
>> >
>> >Now, I have local patches to enable strict 802.1Q mode in these switches
>> >(all the logic is based on the hardware VLAN table). But it does not use
>> >per-port FDB, so fdb_add with VID 0 doesn't make sense anymore. That's
>> >why we need to push the feature checking down to the drivers in DSA.
>> >
>> >I have another pending patch to add .port_fdb_pre_add, where mv88e6xxx
>> >code will return -EOPNOTSUPP if the given VID is 0.
>> >
>> >Another example: mv88e6xxx support tagged VLANs, so no hardware check
>> >needed. But the Broadcom Starfighter 2 only supports port-based VLANs
>> >(which is today wrongly implemented through "bridge_join/leave"). By
>> >implementing .port_vlan_pre_add (another pending patch for DSA), the
>> >driver will be able to return -EOPNOTSUPP if !BRIDGE_VLAN_INFO_PVID.
>> >
>> >Also, having logic in switchdev drivers to check SWITCHDEV_TRANS_NONE
>> >and SWITCHDEV_TRANS_ABORT is not really nice. Having switchdev handle
>> >the abort phase (calling each destructor) and getting rid of the
>> >SWITCHDEV_TRANS_* flags sounds better to me.
>> 
>> Agree, if pre/commit is going to be in one function, we should have
>> only prepare/commit enums. It can be carried around as a single bool
>> value in switchdev_trans structure. Will include that in my transaction
>> patchset.
>> 
>> 
>> >
>> >> >Also, the patchset removes the ABORT callback in case of a rollback
>> >> >due to a failed PREPARE.  We can't make the assumption that it's just
>> >> >a memory list to destroy on ABORT.  The driver, on PREPARE, may have
>> >> >reserved device space or staged an operation on the device which we'll
>> >> >need to undo on ABORT.
>> >> 
>> >> Yep, just register an item with custom destructor, there you can do
>> >> whatever. Also, I believe much nicer comparing to current code.
>> >> 
>> >> 
>> >> >
>> >> >So we need ABORT back, and we need PREPARE to not be optional, so
>> >> >what's left list enqueue/dequeue helpers, which I'm not seeing much
>> >> >value in up-leveling as the driver can do list_add/del itself.
>> >> 
>> >> Why would every driver do it itself, over and over when there can be a
>> >> clean infrastructure to do that. Including abort phase. Without the driver
>> >> needed to be involved.
>> >
>> >Maybe the term ".destructor" has a too strong meaning to deallocation,
>> >but you can indeed do whatever you need in this function.
>> 
>> It is a destructor. Don't know about a better name, suggestions?
>
>Nope, I'm personally fine with this term.
>
>> >
>> >> >Am I missing something?  I didn't see a motivation statement for the
>> >> >RFC so I'm not sure where you wanted to take this.
>> >> 
>> >> I want to make current code much nicer, easier to read and implement in
>> >> other drivers. Look at rocker.c and how often there is == PREPARE there.
>> >> It's nearly impossible to followthe code, sorry.
>> >> 
>> >> My next patchset is to un-mess rocker.c (that freaking ofdpa stuff is
>> >> everywhere)
>> >
>> >I'm basically for this patchset, but I do have some concerns about the
>> >general switchdev transaction design.
>> >
>> >I certainly don't have the perspective that you guys have, so please
>> >tell me if I'm totally wrong. From my point of view (with DSA drivers),
>> >the emphase should be done on asking the hardware if it can handle or
>> >not a given transaction (not simply an hardware feature!).
>> >
>> >The driver can handle any allocation and preparation itself, and also
>> >errors can actually occur *during* a commit phase.
>> 
>> But during commit phase, the odds that error is going to happen is a lot
>> smaller. Prepare phase should resolve all common fails like memory
>> allocations and resource limitation checks.
>
>With mv88e6xxx, we do MDIO calls in the commit phase that we don't do in
>the prepare phase, and they can actually fail.
>
>switchdev assumes that no error can occur during a commit, this is
>wrong. It also triggers a WARN() in that case, which is bad IMHO.
>
>The prepare phase tries to help drivers with allocation and partial
>checking, while this can be nice, it is not even switch-specific. That
>can totally be done at the driver level, if it needs to.
>
>I'm really trying to understand what is the real value behind this two
>phases model, but looking at really use cases like DSA, I can't see one.
>
>Maybe DSA is a specific case. Do you have a concrete example of
>situation where a switch or driver would really need this pre-phase?
>
>> 
>> >
>> >Being able to return -EOPNOTSUPP from any add/del/dump function would be
>> >just perfect.
>> 
>> Looking at this, I agree that for switchdev_port_obj_add and
>> switchdev_port_attr_set if would make more sense to return 0 in case of
>> hw does not actuall support. Callers check for -EOPNOTSUP and treat
>> that as 0 anyway. Feel free to send a patch for this.
>
>I am not sure to understand. Are you suggesting to make the prepare
>phase optional? Something like this:
>
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -186,7 +186,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
> 
> 	attr->trans = SWITCHDEV_TRANS_COMMIT;
> 	err = __switchdev_port_attr_set(dev, attr);
>-	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
>+	WARN(err != -EOPNOTSUPP, "%s: Commit of attribute (id=%d) failed.\n",
> 	     dev->name, attr->id);
> 
> 	return err;
>@@ -266,7 +266,8 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
> 
> 	obj->trans = SWITCHDEV_TRANS_COMMIT;
> 	err = __switchdev_port_obj_add(dev, obj);
>-	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
>+	WARN(err != -EOPNOTSUPP, "%s: Commit of object (id=%d) failed.\n",
>+	     dev->name, obj->id);
> 
> 	return err;
> }
>
>
>If yes, that would allow simple driver like DSA to return 0 in the
>prepare phrase (to basically ignore it) and let the drivers eventually
>return -EOPNOTSUPP in the commit phase, which is way more simple.
>
>But then, is there really a need for the prepare phase again?

I have very similar doubts about prepare-commit phases as you have.
Scott, DaveM, any comments?
