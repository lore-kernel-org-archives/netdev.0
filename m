From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Fri, 6 Mar 2015 21:42:41 -0500
Message-ID: <20150307024241.GB502@gospo.home.greyhouse.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
 <20150306071617.GA2011@nanopsycho.orion>
 <54FA006D.3010604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:41596 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbbCGCmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 21:42:45 -0500
Received: by qcvx3 with SMTP id x3so27058923qcv.8
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 18:42:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54FA006D.3010604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 06, 2015 at 11:30:53AM -0800, Samudrala, Sridhar wrote:
> 
> On 3/5/2015 11:16 PM, Jiri Pirko wrote:
> >Thu, Mar 05, 2015 at 10:48:35PM CET, sridhar.samudrala@intel.com wrote:
> >>With this patch ethtool <team> OR cat /sys/class/net/<team>/speed
> >>returns the speed of team based on member ports speed and state.
> >>
> >>Based on get speed support in bonding driver.
> >>
> >>Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> >>---
> >>drivers/net/team/team.c | 25 +++++++++++++++++++++++++
> >>1 file changed, 25 insertions(+)
> >>
> >>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> >>index 9d3366f..e822803 100644
> >>--- a/drivers/net/team/team.c
> >>+++ b/drivers/net/team/team.c
> >>@@ -1954,6 +1954,30 @@ static int team_change_carrier(struct net_device *dev, bool new_carrier)
> >>	return 0;
> >>}
> >>
> >>+static int team_ethtool_get_settings(struct net_device *dev,
> >>+				     struct ethtool_cmd *ecmd)
> >>+{
> >>+	struct team *team = netdev_priv(dev);
> >>+	struct team_port *port;
> >>+	unsigned long speed = 0;
> >>+
> >>+	ecmd->duplex = DUPLEX_UNKNOWN;
> >>+	ecmd->port = PORT_OTHER;
> >>+
> >>+	mutex_lock(&team->lock);
> >>+	list_for_each_entry(port, &team->port_list, list) {
> >>+		if (port->linkup)
> >>+			speed += port->state.speed;
> >>+		if (ecmd->duplex == DUPLEX_UNKNOWN &&
> >>+		    port->state.duplex != 0)
> >>+			ecmd->duplex = port->state.duplex;
> >>+	}
> >>+	ethtool_cmd_speed_set(ecmd, speed);
> >>+	mutex_unlock(&team->lock);
> >>+
> >>+	return 0;
> >>+}
> >Sridar, what exactly you are trying to achieve? I agree with DaveM that
> >this make no sense for soft devices. The fact bonding has it is a
> >mistake.
> >
> We are currently looking into the possibility of using team as a way to
> offload link aggregation support to switch hardware.
> To support LAG, a team device is created and the switch ports are added
> as members of the team. We are considering if we should create a new team
> mode specifically to support offload or the existing modes can be extended
> to enable offloading. Will appreciate any thoughts you have on this?

There is no real need to create an offload mode for teaming or bonding.
There is actually a similar thread happening right now to discuss how to
offload bonding to hardware, I would suggest browsing that and
discussing in that thread[1].

FWIW, we offload bonding right now without much issue by monitoring
netlink events.  All the hardware really needs to know is the membership
information and the hash algorithm the user might like to set and both
of those are available on recent kernels via netlink.  Based on the
hardware we are using and the in-kernel infrastructure that existed at
the time it was the proper choice.

1. [PATCH net-next 0/2] dsa: implement HW bonding
http://patchwork.ozlabs.org/patch/441907/
