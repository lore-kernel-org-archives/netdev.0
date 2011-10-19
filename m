From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: introduce ethernet teaming device
Date: Wed, 19 Oct 2011 19:39:28 +0200
Message-ID: <20111019173927.GA2922@minipsycho>
References: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
 <20111019172624.GB21324@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757070Ab1JSRjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 13:39:47 -0400
Content-Disposition: inline
In-Reply-To: <20111019172624.GB21324@synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 19, 2011 at 07:26:24PM CEST, benjamin.poirier@gmail.com wrote:
>Hi Jiri, just a few late comments:
>
>On 11/10/04 16:15, Jiri Pirko wrote:
>> This patch introduces new network device called team. It supposes to be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>> 
>> Userspace library called libteam with couple of demo apps is available
>> here:
>> https://github.com/jpirko/libteam
>> Note it's still in its dipers atm.
>> 
>> team<->libteam use generic netlink for communication. That and rtnl
>> suppose to be the only way to configure team device, no sysfs etc.
>> 
>> In near future python binding for libteam will be introduced. Also
>> daemon providing arpmon/miimon active-backup functionality will
>> be introduced. All what's necessary is already implemented in kernel team
>> driver.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>[...]
>
>> +/******************************
>> + * Round-robin mode definition
>> + ******************************/
>> +
>> +static struct team_port *__get_first_port_up(struct team *team,
>> +					     struct team_port *port)
>
>This is more like __get_"next"_port_up() no?

Might be.

>
>> +{
>> +	struct team_port *cur;
>> +
>> +	if (port->linkup)
>> +		return port;
>> +	cur = port;
>> +	list_for_each_entry_continue_rcu(cur, &team->port_list, list)
>> +		if (cur->linkup)
>> +			return cur;
>> +	list_for_each_entry_rcu(cur, &team->port_list, list) {
>> +		if (cur == port)
>> +			break;
>> +		if (cur->linkup)
>> +			return cur;
>> +	}
>> +	return NULL;
>> +}
>> +
>
>[...]
>
>> +
>> +
>> +/****************
>> + * Mode handling
>> + ****************/
>> +
>> +static const struct team_mode *team_modes[] = {
>> +	&rr_mode,
>> +	&ab_mode,
>> +};
>> +
>> +static const int team_mode_count = ARRAY_SIZE(team_modes);
>> +
>> +static int team_find_mode(const char *kind)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < team_mode_count; i++) {
>> +		const struct team_mode *mode = team_modes[i];
>> +
>> +		if (strcmp(mode->kind, kind) == 0)
>> +			return i;
>> +	}
>> +	return -ENOENT;
>> +}
>> +
>> +/*
>> + * We can benefit from the fact that it's ensured no port is present
>> + * at the time of mode change.
>> + */
>> +static void __team_change_mode(struct team *team, const int mode_index)
>> +{
>> +	const struct team_mode *mode = team_modes[mode_index];
>
>team_uninit() calls __team_change_mode(team, -1) which will therefore
>dereference team_modes[-1]. Is this always safe?

I changed this bits. New patch is coming soon...

Thanks.

Jirka

>
>-Ben
