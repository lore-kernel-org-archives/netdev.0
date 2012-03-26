From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Mon, 26 Mar 2012 16:10:17 -0700
Message-ID: <20120326231017.GA30684@kroah.com>
References: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
 <1332800304-5060-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de,
	linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332800304-5060-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 26, 2012 at 03:18:24PM -0700, Haiyang Zhang wrote:
> In the existing code, we only stop queue when the ringbuffer is full,
> so the current packet has to be dropped or retried from upper layer.
> 
> This patch stops the tx queue when available ringbuffer is below
> the low watermark. So the ringbuffer still has small amount of space
> available for the current packet. This will reduce the overhead of
> retries on sending.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/hv/ring_buffer.c        |   15 +++++++++++++++
>  drivers/net/hyperv/hyperv_net.h |    3 +++
>  drivers/net/hyperv/netvsc.c     |   23 +++++++++++++++++++----
>  drivers/net/hyperv/netvsc_drv.c |   16 +++++++++++++++-
>  include/linux/hyperv.h          |    3 +++
>  5 files changed, 55 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
> index 8af25a0..8cc3f63 100644
> --- a/drivers/hv/ring_buffer.c
> +++ b/drivers/hv/ring_buffer.c
> @@ -23,6 +23,7 @@
>   */
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
> +#include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
>  #include <linux/hyperv.h>
> @@ -160,6 +161,20 @@ hv_get_ring_buffersize(struct hv_ring_buffer_info *ring_info)
>  }
>  
>  /*
> + * Get the percentage of available bytes to write in the ring.
> + * The return value is in range from 0 to 100.
> + */
> +u32 hv_ringbuf_avail_percent(struct hv_ring_buffer_info *ring_info)
> +{
> +	u32 avail_read, avail_write;
> +
> +	hv_get_ringbuffer_availbytes(ring_info, &avail_read, &avail_write);
> +
> +	return avail_write * 100 / hv_get_ring_buffersize(ring_info);
> +}
> +EXPORT_SYMBOL(hv_ringbuf_avail_percent);

That makes no sense, what happens 1 second later to the buffer?  You
can't expect this result to be valid anymore, right?

> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -51,6 +51,16 @@ static int ring_size = 128;
>  module_param(ring_size, int, S_IRUGO);
>  MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
>  
> +uint ring_avail_percent_hiwater = 20;
> +module_param(ring_avail_percent_hiwater, uint, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(ring_avail_percent_hiwater,
> +	"Ring buffer available percentiles to wake up xmit queue");
> +
> +uint ring_avail_percent_lowater = 10;
> +module_param(ring_avail_percent_lowater, uint, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(ring_avail_percent_lowater,
> +	"Ring buffer available percentiles to stop xmit queue");

Eeek, no, how in the world is someone supposed to know to set these
things?

Please make this work "automatically", otherwise no one will ever get it
right.  Don't make it tunable as a way out of making a decision on how
the driver should work.

Ick.

David, please do NOT apply this as-is.

greg k-h
