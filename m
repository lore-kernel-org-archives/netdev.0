From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] dsa: bonding: implement HW bonding
Date: Fri, 20 Feb 2015 09:56:26 -0800
Message-ID: <54E7754A.3070407@cumulusnetworks.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com> <1424429473-4601-2-git-send-email-jonasj76@gmail.com> <54E763A6.4020505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jonas Johansson <jonasj76@gmail.com>, netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:39711 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbbBTR43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 12:56:29 -0500
Received: by pdjy10 with SMTP id y10so9149615pdj.6
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 09:56:28 -0800 (PST)
In-Reply-To: <54E763A6.4020505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/20/15, 8:41 AM, Florian Fainelli wrote:
> On 20/02/15 02:51, Jonas Johansson wrote:
>> From: Jonas Johansson <jonas.johansson@westermo.se>
>>
>> This patch will implement hooks for hardware bonding support for the DSA
>> driver. When the team driver adds a DSA slave port the port will be assigned
>> a bond group id and the DSA slave driver can setup the hardware. When team
>> changes the port state (enabled/disabled) the DSA slave driver is able to
>> use the attach/detach callback which will allow the hardware to change the
>> hardware settings to reflect the state.
>>
>> Added DSA hooks:
>>   bond_add_group: To add a port to a bond group
>>   bond_del_group: To remove a port from a bond group
>>   bond_attach: To mark the port in a bond group as attached/active
>>   bond_detach: To unmark the port in a bond group as detach/inactive
>>
>> Added new network device hooks:
>>   ndo_bond_attach: To attach a device to a bond group.
>>   ndo_bond_detach: To detach a device from a bond group.
>>
>> Team:
>>   Added callback to ndo_bond_attach when port is enabled.
>>   Added callback to ndo_bond_detach when port is disabled.
>>
>> Added DSA notifier:
>>   Listening on NETDEV_CHANGEUPPER to add or deleta a port to/from a bond group.
>>
>> Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
>> ---
>>   drivers/net/team/team.c   |  4 ++++
>>   include/linux/netdevice.h |  8 +++++++
>>   include/net/dsa.h         |  8 +++++++
>>   net/dsa/dsa.c             | 60 +++++++++++++++++++++++++++++++++++++++++++++++
>>   net/dsa/dsa_priv.h        |  6 +++++
>>   net/dsa/slave.c           | 23 ++++++++++++++++++
>>   6 files changed, 109 insertions(+)
>>
>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>> index 0e62274..f7b2afb 100644
>> --- a/drivers/net/team/team.c
>> +++ b/drivers/net/team/team.c
>> @@ -934,6 +934,8 @@ static void team_port_enable(struct team *team,
>>   		team->ops.port_enabled(team, port);
>>   	team_notify_peers(team);
>>   	team_mcast_rejoin(team);
>> +	if (port->dev->netdev_ops->ndo_bond_attach)
>> +		port->dev->netdev_ops->ndo_bond_attach(port->dev);
>>   }
>>   
>>   static void __reconstruct_port_hlist(struct team *team, int rm_index)
>> @@ -965,6 +967,8 @@ static void team_port_disable(struct team *team,
>>   	team_adjust_ops(team);
>>   	team_notify_peers(team);
>>   	team_mcast_rejoin(team);
>> +	if (port->dev->netdev_ops->ndo_bond_detach)
>> +		port->dev->netdev_ops->ndo_bond_detach(port->dev);
>>   }
> Do we really need new ndos here? Cannot we learn this via
> NETDEV_CHANGEUPPER?

+1, I was just typing a similar response. We need this for switchdevices 
too and notifiers can be used here.
