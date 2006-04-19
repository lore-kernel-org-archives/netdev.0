From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 08/10] bcm43xx: sysfs code cleanup
Date: Wed, 19 Apr 2006 23:50:35 +0200
Message-ID: <20060419215035.GA29122@electric-eye.fr.zoreil.com>
References: <200604190405.k3J457Zj008004@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	mb@bu3sch.de, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:11905 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751263AbWDSVyE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 17:54:04 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200604190405.k3J457Zj008004@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org <akpm@osdl.org> :
> 
> From: Michael Buesch <mb@bu3sch.de>
> 
> This cleans up the bcm43xx sysfs code and makes it compliant with the
> unwritten sysfs rules (at least I hope so).
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Greg KH <greg@kroah.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
[...]
> diff -puN drivers/net/wireless/bcm43xx/bcm43xx.h~bcm43xx-sysfs-code-cleanup drivers/net/wireless/bcm43xx/bcm43xx.h
> --- devel/drivers/net/wireless/bcm43xx/bcm43xx.h~bcm43xx-sysfs-code-cleanup	2006-04-12 18:11:12.000000000 -0700
> +++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-04-12 18:11:12.000000000 -0700
[...]
> @@ -772,6 +769,20 @@ struct bcm43xx_private * bcm43xx_priv(st
>  	return ieee80211softmac_priv(dev);
>  }
>  
> +struct device;
> +
> +static inline
> +struct bcm43xx_private * dev_to_bcm(struct device *dev)
> +{
> +	struct net_device *net_dev;
> +	struct bcm43xx_private *bcm;
> +
> +	net_dev = dev_get_drvdata(dev);
> +	bcm = bcm43xx_priv(net_dev);
> +
> +	return bcm;
> +}
> +

It's used only in bcm43xx_sysfs.c. It could go there and avoid
an extra forward declaration.

[...]
> diff -puN drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c~bcm43xx-sysfs-code-cleanup drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
> --- devel/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c~bcm43xx-sysfs-code-cleanup	2006-04-12 18:11:12.000000000 -0700
> +++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-04-12 18:11:12.000000000 -0700
> @@ -71,14 +71,46 @@ static int get_boolean(const char *buf, 
>  	return -EINVAL;
>  }
>  
> +static int sprom2hex(const u16 *sprom, char *buf, size_t buf_len)
> +{
> +	int i, pos = 0;
> +
> +	for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
> +		pos += snprintf(buf + pos, buf_len - pos - 1,
> +				"%04X", swab16(sprom[i]) & 0xFFFF);
> +	}
> +	pos += snprintf(buf + pos, buf_len - pos - 1, "\n");
> +
> +	return pos + 1;
> +}
> +
> +static int hex2sprom(u16 *sprom, const char *dump, size_t len)
> +{
> +	char tmp[5] = { 0 };
> +	int cnt = 0;
> +	unsigned long parsed;
> +
> +	if (len < BCM43xx_SPROM_SIZE * sizeof(u16) * 2)
> +		return -EINVAL;
> +
> +	while (cnt < BCM43xx_SPROM_SIZE) {
> +		memcpy(tmp, dump, 4);
> +		dump += 4;
> +		parsed = simple_strtoul(tmp, NULL, 16);
> +		sprom[cnt++] = swab16((u16)parsed);
> +	}
> +
> +	return 0;
> +}

"4" suggests that the code walks dump -> dump + 4*BCM43xx_SPROM_SIZE

>  static ssize_t bcm43xx_attr_sprom_store(struct device *dev,
>  					const char *buf, size_t count)
[...]
> -	for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
> -		sprom[i] = buf[i * 2] & 0xFF;
> -		sprom[i] |= ((u16)(buf[i * 2 + 1] & 0xFF)) << 8;
> -	}
> +	err = hex2sprom(sprom, buf, count);

... whereas here it only parses buf -> buf + 2*BCM43xx_SPROM_SIZE

-- 
Ueimor

