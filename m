From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 5/7] bridge: defer switchdev fdb del call in fdb_del_external_learn
Date: Mon, 12 Oct 2015 20:28:20 -0700
Message-ID: <CAE4R7bAhQ2gBp248KAhEEC27SrYZY8enxBjZsUoR_a4Bwq7DAg@mail.gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us> <1444672986-20709-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33584 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115AbbJMD2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 23:28:41 -0400
Received: by obbbh8 with SMTP id bh8so4021092obb.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 20:28:40 -0700 (PDT)
In-Reply-To: <1444672986-20709-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Since spinlock is held here, defer the switchdev operation.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br_fdb.c | 5 ++++-
>  net/bridge/br_if.c  | 3 +++
>  2 files changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index f5e7da0..c88bd8e 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -134,7 +134,10 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
>  static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
>  {
>         struct switchdev_obj_port_fdb fdb = {
> -               .obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
> +               .obj = {
> +                       .id = SWITCHDEV_OBJ_ID_PORT_FDB,
> +                       .flags = SWITCHDEV_F_DEFER,
> +               },
>                 .vid = f->vlan_id,
>         };
>
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 934cae9..09147cb 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -24,6 +24,7 @@
>  #include <linux/slab.h>
>  #include <net/sock.h>
>  #include <linux/if_vlan.h>
> +#include <net/switchdev.h>
>
>  #include "br_private.h"
>
> @@ -249,6 +250,8 @@ static void del_nbp(struct net_bridge_port *p)
>         list_del_rcu(&p->list);
>
>         br_fdb_delete_by_port(br, p, 0, 1);
> +       switchdev_flush_deferred();
> +

This potentially flushes other (valid) work on the deferred queue not
related to FDB del.

I wonder if this flush step is necessary at all?  The work we deferred
to delete the FDB entry can still happen after the port has been
removed (del_nbp).  If the port driver/device find the FDB entry, then
delete it, otherwise ignore it.
