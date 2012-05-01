From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] sky2: fix YUKON FE+ rev. A0, ingress VLAN tagged
 frame problem
Date: Tue, 1 May 2012 09:54:23 -0700
Message-ID: <20120501095423.4039457a@s6510.linuxnetplumber.net>
References: <1335887340-24284-1-git-send-email-cucchimichele@tiscali.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>, netdev@vger.kernel.org
To: Michele Cucchi <cucchimichele@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51725 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753532Ab2EAQy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 12:54:29 -0400
In-Reply-To: <1335887340-24284-1-git-send-email-cucchimichele@tiscali.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 May 2012 17:49:00 +0200
Michele Cucchi <cucchimichele@tiscali.it> wrote:

> The cards based on chip YUKON FE+ revision A0, fails to correctly receive VLAN tagged frames. The ingress frames stays on raw physical interface and don't reach VLANS allocated interfaces.
> The problem is the double call of __vlan_hwaccel_put_tag function, one in the sky2_skb_rx function and the other in the vlans global function vlan_untag.
> Adding a check of card version and revision in the sky2_skb_rx function allow to skip the first time call of __vlan_hwaccel_put_tag and to fix the problem.
> 
> This fix is tested on 3.4-rc5.
> 
> Signed-off-by: Michele Cucchi <cucchimichele@tiscali.it>
> ---
>  drivers/net/ethernet/marvell/sky2.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index c9b504e..2be0351 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -2649,7 +2649,10 @@ static inline void sky2_tx_done(struct net_device *dev, u16 last)
>  static inline void sky2_skb_rx(const struct sky2_port *sky2,
>  			       u32 status, struct sk_buff *skb)
>  {
> -	if (status & GMR_FS_VLAN)
> +	/* Workaround for YUKON FE+ rev. A0, vlan untag problem */
> +	if ((status & GMR_FS_VLAN) &&
> +	(!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
> +	sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0)))
>  		__vlan_hwaccel_put_tag(skb, be16_to_cpu(sky2->rx_tag));
>  
>  	if (skb->ip_summed == CHECKSUM_NONE)

A better solution to this was started by Mirko and revised by me.
It is was posted yesterday.
