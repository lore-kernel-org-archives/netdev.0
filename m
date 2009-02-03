From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Don't update statistics counters when interface
	is down
Date: Tue, 3 Feb 2009 22:46:41 +0100
Message-ID: <20090203214641.GA354@electric-eye.fr.zoreil.com>
References: <1233677686-11591-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48707 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751007AbZBCVo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 16:44:57 -0500
Content-Disposition: inline
In-Reply-To: <1233677686-11591-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
> Some Realtek chips (RTL8169sb/8110sb in my case) are unable to retrieve
> ethtool statistics when the interface is down. The process stays in
> endless loop in rtl8169_get_ethtool_stats. This is because these chips
> need to have receiver enabled (CmdRxEnb bit in ChipCmd register) that is
> cleared when the interface is going down. It's better to update statistics
> only when the interface is up and otherwise return copy of statistics
> grabbed when the interface was up (in rtl8169_close).

It makes sense.

[...]
> +static void rtl8169_update_counters(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  	void __iomem *ioaddr = tp->mmio_addr;
>  	struct rtl8169_counters *counters;
>  	dma_addr_t paddr;
>  	u32 cmd;
> +	int wait = 1000;
>  
> -	ASSERT_RTNL();
> +	if (!netif_running(dev))
> +		return;


int dev_close(struct net_device *dev)
{
[...]
	clear_bit(__LINK_STATE_START, &dev->state);
        -> netif_running is not true anymore
[...]
	if (ops->ndo_stop)
		ops->ndo_stop(dev);

-> Calling rtl8169_update_counters in rtl8169_close looks like a no-op.

Aside from that, I do not understand from the description the need for
the "while (wait--)" loop.

Aside from the aside, the diff can probably be shorter if a local "counters"
variable is kept in the ethtool function (nit).

-- 
Ueimor
