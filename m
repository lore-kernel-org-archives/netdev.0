From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] team: allow userspace to take control over
 carrier
Date: Tue, 5 Feb 2013 22:16:45 +0100
Message-ID: <20130205211645.GA1560@minipsycho.orion>
References: <1360092655-28223-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:42856 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228Ab3BEVQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 16:16:50 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi8so829065wib.13
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 13:16:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360092655-28223-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 05, 2013 at 08:30:55PM CET, fbl@redhat.com wrote:
>Some modes don't require any special carrier handling so
>in these cases, the kernel can control the carrier as for
>any other interface.  However, some other modes, e.g. lacp,
>requires more than just that, so userspace needs to control
>the carrier itself.
>
>The daemon today is ready to control it, but the kernel
>still can change it based on events.
>
>This fix so that either kernel or userspace is controlling
>the carrier.
>
>Signed-off-by: Flavio Leitner <fbl@redhat.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>


>---
> drivers/net/team/team.c | 8 ++++++++
> include/linux/if_team.h | 1 +
> 2 files changed, 9 insertions(+)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 694ccf6..05c5efe 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -508,6 +508,7 @@ static bool team_is_mode_set(struct team *team)
> 
> static void team_set_no_mode(struct team *team)
> {
>+	team->user_carrier_enabled = false;
> 	team->mode = &__team_no_mode;
> }
> 
>@@ -1710,6 +1711,10 @@ static netdev_features_t team_fix_features(struct net_device *dev,
> 
> static int team_change_carrier(struct net_device *dev, bool new_carrier)
> {
>+	struct team *team = netdev_priv(dev);
>+
>+	team->user_carrier_enabled = true;
>+
> 	if (new_carrier)
> 		netif_carrier_on(dev);
> 	else
>@@ -2573,6 +2578,9 @@ static void __team_carrier_check(struct team *team)
> 	struct team_port *port;
> 	bool team_linkup;
> 
>+	if (team->user_carrier_enabled)
>+		return;
>+
> 	team_linkup = false;
> 	list_for_each_entry(port, &team->port_list, list) {
> 		if (port->linkup) {
>diff --git a/include/linux/if_team.h b/include/linux/if_team.h
>index 0245def..4648d80 100644
>--- a/include/linux/if_team.h
>+++ b/include/linux/if_team.h
>@@ -186,6 +186,7 @@ struct team {
> 
> 	const struct team_mode *mode;
> 	struct team_mode_ops ops;
>+	bool user_carrier_enabled;
> 	bool queue_override_enabled;
> 	struct list_head *qom_lists; /* array of queue override mapping lists */
> 	long mode_priv[TEAM_MODE_PRIV_LONGS];
>-- 
>1.8.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
