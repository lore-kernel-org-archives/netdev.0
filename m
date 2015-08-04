From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 1/2] iwlwifi: convert hex_dump_to_buffer() to %*ph
Date: Tue, 04 Aug 2015 13:47:13 +0300
Message-ID: <1438685233.29746.156.camel@linux.intel.com>
References: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29783 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332AbbHDKtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 06:49:24 -0400
In-Reply-To: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-16 at 15:42 +0300, Andy Shevchenko wrote:
> There is no need to use hex_dump_to_buffer() in the cases like this:
> 
> 	hexdump_to_buffer(buf, len, 16, 1, outbuf, outlen, false);	> /* len <= 16 
> */
> 	sprintf("%s\n", outbuf);
> 
> since it maybe easily converted to simple:
> 
> 	sprintf("%*ph\n", len, buf);
> 
> Note: it seems in one case the output is groupped by 2 bytes and 
> looks like a
> typo. Thus, patch changes that to plain byte stream.


Any comments on this, anyone?

The idea is to minimize usage of hexdump_to_buffer(), i.e. not using it
when it's an obvious overkill.

> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  drivers/net/wireless/iwlwifi/dvm/debugfs.c | 8 ++------
>  drivers/net/wireless/iwlwifi/mvm/debugfs.c | 7 +------
>  2 files changed, 3 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/dvm/debugfs.c 
> b/drivers/net/wireless/iwlwifi/dvm/debugfs.c
> index 0ffb6ff..b15e44f 100644
> --- a/drivers/net/wireless/iwlwifi/dvm/debugfs.c
> +++ b/drivers/net/wireless/iwlwifi/dvm/debugfs.c
> @@ -310,12 +310,8 @@ static ssize_t iwl_dbgfs_nvm_read(struct file 
> *file,
>  	pos += scnprintf(buf + pos, buf_size - pos,
>  			 "NVM version: 0x%x\n", nvm_ver);
>  	for (ofs = 0 ; ofs < eeprom_len ; ofs += 16) {
> -		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x 
> ", ofs);
> -		hex_dump_to_buffer(ptr + ofs, 16 , 16, 2, buf + pos,
> -				   buf_size - pos, 0);
> -		pos += strlen(buf + pos);
> -		if (buf_size - pos > 0)
> -			buf[pos++] = '\n';
> +		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x 
> %16ph\n",
> +				 ofs, ptr + ofs);
>  	}
>  
>  	ret = simple_read_from_buffer(user_buf, count, ppos, buf, 
> pos);
> diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs.c 
> b/drivers/net/wireless/iwlwifi/mvm/debugfs.c
> index ffb4b5c..98abd31 100644
> --- a/drivers/net/wireless/iwlwifi/mvm/debugfs.c
> +++ b/drivers/net/wireless/iwlwifi/mvm/debugfs.c
> @@ -1200,12 +1200,7 @@ static ssize_t iwl_dbgfs_d3_sram_read(struct 
> file *file, char __user *user_buf,
>  	if (ptr) {
>  		for (ofs = 0; ofs < len; ofs += 16) {
>  			pos += scnprintf(buf + pos, bufsz - pos,
> -					 "0x%.4x ", ofs);
> -			hex_dump_to_buffer(ptr + ofs, 16, 16, 1, buf 
> + pos,
> -					   bufsz - pos, false);
> -			pos += strlen(buf + pos);
> -			if (bufsz - pos > 0)
> -				buf[pos++] = '\n';
> +					 "0x%.4x %16ph\n", ofs, ptr 
> + ofs);
>  		}
>  	} else {
>  		pos += scnprintf(buf + pos, bufsz - pos,

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
