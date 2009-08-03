From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 6/10] drivers/net/wireless/iwlwifi: introduce missing
 kfree
Date: Mon, 03 Aug 2009 17:13:25 +0800
Message-ID: <1249290805.4069.46.camel@debian>
References: <Pine.LNX.4.64.0908011054010.23408@ask.diku.dk>
	 <1249260246.4069.26.camel@debian>
	 <Pine.LNX.4.64.0908031109590.8435@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Chatre, Reinette" <reinette.chatre@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ipw3945-devel@lists.sourceforge.net"
	<ipw3945-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754638AbZHCJN3@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0908031109590.8435@pc-004.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-08-03 at 17:11 +0800, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Move orthogonal error handling code up before a kzalloc, so that it 
> doesn't have to free the allocated data.

Acked-by: Zhu Yi <yi.zhu@intel.com>

Thanks,
-yi

> The semantic match that finds the problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @r exists@
> local idexpression x;
> statement S;
> expression E;
> identifier f,f1,l;
> position p1,p2;
> expression *ptr != NULL;
> @@
> 
> x@p1 = \(kmalloc\|kzalloc\|kcalloc\)(...);
> ...
> if (x == NULL) S
> <... when != x
>      when != if (...) { <+...x...+> }
> (
> x->f1 = E
> |
>  (x->f1 == NULL || ...)
> |
>  f(...,x->f1,...)
> )
> ...>
> (
>  return \(0\|<+...x...+>\|ptr\);
> |
>  return@p2 ...;
> )
> 
> @script:python@
> p1 << r.p1;
> p2 << r.p2;
> @@
> 
> print "* file: %s kmalloc %s return %s" % (p1[0].file,p1[0].line,p2[0].line)
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> ---
>  drivers/net/wireless/iwlwifi/iwl-debugfs.c     |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
> index 7707a26..6748a3f 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
> @@ -310,18 +310,18 @@ static ssize_t iwl_dbgfs_nvm_read(struct file *file,
>  		return -ENODATA;
>  	}
>  
> +	ptr = priv->eeprom;
> +	if (!ptr) {
> +		IWL_ERR(priv, "Invalid EEPROM/OTP memory\n");
> +		return -ENOMEM;
> +	}
> +
>  	/* 4 characters for byte 0xYY */
>  	buf = kzalloc(buf_size, GFP_KERNEL);
>  	if (!buf) {
>  		IWL_ERR(priv, "Can not allocate Buffer\n");
>  		return -ENOMEM;
>  	}
> -
> -	ptr = priv->eeprom;
> -	if (!ptr) {
> -		IWL_ERR(priv, "Invalid EEPROM/OTP memory\n");
> -		return -ENOMEM;
> -	}
>  	pos += scnprintf(buf + pos, buf_size - pos, "NVM Type: %s\n",
>  			(priv->nvm_device_type == NVM_DEVICE_TYPE_OTP)
>  			? "OTP" : "EEPROM");
