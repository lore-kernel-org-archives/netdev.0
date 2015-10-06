From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 06/14] rocker: introduce worlds infrastructure
Date: Tue, 6 Oct 2015 10:03:49 -0700
Message-ID: <CAE4R7bCbqVn2oUoxnCb3G6dFJrfV0JC+8Nce9CFAnwDsxsX1bg@mail.gmail.com>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
 <1444117913-10386-7-git-send-email-jiri@resnulli.us> <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com>
 <20151006161540.GK2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33689 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbbJFREJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 13:04:09 -0400
Received: by obbbh8 with SMTP id bh8so159149310obb.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 10:04:09 -0700 (PDT)
In-Reply-To: <20151006161540.GK2165@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 9:15 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 06, 2015 at 06:06:45PM CEST, sfeldma@gmail.com wrote:
>>On Tue, Oct 6, 2015 at 12:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This is another step on the way to per-world clean cut. Introduce world
>>> ops hooks which each world can implement in world-specific way.
>>> Also introduce world infrastructure including function for port worlds
>>> change.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>> v1->v2:
>>>  - removed functions to change worlds based on name, as rtnl mode
>>>    set patch is removed from patchset.
>>> v2->v3:
>>>  - fix checks in rocker_world_port_open and rocker_world_port_stop
>>> ---
>>>  drivers/net/ethernet/rocker/rocker.h      |  56 ++++
>>>  drivers/net/ethernet/rocker/rocker_main.c | 464 +++++++++++++++++++++++++++++-
>>>  2 files changed, 519 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
>>> index 650caa0..d49bc5d 100644
>>> --- a/drivers/net/ethernet/rocker/rocker.h
>>> +++ b/drivers/net/ethernet/rocker/rocker.h
>>> @@ -12,7 +12,11 @@
>>>  #ifndef _ROCKER_H
>>>  #define _ROCKER_H
>>>
>>> +#include <linux/kernel.h>
>>>  #include <linux/types.h>
>>> +#include <linux/netdevice.h>
>>> +#include <net/neighbour.h>
>>> +#include <net/switchdev.h>
>>>
>>>  #include "rocker_hw.h"
>>>
>>> @@ -24,4 +28,56 @@ struct rocker_desc_info {
>>>         dma_addr_t mapaddr;
>>>  };
>>>
>>> +struct rocker;
>>> +struct rocker_port;
>>> +
>>> +struct rocker_world_ops {
>>> +       const char *kind;
>>> +       size_t priv_size;
>>> +       size_t port_priv_size;
>>> +       u8 mode;
>>> +       int (*init)(struct rocker *rocker, void *priv);
>>> +       void (*fini)(void *priv);
>>> +       int (*port_init)(struct rocker_port *rocker_port, void *priv,
>>> +                        void *port_priv);
>>> +       void (*port_fini)(void *port_priv);
>>> +       int (*port_open)(void *port_priv);
>>> +       void (*port_stop)(void *port_priv);
>>> +       int (*port_attr_stp_state_set)(void *port_priv, u8 state,
>>> +                                      struct switchdev_trans *trans);
>>> +       int (*port_attr_bridge_flags_set)(void *port_priv,
>>> +                                         unsigned long brport_flags,
>>> +                                         struct switchdev_trans *trans);
>>> +       int (*port_attr_bridge_flags_get)(void *port_priv,
>>> +                                         unsigned long *p_brport_flags);
>>> +       int (*port_obj_vlan_add)(void *port_priv,
>>> +                                const struct switchdev_obj_port_vlan *vlan,
>>> +                                struct switchdev_trans *trans);
>>> +       int (*port_obj_vlan_del)(void *port_priv,
>>> +                                const struct switchdev_obj_port_vlan *vlan);
>>> +       int (*port_obj_vlan_dump)(void *port_priv,
>>> +                                 struct switchdev_obj_port_vlan *vlan,
>>> +                                 switchdev_obj_dump_cb_t *cb);
>>> +       int (*port_obj_fib4_add)(void *port_priv,
>>> +                                const struct switchdev_obj_ipv4_fib *fib4,
>>> +                                struct switchdev_trans *trans);
>>> +       int (*port_obj_fib4_del)(void *port_priv,
>>> +                                const struct switchdev_obj_ipv4_fib *fib4);
>>> +       int (*port_obj_fdb_add)(void *port_priv,
>>> +                               const struct switchdev_obj_port_fdb *fdb,
>>> +                               struct switchdev_trans *trans);
>>> +       int (*port_obj_fdb_del)(void *port_priv,
>>> +                               const struct switchdev_obj_port_fdb *fdb);
>>> +       int (*port_obj_fdb_dump)(void *port_priv,
>>> +                                struct switchdev_obj_port_fdb *fdb,
>>> +                                switchdev_obj_dump_cb_t *cb);
>>> +       int (*port_master_linked)(void *port_priv, struct net_device *master);
>>> +       int (*port_master_unlinked)(void *port_priv, struct net_device *master);
>>> +       int (*port_neigh_update)(void *port_priv, struct neighbour *n);
>>> +       int (*port_neigh_destroy)(void *port_priv, struct neighbour *n);
>>> +       int (*port_ev_mac_vlan_seen)(void *port_priv,
>>> +                                    const unsigned char *addr,
>>> +                                    __be16 vlan_id);
>>> +};
>>
>>Using void * in these ops is unacceptable, I can't agree to this patch.
>
> Could you please elaborate more why is it unacceptable. I don't see any
> problem in that.

void * is OK if you're passing around un-typed, TBD-sized objects.

Wait, this conversation doesn't even seem real.  You're really
advocating, publicly, the use of void * in ops callbacks, when the
pointer passed could be a well-typed pointer?

How could define a new API internal to the driver with void * as the main arg?

>>There is a much cleaner way to architect this.  If you look at the ops
>>defined, they're mostly duplicates of the already defined
>>switchdev_ops.  It would be much cleaner to:
>>
>>0) set port mode on qemu/rocker (the device)
>>1) get the port mode on port probe
>>2) based on port mode, set the switchdev_ops to point to the port mode
>>world switchdev_ops
>
> That will end up with 2 structs instead of one, not all of those
> callbacks are switchdev. Also, common part nicely picks cb by att/obj
> type. I'm finding this very nice. Not sure why you want to do it
> differently.

I'm suggesting a simpler path, that's why.  It's not necessary to add
all these new world ops for the port when they already exist with
switchdev_ops.  The none switchdev_ops cbs can hang off of
rocker_portand set on port probe once mode is known.

>>3) sub-class rocker_port, like I mentioned in before, to store
>>world-specific stuff in rocker_port
>>
>>I don't buy the argument that we need to change port mode dynamically
>>from the driver.  Set it at the device and be done.
>
> But why? just because of removal of completely legit use of "void *"?
> I don't understand, sorry.

I'll repeat: 1) because port mode can be set at the device during
device init; 2) there is no user benefit to setting it from the host,
3) setting it from the host dynamically creates all this unnecessary
work and indirection in the driver, which should be avoided.
