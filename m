From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mwifiex: Make mwifiex_dbg a function, reduce object size
Date: Tue, 1 Sep 2015 15:09:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB8B595@AcuExch.aculab.com>
References: <1441043205.3276.28.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Joe Perches' <joe@perches.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441043205.3276.28.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches
> Sent: 31 August 2015 18:47
> 
> The mwifiex_dbg macro has two tests that could be consolidated
> into a function reducing overall object size ~10KB (~4%).
> 
> So convert the macro into a function.

This looks like it will slow things down somewhat.
Maybe inline the tests and then do a call for the dev_info().
Or at least inline the test for the debug flag.
So you end up with something like:

#define mwifiex_dbg(adapter, dbg_mask, fmt, args...)		\
do {								\
	if ((adapter)->debug_mask & MWIFIEX_DBG_##dbg_mask)	\
		_mwifiex_dbg(adapter, fmt, ##__VA_ARGS__)
} while (0)

	David

> 
> $ size drivers/net/wireless/mwifiex/built-in.o* (x86-64 defconfig)
>    text	   data	    bss	    dec	    hex	filename
>  233102	   8628	   4809	 246539	  3c30b	drivers/net/wireless/mwifiex/built-
> in.o.new
>  243949	   8628	   4809	 257386	  3ed6a	drivers/net/wireless/mwifiex/built-
> in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/mwifiex/main.c | 20 ++++++++++++++++++++
>  drivers/net/wireless/mwifiex/main.h | 17 ++++++++---------
>  2 files changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
> index 278dc94..4fa8ca3 100644
> --- a/drivers/net/wireless/mwifiex/main.c
> +++ b/drivers/net/wireless/mwifiex/main.c
> @@ -1447,6 +1447,26 @@ exit_sem_err:
>  }
>  EXPORT_SYMBOL_GPL(mwifiex_remove_card);
> 
> +void _mwifiex_dbg(const struct mwifiex_adapter *adapter, int mask,
> +		  const char *fmt, ...)
> +{
> +	struct va_format vaf;
> +	va_list args;
> +
> +	if (!adapter->dev || !(adapter->debug_mask & mask))
> +		return;
> +
> +	va_start(args, fmt);
> +
> +	vaf.fmt = fmt;
> +	vaf.va = &args;
> +
> +	dev_info(adapter->dev, "%pV", &vaf);
> +
> +	va_end(args);
> +}
> +EXPORT_SYMBOL_GPL(_mwifiex_dbg);
> +
>  /*
>   * This function initializes the module.
>   *
> diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwifiex/main.h
> index 6b95121..96663214 100644
> --- a/drivers/net/wireless/mwifiex/main.h
> +++ b/drivers/net/wireless/mwifiex/main.h
> @@ -48,6 +48,9 @@
> 
>  extern const char driver_version[];
> 
> +struct mwifiex_adapter;
> +struct mwifiex_private;
> +
>  enum {
>  	MWIFIEX_ASYNC_CMD,
>  	MWIFIEX_SYNC_CMD
> @@ -180,12 +183,11 @@ enum MWIFIEX_DEBUG_LEVEL {
>  					MWIFIEX_DBG_FATAL | \
>  					MWIFIEX_DBG_ERROR)
> 
> -#define mwifiex_dbg(adapter, dbg_mask, fmt, args...)		\
> -do {								\
> -	if ((adapter)->debug_mask & MWIFIEX_DBG_##dbg_mask)	\
> -		if ((adapter)->dev)				\
> -			dev_info((adapter)->dev, fmt, ## args);	\
> -} while (0)
> +__printf(3, 4)
> +void _mwifiex_dbg(const struct mwifiex_adapter *adapter, int mask,
> +		  const char *fmt, ...);
> +#define mwifiex_dbg(adapter, mask, fmt, ...)				\
> +	_mwifiex_dbg(adapter, MWIFIEX_DBG_##mask, fmt, ##__VA_ARGS__)
> 
...
