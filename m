From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Thu, 5 Mar 2015 09:36:21 +0100
Message-ID: <20150305083621.GC2033@nanopsycho.orion>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:41963 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbbCEIgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 03:36:25 -0500
Received: by wevm14 with SMTP id m14so51389710wev.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 00:36:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 04, 2015 at 01:15:29AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
>on rocker ports, the second command (bridge link set) below will turn off
>learning in the rocker hw (Scott/Jiri, need some confirmation from
>you that this is indeed a problem and if the below patch is ok).
>
>ip link set dev swp1 master br0
>bridge link set dev swp1 learning off master
>bridge link set dev swp1 learning_sync on self
>
>This patch fixes rocker to ignore learning setting when 'master'
>is set. This makes it possible to set/unset learning in kernel and bridge
>driver independently.
>
>The below command will continue to set learning on in both kernel and rocker
>hw:
>bridge link set dev swp1 learning on
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>---
> drivers/net/ethernet/rocker/rocker.c |    3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index e5a15a4..d7c31d2 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
> 	struct nlattr *attr;
> 	int err;
> 
>+	if (flags && !(flags & BRIDGE_FLAGS_SELF))
>+		return 0;
>+

I think that the called should handle this case, not every particular
driver. How about to put this into rtnl_bridge_setlink?


> 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
> 				   IFLA_PROTINFO);
> 	if (protinfo) {
>-- 
>1.7.10.4
>
