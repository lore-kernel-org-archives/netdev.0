From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 18:47:42 -0300
Message-ID: <20130218184742.5a4c3c06@redhat.com>
References: <20130218153316.GA2663@arwen.pp.htv.fi>
	<20130218155012.GA30974@kroah.com>
	<20130218155215.GB2663@arwen.pp.htv.fi>
	<20130218171334.GA31329@kroah.com>
	<20130218172700.GH2663@arwen.pp.htv.fi>
	<20130218174916.GA2070@kroah.com>
	<20130218184633.GC10755@arwen.pp.htv.fi>
	<20130218164638.7cb53baa@redhat.com>
	<20130218200542.GB20137@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: <balbi@ti.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130218200542.GB20137@arwen.pp.htv.fi>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, 18 Feb 2013 22:05:42 +0200
Felipe Balbi <balbi@ti.com> escreveu:

> Hi,
> 
> On Mon, Feb 18, 2013 at 04:46:38PM -0300, Mauro Carvalho Chehab wrote:
> > > > > No such device - /sys/devices/system/edac/mc/mc0/sdram_scrub_rate
> > > > 
> > > > Odd, go ask the edac developers
> > > 
> > > will do ;-)
> > 
> > Well, the question is missing ;) /me assumes that you want to talk about
> > suspending/resume and EDAC, right?
> 
> oops, my bad. The thing is that file has read permission but reading it
> isn't allowed ;-)

That depends on the driver. See drivers/edac/edac_mc_sysfs.c:

static ssize_t mci_sdram_scrub_rate_show(struct device *dev,
					 struct device_attribute *mattr,
					 char *data)
{
	struct mem_ctl_info *mci = to_mci(dev);
	int bandwidth = 0;

	if (!mci->get_sdram_scrub_rate)
		return -ENODEV;

	bandwidth = mci->get_sdram_scrub_rate(mci);
	if (bandwidth < 0) {
		edac_printk(KERN_DEBUG, EDAC_MC, "Error reading scrub rate\n");
		return bandwidth;
	}

	return sprintf(data, "%d\n", bandwidth);
}

/* memory scrubber attribute file */
DEVICE_ATTR(sdram_scrub_rate, S_IRUGO | S_IWUSR, mci_sdram_scrub_rate_show,
       	mci_sdram_scrub_rate_store);

static struct attribute *mci_attrs[] = {
        &dev_attr_reset_counters.attr,
       	&dev_attr_mc_name.attr,
        &dev_attr_size_mb.attr,
        &dev_attr_seconds_since_reset.attr,
        &dev_attr_ue_noinfo_count.attr,
        &dev_attr_ce_noinfo_count.attr,
        &dev_attr_ue_count.attr,
        &dev_attr_ce_count.attr,
        &dev_attr_sdram_scrub_rate.attr,
       	&dev_attr_max_location.attr,
        NULL
};

The capability of get and/or set the scrub rate is edac-driver specific.
Drivers that support it need to fill those callbacks:
	mci->get_sdram_scrub_rate
	mci->set_sdram_scrub_rate

In any case, the sysfs attribute is created even if the device doesn't
have support for read/set the scrub rate.

On devices where this is not supported, reading (and/or writing) to this
sysfs node will return -ENODEV.

In the past, the sysfs node creation was done using the raw sysfs support.
Doing dynamic creation with the old code were much more complex. I guess
that's the reason why the code was written this way. Now that the code 
uses struct device, it shouldn't be hard to change the code to only 
create this attribute if the device has support for scrub rate setting.

Yet, that would change the userspace API. I'm not sure what
applications would rely on the current behavior. So, changing it
would require some investigation in order to avoid regressions.

Regards,
Mauro
