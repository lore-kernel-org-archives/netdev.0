From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [patch] cxgb4: memory corruption in debugfs
Date: Tue, 18 Aug 2015 19:28:53 +0900
Message-ID: <201508181928.JGB95875.OHOtSVLFMFFJQO@I-love.SAKURA.ne.jp>
References: <20150818093144.GG3965@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com, hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:22784 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbbHRLJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 07:09:31 -0400
In-Reply-To: <20150818093144.GG3965@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> You can't use kstrtoul() with an int or it causes memory corruption.
> Also j should be unsigned or we have underflow bugs.
> 
> I considered changing "j" to unsigned long but everything fits in a u32.

Excuse me, but kstrtouint()'s last argument is not "u32 *" but "unsigned int *".
Aren't there architectures where sizeof(unsigned int) > sizeof(u32) ?

> 
> Fixes: 8e3d04fd7d70 ('cxgb4: Add MPS tracing support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> index 1732e29..0a87a32 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> @@ -1289,13 +1289,14 @@ static unsigned int xdigit2int(unsigned char c)
>  static ssize_t mps_trc_write(struct file *file, const char __user *buf,
>  			     size_t count, loff_t *pos)
>  {
> -	int i, j, enable, ret;
> +	int i, enable, ret;
>  	u32 *data, *mask;
>  	struct trace_params tp;
>  	const struct inode *ino;
>  	unsigned int trcidx;
>  	char *s, *p, *word, *end;
>  	struct adapter *adap;
> +	u32 j;
>  
>  	ino = file_inode(file);
>  	trcidx = (uintptr_t)ino->i_private & 3;
> @@ -1340,7 +1341,7 @@ static ssize_t mps_trc_write(struct file *file, const char __user *buf,
>  
>  		if (!strncmp(word, "qid=", 4)) {
>  			end = (char *)word + 4;
> -			ret = kstrtoul(end, 10, (unsigned long *)&j);
> +			ret = kstrtouint(end, 10, &j);
>  			if (ret)
>  				goto out;
>  			if (!adap->trace_rss) {
