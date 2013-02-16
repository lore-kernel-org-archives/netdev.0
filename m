From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v4] netpoll: fix some sparse warnings in various
 places
Date: Sat, 16 Feb 2013 10:18:08 +0100
Message-ID: <20130216091808.GA1536@minipsycho.orion>
References: <1361003873-20622-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:51246 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787Ab3BPJSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 04:18:12 -0500
Received: by mail-ea0-f178.google.com with SMTP id a14so1691200eaa.23
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 01:18:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1361003873-20622-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 16, 2013 at 09:37:53AM CET, amwang@redhat.com wrote:
>From: Cong Wang <amwang@redhat.com>
>
>This fixes sparse warnings like the one below:
>
>drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
>drivers/net/team/team.c:953:25:    expected struct netpoll_info *
>drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo
>
>Cc: Eric Dumazet <eric.dumazet@gmail.com>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: Vlad Yasevich <vyasevic@redhat.com>
>Cc: Stephen Hemminger <stephen@networkplumber.org>
>Cc: David S. Miller <davem@davemloft.net>
>Signed-off-by: Cong Wang <amwang@redhat.com>
>
>---
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 94c1534..71ad0f2 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1302,7 +1302,7 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
> 
> static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> {
>-	return bond->dev->npinfo;
>+	return rcu_access_pointer(bond->dev->npinfo);
> }
> 
> #else
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 05c5efe..03e5949 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -950,7 +950,7 @@ static void team_port_disable_netpoll(struct team_port *port)
> 
> static struct netpoll_info *team_netpoll_info(struct team *team)
> {
>-	return team->dev->npinfo;
>+	return rcu_access_pointer(team->dev->npinfo);
> }
> 
> #else
>diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>index 6d314c4..699d5c4 100644
>--- a/net/bridge/br_private.h
>+++ b/net/bridge/br_private.h
>@@ -330,7 +330,7 @@ extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
> #ifdef CONFIG_NET_POLL_CONTROLLER
> static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
> {
>-	return br->dev->npinfo;
>+	return rcu_access_pointer(br->dev->npinfo);
> }
> 
> static inline void br_netpoll_send_skb(const struct net_bridge_port *p,


Hmm. I'm just wondering if there wouldn't be nicer for these functions to
return bool if you just want to know if npinfo is null or not. This
notation seems a bit confusing to me.
