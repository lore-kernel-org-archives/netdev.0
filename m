From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 3/8] switchdev: allow caller to explicitly
 request attr_set as deferred
Date: Thu, 15 Oct 2015 07:57:53 +0200
Message-ID: <20151015055753.GA2242@nanopsycho.orion>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
 <1444844455-12508-4-git-send-email-jiri@resnulli.us>
 <CAE4R7bAZbRYbc=2nWJjCjQ0dkz5HA+y4a7-H38cE6CYDtJ2PBA@mail.gmail.com>
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
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33964 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbbJOF54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 01:57:56 -0400
Received: by wicgb1 with SMTP id gb1so12469402wic.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 22:57:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAZbRYbc=2nWJjCjQ0dkz5HA+y4a7-H38cE6CYDtJ2PBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 15, 2015 at 06:34:01AM CEST, sfeldma@gmail.com wrote:
>On Wed, Oct 14, 2015 at 10:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Caller should know if he can call attr_set directly (when holding RTNL)
>> or if he has to defer the att_set processing for later.
>>
>> This also allows drivers to sleep inside attr_set and report operation
>> status back to switchdev core. Switchdev core then warns if status is
>> not ok, instead of silent errors happening in drivers.
>>
>> Benefit from newly introduced switchdev deferred ops infrastructure.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/switchdev.h   |   1 +
>>  net/bridge/br_stp.c       |   3 +-
>>  net/switchdev/switchdev.c | 108 ++++++++++++++++++----------------------------
>>  3 files changed, 46 insertions(+), 66 deletions(-)
>>
>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> index d1c7f90..f7de6f8 100644
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
>>                 br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
>>                                 (unsigned int) p->port_no, p->dev->name);
>>  }
>
>Should this part of the patch be moved to patch 6/8 where
>switchdev_deferred_process() is called from del_nbp()?

No, this part relates to the fact that attr_set now does not defer
automagically. So caller must say when to defer. So having this here is
correct.
