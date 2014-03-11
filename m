From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH RFC net-next v1 1/9] ptp: introduce programmable pins.
Date: Tue, 11 Mar 2014 08:58:45 +0100
Message-ID: <F85F72BA1EE25F8F7FB77295@[172.22.2.41]>
References: <cover.1394307303.git.richardcochran@gmail.com>
 <d9cb37a7d6e57d7f103dab78f98044697d3c4433.1394307304.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Stefan_S=C3=B8rensen?= <stefan.sorensen@spectralink.com>
To: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d9cb37a7d6e57d7f103dab78f98044697d3c4433.1394307304.git.richardcochran@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

--On March 08, 2014 20:42 +0100 Richard Cochran <richardcochran@gmail.com> 
wrote:

> This patch adds a pair of new ioctls to the PTP Hardware Clock device
> interface. Using the ioctls, user space programs can query each pin to
> find out its current function and also reprogram a different function
> if desired.
>
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/ptp/ptp_chardev.c        |  133
> +++++++++++++++++++++++++++++++++++++-  drivers/ptp/ptp_clock.c
> |   23 +++++++
>  drivers/ptp/ptp_private.h        |    4 ++
>  include/linux/ptp_clock_kernel.h |   33 ++++++++++
>  include/uapi/linux/ptp_clock.h   |   39 ++++++++++-
>  5 files changed, 230 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
> index 34a0c60..dc13d1e 100644
> --- a/drivers/ptp/ptp_chardev.c
> +++ b/drivers/ptp/ptp_chardev.c
[...]
> +int ptp_setpin(struct ptp_clock *ptp, unsigned int pin,
> +	       enum ptp_pin_function func, unsigned int chan)
> +{
> +	struct ptp_clock_info *info = ptp->info;
> +	struct ptp_pin_desc *pin1 = NULL, *pin2 = &info->pin_config[pin];
> +	unsigned int i;
> +
> +	/* Check to see if any other pin previously had this function. */
> +	if (mutex_lock_interruptible(&ptp->pincfg_mux))
> +		return -ERESTARTSYS;
> +	for (i = 0; i < info->n_pins; i++) {
> +		if (info->pin_config[i].func == func &&
> +		    info->pin_config[i].chan == chan) {
> +			pin1 = &info->pin_config[i];
> +			break;
> +		}
> +	}
> +	mutex_unlock(&ptp->pincfg_mux);
> +	if (pin1 && i == pin)
> +		return 0;
> +
> +	/* Check the desired function and channel. */
> +	switch (func) {
> +	case PTP_PF_NONE:
> +		break;
> +	case PTP_PF_EXTTS:
> +		if (chan >= info->n_ext_ts)
> +			return -EINVAL;
> +		break;
> +	case PTP_PF_PEROUT:
> +		if (chan >= info->n_per_out)
> +			return -EINVAL;
> +		break;
> +	case PTP_PF_PHYSYNC:
> +		pr_err("sorry, cannot reassign the calibration pin\n");
> +		return -EINVAL;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	if (pin1 && pin1->func == PTP_PF_PHYSYNC) {
> +		pr_err("sorry, cannot reprogram the calibration pin\n");
> +		return -EINVAL;

            ^^^^
Will this ever happen? pin1 && pin1->func == PTP_PF_PHYSYNC means that func 
== PTP_PF_PHYSYNC, but in this case you already return -EINVAL a few lines 
above.

Christian
