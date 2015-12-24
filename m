From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Thu, 24 Dec 2015 16:47:14 +0100
Message-ID: <1450972034.28243.18.camel@suse.com>
References: <Pine.LNX.4.44L0.1512241007050.2785-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "peter@lekensteyn.nl" <peter@lekensteyn.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1512241007050.2785-100000@netrider.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-24 at 10:14 -0500, Alan Stern wrote:
> On Thu, 24 Dec 2015, Oliver Neukum wrote:
> 
> > On Wed, 2015-12-23 at 20:32 -0500, Alan Stern wrote:

> > But you cannot keep that setting if the system goes down
> > or any broadcast packet would resume the whole system.
> > Yet you cannot just disable remote wake up, as WoL packages
> > still must trigger a remote wake up.
> 
> This means that sometimes you want to avoid losing packets and other 
> times you do want to lose packets.  That is a policy decision, and 
> therefore it should be made by the user, not the kernel.

Indeed it is and there is a tool for this with a defined
interface called "ethtool"
The problem here is not the policy decision, but implementing
it in kernel space.

> > So there are drivers which must change settings on devices
> > as the system goes to sleep, even if their devices have
> > already been autosuspended. We could use the notifier chains
> > for that. But can this solution be called elegant?
> 
> Instead of the driver trying to do this automatically, you could rely 
> on userspace telling the driver which packets should cause a wakeup.

It does.

> The setting could be updated immediately before and after each system 
> suspend.

The API is so that user space sets the policy, which persists until
user space changes the setting and the kernel implements it. The
problem is that to do so the kernel needs to do IO to the device
as the system is about to suspend.
Thus the driver may need to resume the device and it needs to learn
that the system is about to go to sleep, even if the device it
manages is already autosuspended.

> I admit this is more awkward than having the driver make a choice based 
> on the type of suspend.  This is a case where the resources provided by 

It also is a race condition, unless you want user space to disable
autosuspend as the system is about to go to sleep. And it makes
relatively little sense, as enabling remote wakeup is the last thing
we do before the device suspends. Setting the filters long before that
doesn't make much sense.

> the PM core aren't adequate for what the driver needs.  The PM core 
> distinguishes between wakeup enabled or disabled; it doesn't 
> distinguish among different levels of wakekup.

True and sanely it cannot. We could only distinguish between drivers
which need their devices to be resumed before the system suspends and
the rest.
Or we tell driver coders to use the notifier chains.

	Regards
		Oliver
