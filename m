From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: sched: set tx_queue_len to default
 when changing noqueue device's qdisc
Date: Wed, 29 Jul 2015 23:10:45 +0200
Message-ID: <1438204245.20182.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
	 <1438203103-27013-2-git-send-email-phil@nwl.cc>
	 <1438203103-27013-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33046 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbbG2VKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:10:49 -0400
Received: by wicmv11 with SMTP id mv11so234491543wic.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 14:10:48 -0700 (PDT)
In-Reply-To: <1438203103-27013-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 22:51 +0200, Phil Sutter wrote:
> Virtual interfaces don't necessarily need a qdisc attached to them. This
> is signalled by setting dev->tx_queue_len to zero upon initialisation. The
> problems begin when a user still adds a qdisc, as then the special value
> is used as a regular one causing massive packet drops as soon as the
> device sees a bit of traffic load.
> 
> This patch solves the issue by setting tx_queue_len to the global
> default for physical devices if it is zero and a qdisc is added. Another
> benefit of this is that veth devices can default to noqueue while still
> preserving the expected behaviour when adding a qdisc.
> 
> The drawback of this patch is that the noqueue state won't be restored
> after a user has removed the custom qdisc, as the information about
> whether this is legitimate for the given device is lost.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  net/sched/sch_api.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index f06aa01..79b8900 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1315,6 +1315,10 @@ graft:
>  			qdisc_destroy(q);
>  		return err;
>  	}
> +	/* circumvent noqueue hack for virtual interfaces if
> +	 * user desires to use a qdisc on it */
> +	if (!dev->tx_queue_len)
> +		dev->tx_queue_len = CONFIG_DEFAULT_TX_QUEUE_LEN;
>  
>  	return 0;
>  }

This is still broken for htb : htb_init() would run before this,
and htb_init() does :


q->direct_qlen = qdisc_dev(sch)->tx_queue_len;

Really, I am not sure this can be changed. qdisc scripts are mostly
written by skilled people knowing if txqueuelen needs to be changed or
not...

Change the kernel behavior and scripts will break.
