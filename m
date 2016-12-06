From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCHv2 net] team: team_port_add should check link_up before
 enable port
Date: Tue, 6 Dec 2016 09:22:33 +0100
Message-ID: <20161206082233.GD1984@nanopsycho>
References: <62f7aa9c00b68beed68a907c51dde22e7847d6c9.1481009348.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:33443 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbcLFIWg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 03:22:36 -0500
Received: by mail-wj0-f196.google.com with SMTP id kp2so42510240wjc.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 00:22:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <62f7aa9c00b68beed68a907c51dde22e7847d6c9.1481009348.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 06, 2016 at 08:29:08AM CET, lucien.xin@gmail.com wrote:
>Now when users add a nic to team dev, the option 'enable' of the port
>is true by default, as team_port_enable enables it after dev_open in
>team_port_add.
>
>But even if the port_dev has no carrier, like it's cable was unpluged,
>the port is still enabled. It leads to that team dev couldn't work well
>if this port was chosen to connect, and has no chance to change to use
>other ports if link_watch is ethtool.
>
>This patch is to enable the port only when the port_dev has carrier in
>team_port_add.
>
>v1 -> v2:
>  use netif_carrier_ok() instead of !!netif_carrier_ok(), as it returns
>  bool now.
>
>Signed-off-by: Xin Long <lucien.xin@gmail.com>
>---
> drivers/net/team/team.c | 8 ++++++--
> 1 file changed, 6 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index a380649..4bc0103 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1140,6 +1140,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
> 	struct net_device *dev = team->dev;
> 	struct team_port *port;
> 	char *portname = port_dev->name;
>+	bool linkup;
> 	int err;
> 
> 	if (port_dev->flags & IFF_LOOPBACK) {
>@@ -1249,9 +1250,12 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
> 
> 	port->index = -1;
> 	list_add_tail_rcu(&port->list, &team->port_list);
>-	team_port_enable(team, port);
>+	linkup = netif_carrier_ok(port_dev);
>+	if (linkup)
>+		team_port_enable(team, port);

This is obviously wrong change. It you use a simple setup without
userspace part (e.g. round robin), The port gets never enabled.
team_port_enabl is called from here and team_port_en_option_set.

By default, all ports should be enabled. Only in case the userspace
daemon decides to disable, it does so.

Could you send me the exact configuration where you see the issue?
This should be definitelly fixed in user part.

Thanks.
