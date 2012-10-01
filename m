From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH RFC net-next 1/1] ptp: add an ioctl to compare PHC time
 with system time
Date: Mon, 1 Oct 2012 22:33:30 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5818C04CB4@ORSMSX105.amr.corp.intel.com>
References: <cover.1348768886.git.richardcochran@gmail.com>
 <f0c20e2d1a303b0247b1e0e0def19f131de162ff.1348768886.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26885 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab2JAWdr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 18:33:47 -0400
In-Reply-To: <f0c20e2d1a303b0247b1e0e0def19f131de162ff.1348768886.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Richard Cochran
> Sent: Thursday, September 27, 2012 11:12 AM
> To: netdev@vger.kernel.org
> Cc: David Miller; Keller, Jacob E; John Stultz; Miroslav Lichvar
> Subject: [PATCH RFC net-next 1/1] ptp: add an ioctl to compare PHC time
> with system time
> 
> This patch adds an ioctl for PTP Hardware Clock (PHC) devices that allows
> user space to measure the time offset between the PHC and the system
> clock. Rather than hard coding any kind of estimation algorithm into the
> kernel, this patch takes the more flexible approach of just delivering an
> array of raw clock readings. In that way, the user space clock servo may
> be adapted to new and different hardware clocks.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/ptp/ptp_chardev.c |   32 ++++++++++++++++++++++++++++++++
>  include/linux/ptp_clock.h |   14 ++++++++++++++
>  2 files changed, 46 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c index
> e7f301da2..4f8ae80 100644
> --- a/drivers/ptp/ptp_chardev.c
> +++ b/drivers/ptp/ptp_chardev.c
> @@ -33,9 +33,13 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int
> cmd, unsigned long arg)  {
>  	struct ptp_clock_caps caps;
>  	struct ptp_clock_request req;
> +	struct ptp_sys_offset sysoff;
>  	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
>  	struct ptp_clock_info *ops = ptp->info;
> +	struct ptp_clock_time *pct;
> +	struct timespec ts;
>  	int enable, err = 0;
> +	unsigned int i;
> 
>  	switch (cmd) {
> 
> @@ -88,6 +92,34 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int
> cmd, unsigned long arg)
>  		err = ops->enable(ops, &req, enable);
>  		break;
> 
> +	case PTP_SYS_OFFSET:
> +		if (copy_from_user(&sysoff, (void __user *)arg,
> +				   sizeof(sysoff))) {
> +			err = -EFAULT;
> +			break;
> +		}
> +		if (sysoff.n_samples > PTP_MAX_SAMPLES) {
> +			err = -EINVAL;
> +			break;
> +		}
> +		pct = &sysoff.ts[0];
> +		for (i = 0; i < sysoff.n_samples; i++) {
> +			getnstimeofday(&ts);
> +			pct->sec = ts.tv_sec;
> +			pct->nsec = ts.tv_nsec;
> +			pct++;
> +			ptp->info->gettime(ptp->info, &ts);
> +			pct->sec = ts.tv_sec;
> +			pct->nsec = ts.tv_nsec;
> +			pct++;
> +		}
> +		getnstimeofday(&ts);
> +		pct->sec = ts.tv_sec;
> +		pct->nsec = ts.tv_nsec;
> +		if (copy_to_user((void __user *)arg, &sysoff,
> sizeof(sysoff)))
> +			err = -EFAULT;
> +		break;
> +
>  	default:
>  		err = -ENOTTY;
>  		break;
> diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h index
> 94e981f..b65c834 100644
> --- a/include/linux/ptp_clock.h
> +++ b/include/linux/ptp_clock.h
> @@ -67,12 +67,26 @@ struct ptp_perout_request {
>  	unsigned int rsv[4];          /* Reserved for future use. */
>  };
> 
> +#define PTP_MAX_SAMPLES 25 /* Maximum allowed offset measurement
> +samples. */
> +
> +struct ptp_sys_offset {
> +	unsigned int n_samples; /* Desired number of measurements. */
> +	unsigned int rsv[3];    /* Reserved for future use. */
> +	/*
> +	 * Array of interleaved system/phc time stamps. The kernel
> +	 * will provide 2*n_samples + 1 time stamps, with the last
> +	 * one as a system time stamp.
> +	 */
> +	struct ptp_clock_time ts[2 * PTP_MAX_SAMPLES + 1]; };
> +
>  #define PTP_CLK_MAGIC '='
> 
>  #define PTP_CLOCK_GETCAPS  _IOR(PTP_CLK_MAGIC, 1, struct ptp_clock_caps)
> #define PTP_EXTTS_REQUEST  _IOW(PTP_CLK_MAGIC, 2, struct
> ptp_extts_request)  #define PTP_PEROUT_REQUEST _IOW(PTP_CLK_MAGIC, 3,
> struct ptp_perout_request)
>  #define PTP_ENABLE_PPS     _IOW(PTP_CLK_MAGIC, 4, int)
> +#define PTP_SYS_OFFSET     _IOW(PTP_CLK_MAGIC, 5, struct ptp_sys_offset)
> 
>  struct ptp_extts_event {
>  	struct ptp_clock_time t; /* Time event occured. */
> --
> 1.7.2.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

This is much nicer than performing the same reads manually in user-space.

Acked-by: Jacob Keller <jacob.e.keller@intel.com>
