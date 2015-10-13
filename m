From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 5/7] bridge: defer switchdev fdb del call in fdb_del_external_learn
Date: Mon, 12 Oct 2015 21:19:48 -0700
Message-ID: <CAE4R7bB1ARJEOuLzedaQrvbiK=YrbqDy3Vytas4JMotAeVS5mA@mail.gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us> <1444672986-20709-4-git-send-email-jiri@resnulli.us>
 <CAE4R7bAhQ2gBp248KAhEEC27SrYZY8enxBjZsUoR_a4Bwq7DAg@mail.gmail.com> <561C7B1B.90406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:35928 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbbJMEUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 00:20:09 -0400
Received: by obbrx8 with SMTP id rx8so4537604obb.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 21:20:08 -0700 (PDT)
In-Reply-To: <561C7B1B.90406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 8:31 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 15-10-12 08:28 PM, Scott Feldman wrote:
>> On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> Since spinlock is held here, defer the switchdev operation.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  net/bridge/br_fdb.c | 5 ++++-
>>>  net/bridge/br_if.c  | 3 +++
>>>  2 files changed, 7 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
>>> index f5e7da0..c88bd8e 100644
>>> --- a/net/bridge/br_fdb.c
>>> +++ b/net/bridge/br_fdb.c
>>> @@ -134,7 +134,10 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
>>>  static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
>>>  {
>>>         struct switchdev_obj_port_fdb fdb = {
>>> -               .obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
>>> +               .obj = {
>>> +                       .id = SWITCHDEV_OBJ_ID_PORT_FDB,
>>> +                       .flags = SWITCHDEV_F_DEFER,
>>> +               },
>>>                 .vid = f->vlan_id,
>>>         };
>>>
>>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>>> index 934cae9..09147cb 100644
>>> --- a/net/bridge/br_if.c
>>> +++ b/net/bridge/br_if.c
>>> @@ -24,6 +24,7 @@
>>>  #include <linux/slab.h>
>>>  #include <net/sock.h>
>>>  #include <linux/if_vlan.h>
>>> +#include <net/switchdev.h>
>>>
>>>  #include "br_private.h"
>>>
>>> @@ -249,6 +250,8 @@ static void del_nbp(struct net_bridge_port *p)
>>>         list_del_rcu(&p->list);
>>>
>>>         br_fdb_delete_by_port(br, p, 0, 1);
>>> +       switchdev_flush_deferred();
>>> +
>>
>> This potentially flushes other (valid) work on the deferred queue not
>> related to FDB del.
>>
>> I wonder if this flush step is necessary at all?  The work we deferred
>> to delete the FDB entry can still happen after the port has been
>> removed (del_nbp).  If the port driver/device find the FDB entry, then
>> delete it, otherwise ignore it.
>>
>
> Just the first thing that springs to mind reading this comment is,
>
>   - del gets deffered
>   - add fdb
>   - del runs
>
> Is there an issue here? Sorry I'll do a more thorough review now just
> thought I would toss it out there before I forget.

It's a valid thought to consider, for sure.  The context is these are
only FDB entries added by an external learn event.  So I believe in
your sequence, the second step to add fdb entry wouldn't happen as the
fdb entry already exists at that point (in other words, the entry has
already been learned on external device and pushed up via notifier to
bridge).  So I think we're OK in regards to your question.
