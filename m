From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: get rid of private net_device_stats
Date: Thu, 26 May 2016 05:54:10 -0700
Message-ID: <1464267250.5939.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	 <1464195039-5098-5-git-send-email-edumazet@google.com>
	 <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36639 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbcEZMyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 08:54:12 -0400
Received: by mail-pf0-f196.google.com with SMTP id g132so2269347pfb.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 05:54:12 -0700 (PDT)
In-Reply-To: <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-26 at 12:38 +0300, Tariq Toukan wrote:
> Hi Eric,
> 
> Thanks for the fix.
> 
> > We do not need to clear fields that are already 0.
> Why is it always true that dev->stats is already 0 at the point ndo_open 
> is called?
> Is it true also in a flow of open -> stop -> open? I searched the kernel 
> stack for this but couldn't find.
> > @@ -1877,7 +1877,6 @@ static void mlx4_en_clear_stats(struct net_device *dev)
> >   	if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
> >   		en_dbg(HW, priv, "Failed dumping statistics\n");
> >   
> > -	memset(&priv->stats, 0, sizeof(priv->stats));
> >   	memset(&priv->pstats, 0, sizeof(priv->pstats));
> >   	memset(&priv->pkstats, 0, sizeof(priv->pkstats));
> >   	memset(&priv->port_stats, 0, sizeof(priv->port_stats));
> The role of this function is to clear the stats, no matter when and 
> where it is called.
> I am aware that clearing the stats structure might be redundant today, 
> as the function is called only within mlx4_en_open, but we might want to 
> call the function in other flows in the future.

This is the ' non obvious fix' we need to discuss for net-next

When we enslave a mlx4 NIC in a bonding driver, we sometime get
incorrect bond stats because mlx4 stats are reset.

These stats being computed using deltas, this can not work as is.

I believe the rule is to not clear the netdev stats at open()

Anyway, for this particular path, it does not matter, as
mlx4_en_DUMP_ETH_STATS() will set all the fields to their value.
