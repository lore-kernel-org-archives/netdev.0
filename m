From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 0/3] net: switchdev: extract specific object structures
Date: Wed, 9 Sep 2015 09:25:14 -0700
Message-ID: <CAE4R7bDVNDUoxzRR8jtkOzEk7wvMZGNodMO=aRMUgz2KBxnQog@mail.gmail.com>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33518 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbbIIQZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 12:25:34 -0400
Received: by obbbh8 with SMTP id bh8so12303554obb.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 09:25:34 -0700 (PDT)
In-Reply-To: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 8, 2015 at 1:47 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Hi!
>
> Current implementations of .switchdev_port_obj_add and .switchdev_port_obj_dump
> must pass the generic switchdev_obj structure instead of a specific one (e.g.
> switchdev_obj_fdb) to the related driver accessors, because it contains the
> object transaction and callback. This is not very convenient for drivers.
>
> Instead of having all specific structures included into a switchdev_obj union,
> it would be simpler to embed a switchdev_obj structure as the first member of
> the more specific ones. That way, a driver can cast the switchdev_obj pointer
> to the specific structure and have access to all the information from it.
>
> As an example, this allows Rocker to change its two FDB accessors:
>
>     rocker_port_fdb_add(rocker_port, obj->trans, &obj->u.fdb);
>     rocker_port_fdb_dump(rocker_port, obj);
>
> for these most consistent ones:
>
>     fdb = (struct switchdev_obj_fdb *) obj;
>     rocker_port_fdb_add(rocker_port, fdb);
>     rocker_port_fdb_dump(rocker_port, fdb);
>
> This is what struct netdev_notifier_info and its specific supersets (e.g.
> struct netdev_notifier_changeupper_info) do in include/linux/netdevice.h.
>
> This patchset does that and updates bridge, Rocker and DSA accordingly.
>
> Note that this patchset was sent as an RFC not to bother David with new
> net-next stuffs, but if the changes look good, it is ready to merge.
>
> Also, please take note that the change sits on top of:
> http://patchwork.ozlabs.org/patch/514894/
>

HI Vivien, looks good. Some requests for the next version:

1) Move the cb() member out of struct switchdev_obj and into the
containing struct switchdev_obj_xxx structure.  This way the second
arg to cb() can be struct switchdev_obj_xxx *.  (And, I have pending
patches where the first arg to cb() is different, so making the dump
cb() func specific to obj type will help).

2) As already mentioned, use container_of where possible to avoid
locking struct member at a position within struct.

Should the same treatment be done for switchdev_attr?  Maybe that's a
second patchset.

-scott
