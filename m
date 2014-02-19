From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net] veth: Fix vlan_features so as to be able to use
 stacked vlan interfaces
Date: Wed, 19 Feb 2014 01:13:57 -0300
Message-ID: <20140219041357.GB2491@localhost.localdomain>
References: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbaBSEOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 23:14:16 -0500
Content-Disposition: inline
In-Reply-To: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 09:20:08PM +0900, Toshiaki Makita wrote:
> Even if we create a stacked vlan interface such as veth0.10.20, it sends
> single tagged frames (tagged with only vid 10).
> Because vlan_features of a veth interface has the
> NETIF_F_HW_VLAN_[CTAG/STAG]_TX bits, veth0.10 also has that feature, so
> dev_hard_start_xmit(veth0.10) doesn't call __vlan_put_tag() and
> vlan_dev_hard_start_xmit(veth0.10) overwrites vlan_tci.
> This prevents us from using a combination of 802.1ad and 802.1Q
> in containers, etc.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  drivers/net/veth.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 2ec2041..5b37437 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -285,7 +285,8 @@ static void veth_setup(struct net_device *dev)
>  	dev->ethtool_ops = &veth_ethtool_ops;
>  	dev->features |= NETIF_F_LLTX;
>  	dev->features |= VETH_FEATURES;
> -	dev->vlan_features = dev->features;
> +	dev->vlan_features = dev->features &
> +			     ~(NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX);
>  	dev->destructor = veth_dev_free;
>  
>  	dev->hw_features = VETH_FEATURES;
> -- 
> 1.8.1.2
> 

Why that isn't a problem with another software device?
Although this patch might fix the issue, it seems to me that
the middle devices shouldn't use the same feature flags.
I mean, vlan.20 should add the header, then vlan.10 should
offload the tag to veth.  Otherwise, for any vlan on top of
veth there will be an unneeded memmove().

fbl
