From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: DSA: Suspicious RCU usage (via rtnl_bridge_getlink)
Date: Tue, 20 Sep 2016 16:46:05 +0200
Message-ID: <20160920144605.GK1843@nanopsycho.orion>
References: <20160920102611.GO1041@n2100.armlinux.org.uk>
 <20160920133833.GD20638@lunn.ch>
 <87y42m3alm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:32842 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753797AbcITOqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:46:09 -0400
Received: by mail-lf0-f47.google.com with SMTP id h127so16941569lfh.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 07:46:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87y42m3alm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 20, 2016 at 04:32:53PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Hi Andrew, Russell,
>
>Andrew Lunn <andrew@lunn.ch> writes:
>
>> On Tue, Sep 20, 2016 at 11:26:12AM +0100, Russell King - ARM Linux wrote:
>>> Issuing "bridge vlan show" on clearfog provokes a "suspicious RCU usage"
>>> warning from the kernel (see below).
>>> 
>>> As it's illegal to schedule while holding the RCU read lock, there's the
>>> possibility for this happening much earlier in the call sequence -
>>> mv88e6xxx_port_vlan_dump() takes a mutex, and if that mutex were already
>>> held, we'd schedule at that point.  The RCU read lock was taken by
>>> rtnl_bridge_getlink().
>>> 
>>> It looks horrible to fix - mvmdio.c as well as DSA locking are involved.
>>
>> I would say this needs fixing higher up, in the bridge code. DSA has
>> to be able to sleep, since the switch can be on any arbitrary bus,
>> MDIO, SPI, etc. This will affect pure switchdev devices as well, since
>> they often need to send a request to the switch and wait for a reply.
>
>It looks similar to when a switchdev object/attribute is added/deleted
>without the SWITCHDEV_F_DEFER flag, used in the bridge code to defer
>switchdev operations until switchdev_deferred_process() is called.
>
>This is usually used to process switchdev ops outside the bridge lock.
>
>Jiri, can switchdev_port_vlan_fill not using SWITCHDEV_F_DEFER be the
>reason for this suspicious RCU usage when issuing "bridge vlan show"?

If it is called from atomic context, it should be deferred.


>
>Thanks,
>
>        Vivien
