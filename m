From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Sat, 7 Mar 2015 14:57:29 +0100
Message-ID: <20150307135729.GA2017@nanopsycho.orion>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
 <20150306071617.GA2011@nanopsycho.orion>
 <54FA006D.3010604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:39084 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbbCGN5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 08:57:35 -0500
Received: by wghn12 with SMTP id n12so11323577wgh.6
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 05:57:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54FA006D.3010604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 06, 2015 at 08:30:53PM CET, sridhar.samudrala@intel.com wrote:
>
>On 3/5/2015 11:16 PM, Jiri Pirko wrote:
>>Thu, Mar 05, 2015 at 10:48:35PM CET, sridhar.samudrala@intel.com wrote:
>>>With this patch ethtool <team> OR cat /sys/class/net/<team>/speed
>>>returns the speed of team based on member ports speed and state.
>>>
>>>Based on get speed support in bonding driver.
>>>
>>>Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>>---
>>>drivers/net/team/team.c | 25 +++++++++++++++++++++++++
>>>1 file changed, 25 insertions(+)
>>>
>>>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>>>index 9d3366f..e822803 100644
>>>--- a/drivers/net/team/team.c
>>>+++ b/drivers/net/team/team.c
>>>@@ -1954,6 +1954,30 @@ static int team_change_carrier(struct net_device *dev, bool new_carrier)
>>>	return 0;
>>>}
>>>
>>>+static int team_ethtool_get_settings(struct net_device *dev,
>>>+				     struct ethtool_cmd *ecmd)
>>>+{
>>>+	struct team *team = netdev_priv(dev);
>>>+	struct team_port *port;
>>>+	unsigned long speed = 0;
>>>+
>>>+	ecmd->duplex = DUPLEX_UNKNOWN;
>>>+	ecmd->port = PORT_OTHER;
>>>+
>>>+	mutex_lock(&team->lock);
>>>+	list_for_each_entry(port, &team->port_list, list) {
>>>+		if (port->linkup)
>>>+			speed += port->state.speed;
>>>+		if (ecmd->duplex == DUPLEX_UNKNOWN &&
>>>+		    port->state.duplex != 0)
>>>+			ecmd->duplex = port->state.duplex;
>>>+	}
>>>+	ethtool_cmd_speed_set(ecmd, speed);
>>>+	mutex_unlock(&team->lock);
>>>+
>>>+	return 0;
>>>+}
>>Sridar, what exactly you are trying to achieve? I agree with DaveM that
>>this make no sense for soft devices. The fact bonding has it is a
>>mistake.
>>
>We are currently looking into the possibility of using team as a way to
>offload link aggregation support to switch hardware.
>To support LAG, a team device is created and the switch ports are added
>as members of the team. We are considering if we should create a new team
>mode specifically to support offload or the existing modes can be extended
>to enable offloading. Will appreciate any thoughts you have on this?

No, please no special modes. That is unacceptable. Just use what exists,
extend it if needed, then offload it. That is the way to go.


>
>For the specific usecase of a team where all the member ports correspond
>to offloaded switch ports, does it make sense to support getting speed OR
>we should just leave it to the mgmt apps to figure out the speed based on
>the speed of the member ports?


I do not see any reason for it. mgmt app can find out how devices are
stacked and can query the port devices directly. No need to pretend
something on team layer for it.


Jiri

>
>Thanks
>Sridhar
>
>
