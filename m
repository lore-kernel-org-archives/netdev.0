From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 2/7] switchdev: allow caller to explicitly
 request attr_set as deferred
Date: Tue, 13 Oct 2015 09:30:20 +0200
Message-ID: <20151013073020.GF2242@nanopsycho.orion>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bCm+jOjhMH7wucCFhNd55Do_dJpqzixrtKZbCM4vG1dKw@mail.gmail.com>
 <20151013054414.GA2242@nanopsycho.orion>
 <561C9EC2.7030907@gmail.com>
 <20151013062112.GD2242@nanopsycho.orion>
 <CAE4R7bC4vik8-V9L5oTukQ4YhMoCGF_uOM_481fJgq3yc1LN=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34896 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbJMHaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 03:30:24 -0400
Received: by wicge5 with SMTP id ge5so177698761wic.0
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 00:30:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bC4vik8-V9L5oTukQ4YhMoCGF_uOM_481fJgq3yc1LN=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 13, 2015 at 08:53:45AM CEST, sfeldma@gmail.com wrote:
>On Mon, Oct 12, 2015 at 11:21 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 13, 2015 at 08:03:46AM CEST, john.fastabend@gmail.com wrote:
>>>On 15-10-12 10:44 PM, Jiri Pirko wrote:
>>>> Tue, Oct 13, 2015 at 04:52:42AM CEST, sfeldma@gmail.com wrote:
>>>>> On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>>>
>>>>>> Caller should know if he can call attr_set directly (when holding RTNL)
>>>>>> or if he has to defer the att_set processing for later.
>>>>>>
>>>>>> This also allows drivers to sleep inside attr_set and report operation
>>>>>> status back to switchdev core. Switchdev core then warns if status is
>>>>>> not ok, instead of silent errors happening in drivers.
>>>>>>
>>>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>>>> ---
>>>>>>  include/net/switchdev.h   |   1 +
>>>>>>  net/bridge/br_stp.c       |   3 +-
>>>>>>  net/switchdev/switchdev.c | 107 ++++++++++++++++++++++++----------------------
>>>>>>  3 files changed, 59 insertions(+), 52 deletions(-)
>>>>>>
>>>>>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>>>>> index d2879f2..6b109e4 100644
>>>>>> --- a/include/net/switchdev.h
>>>>>> +++ b/include/net/switchdev.h
>>>>>> @@ -17,6 +17,7 @@
>>>>>>
>>>>>>  #define SWITCHDEV_F_NO_RECURSE         BIT(0)
>>>>>>  #define SWITCHDEV_F_SKIP_EOPNOTSUPP    BIT(1)
>>>>>> +#define SWITCHDEV_F_DEFER              BIT(2)
>>>>>>
>>>>>>  struct switchdev_trans_item {
>>>>>>         struct list_head list;
>>>>>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>>>>>> index db6d243de..80c34d7 100644
>>>>>> --- a/net/bridge/br_stp.c
>>>>>> +++ b/net/bridge/br_stp.c
>>>>>> @@ -41,13 +41,14 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
>>>>>>  {
>>>>>>         struct switchdev_attr attr = {
>>>>>>                 .id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>>>>>> +               .flags = SWITCHDEV_F_DEFER,
>>>>>>                 .u.stp_state = state,
>>>>>>         };
>>>>>>         int err;
>>>>>>
>>>>>>         p->state = state;
>>>>>>         err = switchdev_port_attr_set(p->dev, &attr);
>>>>>> -       if (err && err != -EOPNOTSUPP)
>>>>>> +       if (err)
>>>>>
>>>>> This looks like a problem as now all other non-switchdev ports will
>>>>> get an WARN in the log when STP state changes.  We should only WARN if
>>>>> there was an err and the err is not -EOPNOTSUPP.
>>>>
>>>> If SWITCHDEV_F_DEFER flag is set, there's only 0 of -ENOMEM.
>>>>
>>>>
>>>>>
>>>>>>                 br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
>>>>>>                                 (unsigned int) p->port_no, p->dev->name);
>>>>>>  }
>>>>>
>>>>> <snip>
>>>>>
>>>>>>  struct switchdev_attr_set_work {
>>>>>>         struct work_struct work;
>>>>>>         struct net_device *dev;
>>>>>> @@ -183,14 +226,17 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
>>>>>>  {
>>>>>>         struct switchdev_attr_set_work *asw =
>>>>>>                 container_of(work, struct switchdev_attr_set_work, work);
>>>>>> +       bool rtnl_locked = rtnl_is_locked();
>>>>>>         int err;
>>>>>>
>>>>>> -       rtnl_lock();
>>>>>> -       err = switchdev_port_attr_set(asw->dev, &asw->attr);
>>>>>> +       if (!rtnl_locked)
>>>>>> +               rtnl_lock();
>>>>>
>>>>> I'm not following this change.  If someone else has rtnl_lock, we'll
>>>>> not wait to grab it here ourselves, and proceed as if we have the
>>>>> lock.  But what if that someone else releases the lock in the middle
>>>>> of us doing switchdev_port_attr_set_now?  Seems we want to
>>>>> unconditionally wait and grab the lock.  We need to block anything
>>>>>from moving while we do the attr set.
>>>>
>>>> Why would someone we call (driver) return the lock? In that case, he is
>>>> buggy and should be fixed.
>>>>
>>>> This hunk only ensures we have rtnl_lock. If not, we take it here. We do
>>>> not take it unconditionally because we may already have it, for example
>>>> if caller of switchdev_flush_deferred holds rtnl_lock.
>>>>
>>>
>>>This is where you lost me. How do you know another core doesn't happen
>>>to have the lock when you hit this code path? Maybe someone is running
>>>an ethtool command on another core or something.
>>
>> You are right. The same problem exists currently in switchdev_port_attr_set.
>
>You are right as in you'll change this back to unconditional grabbing
>of rtnl_lock?  I don't follow how this problem currently exists as
>current code does an unconditional grab of rtnl_lock.

  cpu1				cpu2
  				rtnl_lock()
switchdev_port_attr_set
  !rtnl_is_locked() == false
  switchdev_trans_init
 				rtnl_unlock()
  __switchdev_port_attr_set

now __switchdev_port_attr_set is called without rtnl_lock.

Would make sense to introduce rtnl_is_locked_by_me() or something.
