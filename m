From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Fri, 06 Mar 2015 11:30:53 -0800
Message-ID: <54FA006D.3010604@intel.com>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com> <20150306071617.GA2011@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36013 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756839AbbCFTay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 14:30:54 -0500
In-Reply-To: <20150306071617.GA2011@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 3/5/2015 11:16 PM, Jiri Pirko wrote:
> Thu, Mar 05, 2015 at 10:48:35PM CET, sridhar.samudrala@intel.com wrote:
>> With this patch ethtool <team> OR cat /sys/class/net/<team>/speed
>> returns the speed of team based on member ports speed and state.
>>
>> Based on get speed support in bonding driver.
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> ---
>> drivers/net/team/team.c | 25 +++++++++++++++++++++++++
>> 1 file changed, 25 insertions(+)
>>
>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>> index 9d3366f..e822803 100644
>> --- a/drivers/net/team/team.c
>> +++ b/drivers/net/team/team.c
>> @@ -1954,6 +1954,30 @@ static int team_change_carrier(struct net_device *dev, bool new_carrier)
>> 	return 0;
>> }
>>
>> +static int team_ethtool_get_settings(struct net_device *dev,
>> +				     struct ethtool_cmd *ecmd)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	unsigned long speed = 0;
>> +
>> +	ecmd->duplex = DUPLEX_UNKNOWN;
>> +	ecmd->port = PORT_OTHER;
>> +
>> +	mutex_lock(&team->lock);
>> +	list_for_each_entry(port, &team->port_list, list) {
>> +		if (port->linkup)
>> +			speed += port->state.speed;
>> +		if (ecmd->duplex == DUPLEX_UNKNOWN &&
>> +		    port->state.duplex != 0)
>> +			ecmd->duplex = port->state.duplex;
>> +	}
>> +	ethtool_cmd_speed_set(ecmd, speed);
>> +	mutex_unlock(&team->lock);
>> +
>> +	return 0;
>> +}
> Sridar, what exactly you are trying to achieve? I agree with DaveM that
> this make no sense for soft devices. The fact bonding has it is a
> mistake.
>
We are currently looking into the possibility of using team as a way to
offload link aggregation support to switch hardware.
To support LAG, a team device is created and the switch ports are added
as members of the team. We are considering if we should create a new team
mode specifically to support offload or the existing modes can be extended
to enable offloading. Will appreciate any thoughts you have on this?

For the specific usecase of a team where all the member ports correspond
to offloaded switch ports, does it make sense to support getting speed OR
we should just leave it to the mgmt apps to figure out the speed based on
the speed of the member ports?

Thanks
Sridhar
