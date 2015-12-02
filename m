From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 16/26] bonding: implement lower state change
 propagation
Date: Wed, 2 Dec 2015 12:40:51 +0100
Message-ID: <565ED8C3.3090709@cumulusnetworks.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-17-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37154 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757939AbbLBLkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 06:40:53 -0500
Received: by wmww144 with SMTP id w144so52953241wmw.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 03:40:52 -0800 (PST)
In-Reply-To: <1448977744-17930-17-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 02:48 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Let netdev notifier listeners know about link and slave state change.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/bonding/bond_main.c | 10 ++++++++++
>  include/net/bonding.h           |  7 +++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index c9943fc..e153a87 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1315,6 +1315,16 @@ void bond_queue_slave_event(struct slave *slave)
>  	queue_delayed_work(slave->bond->wq, &nnw->work, 0);
>  }
>  
> +void bond_lower_state_changed(struct slave *slave)
> +{
> +	struct netdev_lag_lower_state_info info;
> +
> +	info.link_up = slave->link == BOND_LINK_UP ||
> +		       slave->link == BOND_LINK_FAIL;
> +	info.tx_enabled = bond_is_active_slave(slave);
> +	netdev_lower_state_changed(slave->dev, &info);
> +}
> +

Hmm, but does this tell the listeners what changed ? I think it just
sends the current slave state and the listener has to decide what has
changed.
For example, right now it's possible for multiple identical events to
be sent (e.g. set_inactive_flags called two times on release, once because
of curr_active_slave change and second because of your set), the listeners
should be able to cope with that. For this same example I see that the mlxsw
will call mlxsw_sp_port_lag_changed() two times with the same values in that
case. I'm not saying this is necessarily bad, just noting it. :-)
