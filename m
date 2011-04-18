From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH V14 3/4] ptp: Added a clock driver for the IXP46x.
Date: Mon, 18 Apr 2011 21:53:06 +0100
Message-ID: <1303159986.2857.56.camel@bwh-desktop>
References: <cover.1303107532.git.richard.cochran@omicron.at>
	 <dbee2487a57fd7f41e4efbbd2ddfb1313b8d71bc.1303107532.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <dbee2487a57fd7f41e4efbbd2ddfb1313b8d71bc.1303107532.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-04-18 at 08:29 +0200, Richard Cochran wrote:
> This patch adds a driver for the hardware time stamping unit found on the
> IXP465. The basic clock operations and an external trigger are implemented.
[...]
> --- a/drivers/net/arm/ixp4xx_eth.c
> +++ b/drivers/net/arm/ixp4xx_eth.c
[...]
> @@ -246,6 +255,169 @@ static int ports_open;
>  static struct port *npe_port_tab[MAX_NPES];
>  static struct dma_pool *dma_pool;
>  
> +static struct sock_filter ptp_filter[] = {
> +	PTP_FILTER
> +};
> +
> +static int ixp_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seq)
> +{
> +	unsigned int type;
> +	u16 *hi, *id;
> +	u8 *lo, *data = skb->data;
> +
> +	type = sk_run_filter(skb, ptp_filter);
> +
> +	if (PTP_CLASS_V1_IPV4 == type) {
> +
> +		id = (u16 *)(data + 42 + 30);
> +		hi = (u16 *)(data + 42 + 22);
> +		lo = data + 42 + 24;
[...]

PTP_FILTER does not verify that the packet length is sufficient to hold
a complete PTP header, nor does it require that the IPv4 header length
is 5 (i.e. 20 bytes).  So you have to check those here rather than using
magic numbers.

I think you also need to use be16_to_cpup() to read 'id' and 'hi', since
the host byte order may vary.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
