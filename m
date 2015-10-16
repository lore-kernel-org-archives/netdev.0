From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 3/8] switchdev: allow caller to explicitly
 request attr_set as deferred
Date: Fri, 16 Oct 2015 10:23:48 +0200
Message-ID: <20151016082347.GC2194@nanopsycho.orion>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
 <1444844455-12508-4-git-send-email-jiri@resnulli.us>
 <561FC472.5030506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, David.Laight@ACULAB.COM, stephen@networkplumber.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35502 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbbJPIXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 04:23:51 -0400
Received: by lffy185 with SMTP id y185so75114352lff.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 01:23:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <561FC472.5030506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 15, 2015 at 05:21:22PM CEST, john.fastabend@gmail.com wrote:
>On 15-10-14 10:40 AM, Jiri Pirko wrote:
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
>
>A nit but the patch description should note your setting the defer bit
>on the bridge set state.
>
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
>>  #define SWITCHDEV_F_NO_RECURSE		BIT(0)
>>  #define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
>> +#define SWITCHDEV_F_DEFER		BIT(2)
>>  
>>  struct switchdev_trans_item {
>>  	struct list_head list;
>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>> index db6d243de..80c34d7 100644
>> --- a/net/bridge/br_stp.c
>> +++ b/net/bridge/br_stp.c
>> @@ -41,13 +41,14 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
>>  {
>>  	struct switchdev_attr attr = {
>>  		.id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>> +		.flags = SWITCHDEV_F_DEFER,
>>  		.u.stp_state = state,
>>  	};
>
>
>This creates a possible race (with 6/8) I think, please check!

Wait. This patch does not change the previous behaviour. Patch 6 does,
so I don't understand why you are asking here. Confusing.


>
>In del_nbp() we call br_stp_disable_port() to set the port state
>to BR_STATE_DISABLE and disabling learning events. But with this
>patch it can be deferred. Also note the STP agent may be in userspace
>which actually seems more likely the case because you likely want to
>run some more modern variant of STP than the kernel supports.
>
>So at some point in the future the driver will turn off learning. At
>the same time we call br_fdb_delete_by_port which calls a deferred
>set of fdb deletes.
>
>I don't see how you guarantee learning is off before you start doing
>the deletes here and possibly learning new addresses after the software
>side believes the port is down.
>
>So
>
>   br_stp_disable_port
>                           br_fdb_delete_by_port
>                           {fdb_del_external_learn}
>   [hw learns a fdb]
>   [hw disables learning]
>
>What stops this from happening?

Okay. This behaviour is the same as without the patchset. What would
resolve the issue it to put switchdev_deferred_process() after
br_stp_disable_port() and before br_fdb_delete_by_port() call.
That would enforce stp change to happen in hw before fdbs are explicitly
deleted. Sound good to you?



>
