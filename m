From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net-next] tuntap: convert to 64-bit interface
 statistics
Date: Thu, 19 Mar 2015 14:38:29 -0700
Message-ID: <1426801109.25985.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Curt Brune <curt@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33635 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbbCSVia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:38:30 -0400
Received: by ignm3 with SMTP id m3so18838505ign.0
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 14:38:29 -0700 (PDT)
In-Reply-To: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 12:51 -0700, Jonathan Toppins wrote:
> Signed-off-by: Curt Brune <curt@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>  drivers/net/tun.c |   54 ++++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 43 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index b96b94c..be8941a 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -65,6 +65,7 @@
>  #include <linux/nsproxy.h>
>  #include <linux/virtio_net.h>
>  #include <linux/rcupdate.h>
> +#include <linux/u64_stats_sync.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  #include <net/rtnetlink.h>
> @@ -204,6 +205,9 @@ struct tun_struct {
>  	struct list_head disabled;
>  	void *security;
>  	u32 flow_count;
> +	spinlock_t			stat_lock;
> +	struct u64_stats_sync		stat_sync;
> +	struct rtnl_link_stats64	stats64;
>  };
>  
>  static inline u16 tun16_to_cpu(struct tun_struct *tun, __virtio16 val)
> @@ -751,6 +755,16 @@ static int tun_net_close(struct net_device *dev)
>  	return 0;
>  }
>  
> +static __always_inline void tun_stat64_inc(struct tun_struct *tun, u64 *stat,
> +					   size_t val)
> +{
> +	spin_lock_bh(&tun->stat_lock);
> +	u64_stats_update_begin(&tun->stat_sync);
> +	(*stat) += val;
> +	u64_stats_update_end(&tun->stat_sync);
> +	spin_unlock_bh(&tun->stat_lock);
> +}

Ouch, one spin_lock_bh() ? Really ?

> -	tun->dev->stats.tx_packets++;
> -	tun->dev->stats.tx_bytes += skb->len + vlan_hlen;
> +	tun_stat64_inc(tun, &tun->stats64.tx_packets, 1);
> +	tun_stat64_inc(tun, &tun->stats64.tx_bytes, skb->len + vlan_hlen);


So you take this spinlock twice ?

Sorry, this is not good.
