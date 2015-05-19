From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Tue, 19 May 2015 16:52:24 +0200
Message-ID: <1432047144.2698.6.camel@suse.com>
References: <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai@suse.de>, Laura Abbott <labbott@redhat.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Laura Abbott <labbott@fedoraproject.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ming Lei <ming.lei@canonical.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	linux-usb@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-19 at 10:26 -0400, Alan Stern wrote:
> On Tue, 19 May 2015, Takashi Iwai wrote:
> 
> > > > I am not convinced. Now we are hacking the Bluetooth core layer
> > > > (which has nothing to do with the drivers suspend/resume or
> > > > probe) to do something different so that we do not see this
> > > > warning.
> > > >
> > > > I can not do anything about the platform in question choosing a
> > > > unplug/replug for suspend/resume instead of having a proper USB
> > > > suspend and resume handling. That is pretty much out of our
> > > > control.
> 
> Actually one can do something about this.  I mean, one _can_ implement
> proper USB suspend and resume handling in the Bluetooth driver.  At
> this point the details aren't clear to me, but perhaps if the driver in
> question had a reset_resume callback then it might work better.

I doubt this would work. By losing power the BT controller is thrown
out of its cell. It looks to me like fundamentally BT needs to
fully reestablish the network from scratch after a loss of power.

> > > >  I would rather have the USB subsystem delay the probe()
> > > > callback if we tell it to.
> 
> This is possible.  I am not sure it would be the right thing to do,
> though.  What happens if the probe routine gets called early on during
> the boot-up procedure, before userspace is up and running?  The same
> thing should happen here.

Yes. Basically if you want firmware during probe the firmware
infrastructure has to be there. That is if you build such a module
statically the firmware must be included in the kernel image.

> > > >  Of just have request_firmware()
> > > > actually sleep until userspace is ready. Seriously, why is
> > > > request_firmware not just sleeping for us.
> 
> It won't work.  The request_firmware call is part of the probe 
> sequence, which in turn is part of the resume sequence.  Userspace 
> doesn't start running again until the resume sequence is finished.  If 
> request_firmware waited for userspace, it would hang.

I'd recommend the sledge hammer. Never free the firmware while the
hardware is connected or the system sleeping. If you must do this
there is a notifier chain.

	Regards
		Oliver
