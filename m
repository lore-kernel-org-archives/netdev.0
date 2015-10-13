From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v4 2/7] switchdev: allow caller to explicitly
 request attr_set as deferred
Date: Mon, 12 Oct 2015 21:40:25 -0700
Message-ID: <561C8B39.20604@gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us> <1444672986-20709-1-git-send-email-jiri@resnulli.us> <CAE4R7bCm+jOjhMH7wucCFhNd55Do_dJpqzixrtKZbCM4vG1dKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33677 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbbJMEkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 00:40:43 -0400
Received: by pabrc13 with SMTP id rc13so8824262pab.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 21:40:42 -0700 (PDT)
In-Reply-To: <CAE4R7bCm+jOjhMH7wucCFhNd55Do_dJpqzixrtKZbCM4vG1dKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-12 07:52 PM, Scott Feldman wrote:
> On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Caller should know if he can call attr_set directly (when holding RTNL)
>> or if he has to defer the att_set processing for later.
>>
>> This also allows drivers to sleep inside attr_set and report operation
>> status back to switchdev core. Switchdev core then warns if status is
>> not ok, instead of silent errors happening in drivers.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/switchdev.h   |   1 +
>>  net/bridge/br_stp.c       |   3 +-
>>  net/switchdev/switchdev.c | 107 ++++++++++++++++++++++++----------------------
>>  3 files changed, 59 insertions(+), 52 deletions(-)
>>
>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> index d2879f2..6b109e4 100644
>> --- a/include/net/switchdev.h
>> +++ b/include/net/switchdev.h
>> @@ -17,6 +17,7 @@
>>
>>  #define SWITCHDEV_F_NO_RECURSE         BIT(0)
>>  #define SWITCHDEV_F_SKIP_EOPNOTSUPP    BIT(1)
>> +#define SWITCHDEV_F_DEFER              BIT(2)
>>
>>  struct switchdev_trans_item {
>>         struct list_head list;
>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>> index db6d243de..80c34d7 100644
>> --- a/net/bridge/br_stp.c
>> +++ b/net/bridge/br_stp.c
>> @@ -41,13 +41,14 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
>>  {
>>         struct switchdev_attr attr = {
>>                 .id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>> +               .flags = SWITCHDEV_F_DEFER,
>>                 .u.stp_state = state,
>>         };
>>         int err;
>>
>>         p->state = state;
>>         err = switchdev_port_attr_set(p->dev, &attr);
>> -       if (err && err != -EOPNOTSUPP)
>> +       if (err)
> 
> This looks like a problem as now all other non-switchdev ports will
> get an WARN in the log when STP state changes.  We should only WARN if
> there was an err and the err is not -EOPNOTSUPP.
> 
>>                 br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
>>                                 (unsigned int) p->port_no, p->dev->name);
>>  }
> 
> <snip>
> 
>>  struct switchdev_attr_set_work {
>>         struct work_struct work;
>>         struct net_device *dev;
>> @@ -183,14 +226,17 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
>>  {
>>         struct switchdev_attr_set_work *asw =
>>                 container_of(work, struct switchdev_attr_set_work, work);
>> +       bool rtnl_locked = rtnl_is_locked();
>>         int err;
>>
>> -       rtnl_lock();
>> -       err = switchdev_port_attr_set(asw->dev, &asw->attr);
>> +       if (!rtnl_locked)
>> +               rtnl_lock();
> 
> I'm not following this change.  If someone else has rtnl_lock, we'll
> not wait to grab it here ourselves, and proceed as if we have the
> lock.  But what if that someone else releases the lock in the middle
> of us doing switchdev_port_attr_set_now?  Seems we want to
> unconditionally wait and grab the lock.  We need to block anything
> from moving while we do the attr set.
> 

Also an additional race between setting rtnl_locked and the if stmt
and then grabbing the lock. There seems to be a something of pattern
around this where other subsystems use a rtnl_trylock and if it fails
do a restart/re-queue operation to retry. Looks like how you handle
it in the team driver at least.

>> +       err = switchdev_port_attr_set_now(asw->dev, &asw->attr);
>>         if (err && err != -EOPNOTSUPP)
>>                 netdev_err(asw->dev, "failed (err=%d) to set attribute (id=%d)\n",
>>                            err, asw->attr.id);
>> -       rtnl_unlock();
>> +       if (!rtnl_locked)
>> +               rtnl_unlock();
>>
>>         dev_put(asw->dev);
>>         kfree(work);
>> @@ -211,7 +257,7 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
>>         asw->dev = dev;
>>         memcpy(&asw->attr, attr, sizeof(asw->attr));
>>
>> -       schedule_work(&asw->work);
>> +       queue_work(switchdev_wq, &asw->work);
>>
>>         return 0;
>>  }
