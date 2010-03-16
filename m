From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/wimax/i2400m/fw.c fix possible double free
Date: Tue, 16 Mar 2010 14:14:45 -0700 (PDT)
Message-ID: <20100316.141445.27416807.davem@davemloft.net>
References: <1268739988.17270.8.camel@ICE-BOX>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	kernel-janitors@vger.kernel.org, cindy.h.kao@intel.com,
	dirk.j.brandewie@intel.com, wimax@linuxwimax.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: darrenrjenkins@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46828
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754364Ab0CPVOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:14:23 -0400
In-Reply-To: <1268739988.17270.8.camel@ICE-BOX>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Darren Jenkins <darrenrjenkins@gmail.com>
Date: Tue, 16 Mar 2010 22:46:28 +1100

> i2400m_fw_check() can free i2400m->fw_hdrs if krealloc() fails causing a double free
> Add a check so we don't free the memory a second time.
> 
> coverity CID: 13455
> 
> Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>

Please don't fix it like this, the check is obscure and it's
allowing other bugs to happen.

If krealloc() fails, any refrence to i2400m->fw_hdrs is
referencing freed memory.

Therefore the krealloc() failure handling in this driver should NULL
out i2400m->fw_hdrs and that will fix the double kfree problem as well
as trap any stray references.

> ---
>  drivers/net/wimax/i2400m/fw.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
> index 25c24f0..a97c413 100644
> --- a/drivers/net/wimax/i2400m/fw.c
> +++ b/drivers/net/wimax/i2400m/fw.c
> @@ -1490,7 +1490,8 @@ int i2400m_fw_bootstrap(struct i2400m *i2400m, const struct firmware *fw,
>  	if (ret < 0)
>  		dev_err(dev, "%s: cannot use: %d, skipping\n",
>  			i2400m->fw_name, ret);
> -	kfree(i2400m->fw_hdrs);
> +	if (ret != -ENOMEM)
> +		kfree(i2400m->fw_hdrs);
>  	i2400m->fw_hdrs = NULL;
>  	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
>  	return ret;
> -- 
> 1.6.3.3
