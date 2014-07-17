From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch] wan/x25_asy: integer overflow in x25_asy_change_mtu()
Date: Thu, 17 Jul 2014 08:45:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727688E@AcuExch.aculab.com>
References: <20140717080310.GB477@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140717080310.GB477@mwanda>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter
> If "newmtu * 2 + 4" is too large then it can cause an integer overflow
> leading to memory corruption.  Btw, "newmtu" is not allowed to be a
> negative number because of the check in dev_set_mtu(), so that's ok.

This still allows large numbers to be used to allocate almost all of
kernel memory - causing massive issues elsewhere.

I'd have thought a 'sanity' limit on the mtu would be more appropriate.
I've no idea which mtu is being changed here, and I can't even remember
the x.25 protocol well enough if it is an x.25 level 3 limit.
But I suspect that a 'sanity' bound to 1MB won't cause any grief.

	David

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
> index 5895f19..f04c8c1 100644
> --- a/drivers/net/wan/x25_asy.c
> +++ b/drivers/net/wan/x25_asy.c
> @@ -122,8 +122,11 @@ static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
>  {
>  	struct x25_asy *sl = netdev_priv(dev);
>  	unsigned char *xbuff, *rbuff;
> -	int len = 2 * newmtu;
> +	int len;
> 
> +	if (newmtu > INT_MAX / 2 - 4)
> +		return -EINVAL;
> +	len = 2 * newmtu;
>  	xbuff = kmalloc(len + 4, GFP_ATOMIC);
>  	rbuff = kmalloc(len + 4, GFP_ATOMIC);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


