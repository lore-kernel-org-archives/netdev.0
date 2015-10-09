From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Thu, 8 Oct 2015 20:31:53 -0700
Message-ID: <CAE4R7bBvG5s5agx6PkqVF+OAXdiAY5iiBKpgH5N7x5DQ_+FgfA@mail.gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com> <CAGVrzca-PQ6kbW+KCi_LWOs0zqCgicoB2sNrK=kViECRu7sH4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36712 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbbJIDcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 23:32:13 -0400
Received: by obcgx8 with SMTP id gx8so53625219obc.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 20:32:12 -0700 (PDT)
In-Reply-To: <CAGVrzca-PQ6kbW+KCi_LWOs0zqCgicoB2sNrK=kViECRu7sH4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 7:40 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2015-10-08 19:23 GMT-07:00  <sfeldma@gmail.com>:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
>> support setting ageing_time (or setting bridge attrs in general).
>>
>> If push fails, don't update ageing_time in bridge and return err to user.
>>
>> If push succeeds, update ageing_time in bridge and run gc_timer now to
>> recalabrate when to run gc_timer next, based on new ageing_time.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/bridge/br_ioctl.c    |    3 +--
>>  net/bridge/br_netlink.c  |    6 +++---
>>  net/bridge/br_private.h  |    1 +
>>  net/bridge/br_stp.c      |   23 +++++++++++++++++++++++
>>  net/bridge/br_sysfs_br.c |    3 +--
>>  5 files changed, 29 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
>> index 8d423bc..263b4de 100644
>> --- a/net/bridge/br_ioctl.c
>> +++ b/net/bridge/br_ioctl.c
>> @@ -200,8 +200,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>>                 if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
>>                         return -EPERM;
>>
>> -               br->ageing_time = clock_t_to_jiffies(args[1]);
>> -               return 0;
>> +               return br_set_ageing_time(br, args[1]);
>>
>>         case BRCTL_GET_PORT_INFO:
>>         {
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index d78b442..544ab96 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -870,9 +870,9 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
>>         }
>>
>>         if (data[IFLA_BR_AGEING_TIME]) {
>> -               u32 ageing_time = nla_get_u32(data[IFLA_BR_AGEING_TIME]);
>> -
>> -               br->ageing_time = clock_t_to_jiffies(ageing_time);
>> +               err = br_set_ageing_time(br, nla_get_u32(data[IFLA_BR_AGEING_TIME]));
>> +               if (err)
>> +                       return err;
>>         }
>>
>>         if (data[IFLA_BR_STP_STATE]) {
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 09d3ecb..ba0c67b 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -882,6 +882,7 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
>>  int br_set_forward_delay(struct net_bridge *br, unsigned long x);
>>  int br_set_hello_time(struct net_bridge *br, unsigned long x);
>>  int br_set_max_age(struct net_bridge *br, unsigned long x);
>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time);
>>
>>
>>  /* br_stp_if.c */
>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>> index 3a982c0..db6d243de 100644
>> --- a/net/bridge/br_stp.c
>> +++ b/net/bridge/br_stp.c
>> @@ -566,6 +566,29 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
>>
>>  }
>>
>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
>> +{
>> +       struct switchdev_attr attr = {
>> +               .id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>> +               .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>> +               .u.ageing_time = ageing_time,
>> +       };
>> +       unsigned long t = clock_t_to_jiffies(ageing_time);
>> +       int err;
>> +
>> +       if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>> +               return -ERANGE;
>> +
>> +       err = switchdev_port_attr_set(br->dev, &attr);
>> +       if (err)
>> +               return err;
>> +
>> +       br->ageing_time = t;
>> +       mod_timer(&br->gc_timer, jiffies);
>
> If the switch driver/HW supports ageing, does it still make sense to
> have this software timer ticking?

Yes, because the bridge still needs to age out entries it has learned
(those not marked with added_by_external_learn), for example entries
learned on non-offloaded ports.
