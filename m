From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 09:08:38 -0700
Message-ID: <1312906118.11924.8.camel@Joe-Laptop>
References: <1312904711-1855-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Sandeep.Kumar@freescale.com,
	Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: stufever@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312904711-1855-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-08-09 at 23:45 +0800, stufever@gmail.com wrote:
> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>   drivers/net/gianfar_ethtool.c:765: warning: the frame size of 2048 bytes is larger than 1024 bytes
[]
> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
[]
> @@ -686,10 +686,26 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
>  {
>  	unsigned int last_rule_idx = priv->cur_filer_idx;
>  	unsigned int cmp_rqfpr;
> -	unsigned int local_rqfpr[MAX_FILER_IDX + 1];
> -	unsigned int local_rqfcr[MAX_FILER_IDX + 1];
> +	unsigned int *local_rqfpr;
> +	unsigned int *local_rqfcr;
>  	int i = 0x0, k = 0x0;
>  	int j = MAX_FILER_IDX, l = 0x0;
> +	int ret = 1;
> +
> +	local_rqfpr = kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
> +		GFP_KERNEL);
> +	if (!local_rqfpr) {
> +		pr_err("Out of memory\n");
> +		ret = 0;
> +		got err;
> +	}
> +	local_rqfcr = kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
> +		GFP_KERNEL);
> +	if (!local_rqfcr) {
> +		pr_err("Out of memory\n");
> +		ret = 0;
> +		goto err1;
> +	}

Perhaps it'd be clearer to use:

	local_rqfpr = kmalloc(...)
	local_rqfcr = kmalloc(...)
	if (!local_rqfpr || !local_rqfcr) {
		pr_err(...)
		ret = -ENOMEM;
		goto err;
	}

[...]

err:
	kfree(local_rqfpr);
	kfree(local_rqfcr);
	return ret;

Is the "local_" prefix useful?
It seems like visual noise to me.
