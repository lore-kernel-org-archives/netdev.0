From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 06/14] rocker: introduce worlds infrastructure
Date: Tue, 6 Oct 2015 10:08:26 -0700
Message-ID: <CAE4R7bAhc1HyrCxQfbfXUhQgME=UfjdVtF5PAyxy1Oe5g5EoTw@mail.gmail.com>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
 <1444117913-10386-7-git-send-email-jiri@resnulli.us> <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com>
 <5613F482.2010200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34604 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbbJFRIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 13:08:46 -0400
Received: by obbda8 with SMTP id da8so159507919obb.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 10:08:45 -0700 (PDT)
In-Reply-To: <5613F482.2010200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 9:19 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 15-10-06 09:06 AM, Scott Feldman wrote:
>> On Tue, Oct 6, 2015 at 12:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:
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
>> Using void * in these ops is unacceptable, I can't agree to this patch.
>>
>> There is a much cleaner way to architect this.  If you look at the ops
>> defined, they're mostly duplicates of the already defined
>> switchdev_ops.  It would be much cleaner to:
>>
>> 0) set port mode on qemu/rocker (the device)
>> 1) get the port mode on port probe
>> 2) based on port mode, set the switchdev_ops to point to the port mode
>> world switchdev_ops
>> 3) sub-class rocker_port, like I mentioned in before, to store
>> world-specific stuff in rocker_port
>>
>> I don't buy the argument that we need to change port mode dynamically
>> from the driver.  Set it at the device and be done.
>>
>
> Maybe as a reference this strikes me as similar to how we do multiple
> device support in a single driver like ixgbe or fm10k (the two I'm most
> familiar with). At probe time we read the device id and then stub in
> the specific callbacks for that device.

Exactly

> Sorry I'm still hung up on the multiple worlds thing, is it really
> trying to model different devices under a single driver? In which case
> maybe rather than port mode expose it as its own device id. Just a
> thought.

Yes, different devices under single driver.  New device ID or
sub-device ID will not work in this case as we're trying to slice it
at the port level, not the device level.
