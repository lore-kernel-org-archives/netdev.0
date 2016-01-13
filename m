From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v6 2/9] Add driver cross timestamp interface for higher
 precision time synchronization
Date: Wed, 13 Jan 2016 22:30:30 +0100
Message-ID: <20160113213030.GA20252@localhost.localdomain>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
 <1452687149-11281-3-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452687149-11281-3-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The series is a lot easier to follow now.  However, the
sync_device_time_cb structure isn't serving any useful purpose:

> +/*
> + * struct get_sync_device_time_cb - Provides method to capture device time
> + *	synchronized with raw system counter value
> + * @get_time:	Callback providing synchronized capture of device time
> + *		and system counter. Returns 0 on success, < 0 on failure
> + * @ctx:	Context provided to callback function
> + */
> +struct sync_device_time_cb {
> +	int	(*get_time)(ktime_t *device_time,
> +			    struct system_counterval_t *system_counterval,
> +			    void *ctx);
> +	void	 *ctx;
> +};

Why not simply pass the function and context pointers as separate
arguments to get_device_system_crosststamp?

> +/*
> + * Get cross timestamp between system clock and device clock
> + */
> +extern int get_device_system_crosststamp(struct sync_device_time_cb *cb,
> +					 struct system_device_crosststamp *ts);

Here is how it looks at the call site (from the last patch):

> +static int e1000e_phc_getcrosststamp(struct ptp_clock_info *ptp,
> +				     struct system_device_crosststamp *xtstamp)
> +{
> +	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
> +						     ptp_clock_info);
> +	struct sync_device_time_cb sync_devicetime;
> +	int ret;
> +
> +	sync_devicetime.get_time = e1000e_phc_get_syncdevicetime;
> +	sync_devicetime.ctx = adapter;
> +	ret = get_device_system_crosststamp(&sync_devicetime, NULL, xtstamp);
> +	return ret;
> +}

It is really just busy work to assign the fields of 'sync_devicetime'.
If you don't foresee the need of storing the sync_device_time_cb
object, then I would just remove the structure altogether.  Then the
call site will be cleaner, for example:

static int e1000e_phc_getcrosststamp(struct ptp_clock_info *ptp,
				     struct system_device_crosststamp *xtstamp)
{
	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
						     ptp_clock_info);

	return get_device_system_crosststamp(e1000e_phc_get_syncdevicetime,
					     adapter, NULL, xtstamp);
}

Thanks,
Richard
