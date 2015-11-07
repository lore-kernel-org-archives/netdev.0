From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v4 3/4] Add PTP_SYS_OFFSET_PRECISE for driver
 crosstimestamping
Date: Fri, 06 Nov 2015 18:15:21 -0800
Message-ID: <op.x7pkjvdk1774gr@chall-mobl2.amr.corp.intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-4-git-send-email-christopher.s.hall@intel.com>
 <20151013135925.GB5422@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: "Richard Cochran" <richardcochran@gmail.com>,
	"Thomas Gleixner" <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26877 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224AbbKGCPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2015 21:15:22 -0500
In-Reply-To: <20151013135925.GB5422@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard/Thomas:

On Tue, 13 Oct 2015 06:59:26 -0700, Richard Cochran  
<richardcochran@gmail.com> wrote:
> On Mon, Oct 12, 2015 at 11:45:21AM -0700, Christopher S. Hall wrote:
>>
>> +struct ptp_sys_offset_precise {
>> +	unsigned int rsv[4];    /* Reserved for future use. */
>> +	struct ptp_clock_time dev;
>> +	struct ptp_clock_time sys;
>> +};
>> +
>
> Please put the reserved field at the bottom.  Also, since we reading
> the raw monotonic time under the hood, we might as well return it in
> this struct too.  It costs us almost nothing, and having that value
> can be useful for characterizing the system oscillator.

Below is my proposal to implement your suggested changes adding monotonic  
raw to the PTP_SYS_OFFSET_PRECISE ioctl:

Move the reserved field to the end and add monotonic raw to
ptp_sys_offset_precise:

struct ptp_sys_offset_precise {
          struct ptp_clock_time dev;
          struct ptp_clock_time sys_real;
          struct ptp_clock_time sys_raw;
          unsigned int rsv[4];    /* Reserved for future use. */
};

In my previous patch, the getsynctime() prototype is:

int (*getsynctime64)(struct ptp_clock_info *ptp, struct timespec64 *dev,
struct timespec64 *sys);

To simplify the PTP callback arguments (not add an additional raw
argument), it seems better to replace all of the arguments with a single
argument:

int (*getsynctime)(struct ptp_clock_info *ptp, struct correlated_ts *cts);

This requires adding a device time field to the correlated timestamp
struct:

struct correlated_ts {
          int                     (*get_ts)(struct correlated_ts *ts);
          u64                     system_ts;
          u64                     device_ts;
          ktime_t                 system_real;
          ktime_t                 system_raw;
+       ktime_t                 device;
          void                    *private;
};

The device time field is filled out by the driver "on the way back"
(following completion of get_correlated_timestamp()) to the PTP driver.

The call flow:

PTP driver-> get_synctime() (Ethernet driver)-> get_correlated_timestamp()
(Timekeeping)->get_ts (Ethernet driver)

The timestamp argument is the same (type struct correlated_ts *) for all
of these calls.

Thanks,
Chris
