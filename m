From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/4] net: mv643xx_eth: use kzalloc
Date: Wed, 09 Sep 2015 09:00:31 -0700
Message-ID: <1441814431.17219.46.camel@perches.com>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1441787886-7214-4-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441787886-7214-4-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-09-09 at 10:38 +0200, Rasmus Villemoes wrote:
> The double memset is a little ugly; using kzalloc avoids it altogether.
[]
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
[]
> @@ -1859,14 +1859,11 @@ oom:
>  		return;
>  	}
>  
> -	mc_spec = kmalloc(0x200, GFP_ATOMIC);
> +	mc_spec = kzalloc(0x200, GFP_ATOMIC);
>  	if (mc_spec == NULL)
>  		goto oom;
>  	mc_other = mc_spec + (0x100 >> 2);

This sure looks wrong as it sets a pointer
to unallocated memory.

> -	memset(mc_spec, 0, 0x100);
> -	memset(mc_other, 0, 0x100);

So this does a memset of random memory.

	for (i = 0; i < 0x100; i += 4) {
		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, mc_spec[i >> 2]);
		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, mc_other[i >> 2]);
	}
