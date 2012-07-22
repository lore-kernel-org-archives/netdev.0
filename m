From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] Fix divide zero crash when xmit with no enabled port
Date: Sun, 22 Jul 2012 15:59:56 +0200
Message-ID: <20120722135956.GA12129@minipsycho.orion>
References: <20120721203035.71B4DFFC4A@master.hanzubon.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ISHIKAWA Mutsumi <ishikawa@hanzubon.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab2GVOAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 10:00:01 -0400
Content-Disposition: inline
In-Reply-To: <20120721203035.71B4DFFC4A@master.hanzubon.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 21, 2012 at 10:30:35PM CEST, ishikawa@hanzubon.jp wrote:
>
>hash calculation in lb_transmit() cause divide zero crash when
>xmit on teaming loadbalance mode with no team member port is enabled
>(this situation means team->en_port_count = 0). Add check
>team->en_port_count is not 0.

What kernel are you see the issue one?
I believe this is fixed in net-next already:

commit 122bb046bcfb8f3d2d94d9f7f6b74da187a740f2
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Tue Jun 26 06:52:45 2012 +0000

    team: fix team_adjust_ops with regard to enabled ports
    
    team_adjust_ops should check for enabled ports, not all ports.
    This may lead to division by zero. This patch fixes this.
    
    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>



>
>---
> drivers/net/team/team_mode_loadbalance.c |    2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
>index 86e8183..7b878d5 100644
>--- a/drivers/net/team/team_mode_loadbalance.c
>+++ b/drivers/net/team/team_mode_loadbalance.c
>@@ -38,6 +38,8 @@ static bool lb_transmit(struct team *team, struct sk_buff *skb)
> 	if (unlikely(!fp))
> 		goto drop;
> 	hash = SK_RUN_FILTER(fp, skb);
>+	if (team->en_port_count < 1)
>+		goto drop;
> 	port_index = hash % team->en_port_count;
> 	port = team_get_port_by_index_rcu(team, port_index);
> 	if (unlikely(!port))
>-- 
>1.7.10.4
>
