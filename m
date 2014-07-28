From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 1/3] driver core: enable drivers to use deferred probe
	from init
Date: Mon, 28 Jul 2014 17:38:11 +0200
Message-ID: <20140728153811.GD21930@wotan.suse.de>
References: <1406558067-25308-1-git-send-email-mcgrof@do-not-panic.com> <B5657A6538887040AD3A81F1008BEC63B06F9A@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	"MPT-FusionLinux.pdl@avagotech.com"
	<MPT-Fusi
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B06F9A@avmb3.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 03:12:11PM +0000, Yuval Mintz wrote:
> > +static int __driver_probe_device(struct device_driver *drv, struct
> > +device *dev) {
> > +	if (drv->delay_probe && !dev->init_delayed_probe) {
> > +		dev_info(dev, "Driver %s requests probe deferral on init\n",
> > +			 drv->name);
> > +		dev->init_delayed_probe = true;
> > +		driver_deferred_probe_add(dev);
> > +		return -EPROBE_DEFER;
> > +	}
> > +
> > +	return really_probe(dev, drv);
> > +}
> 
> Perhaps this is a silly question, but what guarantees that the deferred probe
> list will actually be triggered, e.g., in case the delayed device is the last device
> in the system?

The dev->init_delayed_probe is used to ensure that we'd add the device to the
deferred probe list once making this a per device thing if the driver has the
field delay_probe set to true. This technically also allows this to be a per
device thing so with some more work we could enable drivers to only enable this
for specific devices but at this point this did not seem required.

> [From drivers/base/dd.c  - "A successful driver probe will trigger moving all
> devices from the pending to the active list so that the workqueue will
> eventually retry them]

I had not noticed this, thanks for pointing this out, in this case
if __driver_probe_device() is still used to retrigger a probe it will
be added back to the deferred list but since dev->init_delayed_probe
is still false. I checked the original commit that added this feature
d1c3414c but in the code I see that bus_probe_device(dev) is used and
I only see the device itself being removed from the deferred probe list,
nothing else.

  Luis
