From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 06/13] rocker: introduce worlds infrastructure
Date: Tue, 6 Oct 2015 09:43:55 +0200
Message-ID: <20151006074355.GB2165@nanopsycho.orion>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
 <1444067046-27825-7-git-send-email-jiri@resnulli.us>
 <CAE4R7bA3dZ79U-Wg28m94=ZJBPRRQ2Xq=uM73ZrK5i2tNug=mg@mail.gmail.com>
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
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37636 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbbJFHn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:43:58 -0400
Received: by wicfx3 with SMTP id fx3so146082499wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:43:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bA3dZ79U-Wg28m94=ZJBPRRQ2Xq=uM73ZrK5i2tNug=mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 06, 2015 at 07:16:29AM CEST, sfeldma@gmail.com wrote:
>On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
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
>Yuck, void *.  Can we do better?

I see nothing wrong with this priv usage. It's done like this on many
places. I think it is completely legit, since the call points are well
defined and wrapped.


>
>How about using base struct rocker_port and then sub-classing
>world-specific rocker ports.  And make rocker_world_ops pass struct
>rocker_port * (for the port-centric ops).
>
>struct rocker_port {
>    // common stuff for all worlds
>};
>
>struct my_world_port {
>    struct rocker_port rocker_port;
>    // world-specific stuff for port
>};
>
>#define MY_WORLD_PORT(rocker_port) \
>        container_of(rocker_port, struct my_world_port, rocker_port)
>
>Same for world-centric ops:
>
>struct rocker_world {
>   // common stuff for all worlds
>};
>
>struct my_world {
>    struct rocker_world rocker_world;
>    // stuff for this world
>};

This would be unnecessary complex. + this cannot be done because you
would have to know the world in advance of creating the structs and you
would not be able to switch it. No, not a good idea.


>
>
>> +static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
>> +                                             const unsigned char *addr,
>> +                                             __be16 vlan_id);
>>
>>  static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
>>                                       const struct rocker_tlv *info)
>> @@ -1246,6 +1252,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
>>         const unsigned char *addr;
>>         int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
>>         __be16 vlan_id;
>> +       int err;
>>
>>         rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
>>         if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_PPORT] ||
>> @@ -1262,6 +1269,10 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
>>
>>         rocker_port = rocker->ports[port_number];
>>
>> +       err = rocker_world_port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
>> +       if (err)
>> +               return err;
>> +
>
>Why is this in this patch?
>
>> +static int rocker_world_port_attr_stp_state_set(struct rocker_port *rocker_port,
>> +                                               u8 state,
>> +                                               struct switchdev_trans *trans)
>> +{
>> +       struct rocker_world *world = rocker_port->world;
>> +
>> +       if (!world->ops->port_attr_stp_state_set)
>> +               return 0;
>
>Should return -EOPNOTSUPP.   Returning 0 means the operation
>succeeded.   I would like to avoid silent failures.  If the user does
>something to a port, and the operation is not supported on the port,
>return -EOPNOTSUPP so user gets some feedback that operation failed.
>Returning 0 gives the user feedback that the operation succeeded, when
>in fact nothing happened at all.

At this stage of the patchset, this has to return 0 in order not to
break the flows.

-EOPNOTSUPP is treated like 0 upper in callers anyway. But I agree that
we can return -OPNOTSUPP in these cases. Will add a patch that changes
this to the end of the patchset.


>
>> +       return world->ops->port_attr_stp_state_set(rocker_port->world_port_priv,
>> +                                                  state, trans);
>> +}
>> +
>> +static int
>> +rocker_world_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
>> +                                       unsigned long brport_flags,
>> +                                       struct switchdev_trans *trans)
>> +{
>> +       struct rocker_world *world = rocker_port->world;
>> +
>> +       if (!world->ops->port_attr_bridge_flags_set)
>> +               return 0;
>
>Same comment, pretty much down the list...
