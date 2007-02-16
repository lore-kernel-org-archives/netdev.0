From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Fri, 16 Feb 2007 08:59:36 +0100
Message-ID: <20070216075936.GB1599@ff.dom.local>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:59057 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966178AbXBPH4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 02:56:21 -0500
Content-Disposition: inline
In-Reply-To: <20070215223744.GC19840@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15-02-2007 23:37, Francois Romieu wrote:
> Your usual dont-flush_scheduled_work-with-RTNL-held stuff.
> 
> It is a bit different here since the thread runs permanently
> or is only occasionally kicked for recovery depending on the
> hardware revision.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/8139too.c |   40 +++++++++++++++++-----------------------
>  1 files changed, 17 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> index 35ad5cf..99304b2 100644
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -1109,6 +1109,8 @@ static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
>  
>  	assert (dev != NULL);
>  
> +	flush_scheduled_work();
> +

IMHO there should be rather cancel_rearming_delayed_work
instead of this.

>  	unregister_netdev (dev);
>  
>  	__rtl8139_cleanup_dev (dev);
> @@ -1603,18 +1605,21 @@ static void rtl8139_thread (struct work_struct *work)
>  	struct net_device *dev = tp->mii.dev;
>  	unsigned long thr_delay = next_tick;
>  
> +	rtnl_lock();
> +
> +	if (!netif_running(dev))
> +		goto out_unlock;

I wonder, why you don't do netif_running before
rtnl_lock? It's an atomic operation.

And I'm not sure if increasing rtnl_lock range
is really needed here.

Regards,
Jarek P.
