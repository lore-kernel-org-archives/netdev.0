From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Tue, 25 Nov 2014 14:20:14 -0800
Message-ID: <5475009E.8060608@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-9-git-send-email-jiri@resnulli.us> <20141125155832.GG27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33558 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbaKYWUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:20:18 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so1446862pad.31
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:20:17 -0800 (PST)
In-Reply-To: <20141125155832.GG27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 07:58, Andy Gospodarek wrote:
> On Tue, Nov 25, 2014 at 11:28:39AM +0100, Jiri Pirko wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To notify switch driver of change in STP state of bridge port, add new
>> .ndo op and provide switchdev wrapper func to call ndo op. Use it in bridge
>> code then.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

[snip]

>>  #include "br_private.h"
>>  #include "br_private_stp.h"
>> @@ -39,6 +40,7 @@ void br_log_state(const struct net_bridge_port *p)
>>  void br_set_state(struct net_bridge_port *p, unsigned int state)
>>  {
>>  	p->state = state;
>> +	netdev_switch_port_stp_update(p->dev, state);
> 
> The only thing that concerns me about this patch is the fact that there
> is nothing paying attention to the return code.
> 
> This means if *something* in the driver fails to set the STP state we
> have no way to feed this information back to the user to let them know
> that their hardware isn't exactly functioning as we expect.

This typically translates into an actual HW register write in general
(writing the STP algorithm result per-port), so although they typically
don't fail in most HW transports, I so no harm in returning something
useful just in case.

Once you do this, feel free to add a:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!

> 
> I do not expect that this first set would provide full feedback to
> br_make_forwarding, br_make_blocking, etc, to allow spanning tree to
> properly deal with the failure (that change is fine to add later), but a
> short one-liner indicating that the call to the hardware  failed would e
> good.  What about something simple like this:
> 
> void br_set_state(struct net_bridge_port *p, unsigned int state)
> {
> 	int ret;
> 	p->state = state;
> 	ret = netdev_switch_port_stp_update(p->dev, state);
> 	if (ret && ret != -EOPNOTSUPP)
> 		br_warn(br, "error setting offload STP state for interface %s\n",
> 			p->dev->name);
> }
> 
>>  
>>  /* called under bridge lock */
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index 66973de..d162b21 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -31,3 +31,22 @@ int netdev_switch_parent_id_get(struct net_device *dev,
>>  	return ops->ndo_switch_parent_id_get(dev, psid);
>>  }
>>  EXPORT_SYMBOL(netdev_switch_parent_id_get);
>> +
>> +/**
>> + *	netdev_switch_port_stp_update - Notify switch device port of STP
>> + *					state change
>> + *	@dev: port device
>> + *	@state: port STP state
>> + *
>> + *	Notify switch device port of bridge port STP state change.
>> + */
>> +int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>> +{
>> +	const struct net_device_ops *ops = dev->netdev_ops;
>> +
>> +	if (!ops->ndo_switch_port_stp_update)
>> +		return -EOPNOTSUPP;
>> +	WARN_ON(!ops->ndo_switch_parent_id_get);
>> +	return ops->ndo_switch_port_stp_update(dev, state);
>> +}
>> +EXPORT_SYMBOL(netdev_switch_port_stp_update);
>> -- 
>> 1.9.3
>>
