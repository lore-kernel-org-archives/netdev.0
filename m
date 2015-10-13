From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 5/7] bridge: defer switchdev fdb del call in
 fdb_del_external_learn
Date: Tue, 13 Oct 2015 08:05:42 +0200
Message-ID: <20151013060542.GC2242@nanopsycho.orion>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-4-git-send-email-jiri@resnulli.us>
 <CAE4R7bAhQ2gBp248KAhEEC27SrYZY8enxBjZsUoR_a4Bwq7DAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36323 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbbJMGFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:05:45 -0400
Received: by wicgb1 with SMTP id gb1so173614543wic.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:05:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAhQ2gBp248KAhEEC27SrYZY8enxBjZsUoR_a4Bwq7DAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 13, 2015 at 05:28:20AM CEST, sfeldma@gmail.com wrote:
>On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Since spinlock is held here, defer the switchdev operation.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  net/bridge/br_fdb.c | 5 ++++-
>>  net/bridge/br_if.c  | 3 +++
>>  2 files changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
>> index f5e7da0..c88bd8e 100644
>> --- a/net/bridge/br_fdb.c
>> +++ b/net/bridge/br_fdb.c
>> @@ -134,7 +134,10 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
>>  static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
>>  {
>>         struct switchdev_obj_port_fdb fdb = {
>> -               .obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
>> +               .obj = {
>> +                       .id = SWITCHDEV_OBJ_ID_PORT_FDB,
>> +                       .flags = SWITCHDEV_F_DEFER,
>> +               },
>>                 .vid = f->vlan_id,
>>         };
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index 934cae9..09147cb 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -24,6 +24,7 @@
>>  #include <linux/slab.h>
>>  #include <net/sock.h>
>>  #include <linux/if_vlan.h>
>> +#include <net/switchdev.h>
>>
>>  #include "br_private.h"
>>
>> @@ -249,6 +250,8 @@ static void del_nbp(struct net_bridge_port *p)
>>         list_del_rcu(&p->list);
>>
>>         br_fdb_delete_by_port(br, p, 0, 1);
>> +       switchdev_flush_deferred();
>> +
>
>This potentially flushes other (valid) work on the deferred queue not
>related to FDB del.

flush_deferred is implemented by flush_workqueue. This enforces the
workqueue to be processed heve and sleeps until it is done. Nothing is
lost.


>
>I wonder if this flush step is necessary at all?  The work we deferred
>to delete the FDB entry can still happen after the port has been
>removed (del_nbp).  If the port driver/device find the FDB entry, then
>delete it, otherwise ignore it.

This step is necessary. Consider following scenario:

spin_lock
switchdev_schedule_deferred (workx)
spin_unlock
netdev_upper_dev_unlink
workx is executed-> driver op is executed.

But during netdev_upper_dev_unlink, resources may have been removed, so
the workx after that would fail (this happens in case of rocker).

So I added switchdev_flush_deferred so the caller may force to safely
process the pending work in right time, for example after he released
the spinlock (after br_fdb_delete_by_port in this case).
