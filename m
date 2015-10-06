From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 06/14] rocker: introduce worlds infrastructure
Date: Tue, 6 Oct 2015 18:15:41 +0200
Message-ID: <20151006161540.GK2165@nanopsycho.orion>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
 <1444117913-10386-7-git-send-email-jiri@resnulli.us>
 <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36458 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbJFQPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 12:15:44 -0400
Received: by wicgb1 with SMTP id gb1so172913294wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 09:15:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 06, 2015 at 06:06:45PM CEST, sfeldma@gmail.com wrote:
>On Tue, Oct 6, 2015 at 12:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> This is another step on the way to per-world clean cut. Introduce world
>> ops hooks which each world can implement in world-specific way.
>> Also introduce world infrastructure including function for port worlds
>> change.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> v1->v2:
>>  - removed functions to change worlds based on name, as rtnl mode
>>    set patch is removed from patchset.
>> v2->v3:
>>  - fix checks in rocker_world_port_open and rocker_world_port_stop
>> ---
>>  drivers/net/ethernet/rocker/rocker.h      |  56 ++++
>>  drivers/net/ethernet/rocker/rocker_main.c | 464 +++++++++++++++++++++++++++++-
>>  2 files changed, 519 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
>> index 650caa0..d49bc5d 100644
>> --- a/drivers/net/ethernet/rocker/rocker.h
>> +++ b/drivers/net/ethernet/rocker/rocker.h
>> @@ -12,7 +12,11 @@
>>  #ifndef _ROCKER_H
>>  #define _ROCKER_H
>>
>> +#include <linux/kernel.h>
>>  #include <linux/types.h>
>> +#include <linux/netdevice.h>
>> +#include <net/neighbour.h>
>> +#include <net/switchdev.h>
>>
>>  #include "rocker_hw.h"
>>
>> @@ -24,4 +28,56 @@ struct rocker_desc_info {
>>         dma_addr_t mapaddr;
>>  };
>>
>> +struct rocker;
>> +struct rocker_port;
>> +
>> +struct rocker_world_ops {
>> +       const char *kind;
>> +       size_t priv_size;
>> +       size_t port_priv_size;
>> +       u8 mode;
>> +       int (*init)(struct rocker *rocker, void *priv);
>> +       void (*fini)(void *priv);
>> +       int (*port_init)(struct rocker_port *rocker_port, void *priv,
>> +                        void *port_priv);
>> +       void (*port_fini)(void *port_priv);
>> +       int (*port_open)(void *port_priv);
>> +       void (*port_stop)(void *port_priv);
>> +       int (*port_attr_stp_state_set)(void *port_priv, u8 state,
>> +                                      struct switchdev_trans *trans);
>> +       int (*port_attr_bridge_flags_set)(void *port_priv,
>> +                                         unsigned long brport_flags,
>> +                                         struct switchdev_trans *trans);
>> +       int (*port_attr_bridge_flags_get)(void *port_priv,
>> +                                         unsigned long *p_brport_flags);
>> +       int (*port_obj_vlan_add)(void *port_priv,
>> +                                const struct switchdev_obj_port_vlan *vlan,
>> +                                struct switchdev_trans *trans);
>> +       int (*port_obj_vlan_del)(void *port_priv,
>> +                                const struct switchdev_obj_port_vlan *vlan);
>> +       int (*port_obj_vlan_dump)(void *port_priv,
>> +                                 struct switchdev_obj_port_vlan *vlan,
>> +                                 switchdev_obj_dump_cb_t *cb);
>> +       int (*port_obj_fib4_add)(void *port_priv,
>> +                                const struct switchdev_obj_ipv4_fib *fib4,
>> +                                struct switchdev_trans *trans);
>> +       int (*port_obj_fib4_del)(void *port_priv,
>> +                                const struct switchdev_obj_ipv4_fib *fib4);
>> +       int (*port_obj_fdb_add)(void *port_priv,
>> +                               const struct switchdev_obj_port_fdb *fdb,
>> +                               struct switchdev_trans *trans);
>> +       int (*port_obj_fdb_del)(void *port_priv,
>> +                               const struct switchdev_obj_port_fdb *fdb);
>> +       int (*port_obj_fdb_dump)(void *port_priv,
>> +                                struct switchdev_obj_port_fdb *fdb,
>> +                                switchdev_obj_dump_cb_t *cb);
>> +       int (*port_master_linked)(void *port_priv, struct net_device *master);
>> +       int (*port_master_unlinked)(void *port_priv, struct net_device *master);
>> +       int (*port_neigh_update)(void *port_priv, struct neighbour *n);
>> +       int (*port_neigh_destroy)(void *port_priv, struct neighbour *n);
>> +       int (*port_ev_mac_vlan_seen)(void *port_priv,
>> +                                    const unsigned char *addr,
>> +                                    __be16 vlan_id);
>> +};
>
>Using void * in these ops is unacceptable, I can't agree to this patch.

Could you please elaborate more why is it unacceptable. I don't see any
problem in that.


>
>There is a much cleaner way to architect this.  If you look at the ops
>defined, they're mostly duplicates of the already defined
>switchdev_ops.  It would be much cleaner to:
>
>0) set port mode on qemu/rocker (the device)
>1) get the port mode on port probe
>2) based on port mode, set the switchdev_ops to point to the port mode
>world switchdev_ops

That will end up with 2 structs instead of one, not all of those
callbacks are switchdev. Also, common part nicely picks cb by att/obj
type. I'm finding this very nice. Not sure why you want to do it
differently.


>3) sub-class rocker_port, like I mentioned in before, to store
>world-specific stuff in rocker_port
>
>I don't buy the argument that we need to change port mode dynamically
>from the driver.  Set it at the device and be done.

But why? just because of removal of completely legit use of "void *"?
I don't understand, sorry.
