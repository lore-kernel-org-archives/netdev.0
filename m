From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: SmPL for automatic request_firmware_nowait() conversion
Date: Tue, 24 Jun 2014 01:21:07 +0200
Message-ID: <20140623232107.GB27687@wotan.suse.de>
References: <20140621015714.GX4841@wotan.suse.de> <20140621105205.GA31611@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cocci@systeme.lip6.fr, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140621105205.GA31611@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 21, 2014 at 12:52:05PM +0200, Francois Romieu wrote:
> Luis R. Rodriguez <mcgrof@suse.com> :
> > I was just porting over an ethernet driver [0] to use request_firmware_nowait()
> > since firmware loading seems can take over a minute on one device, while
> > at it I noticed no other ethernet drivers yet use this API so figure
> > this may be a trend coming if devices are getting as complex as cxgb4.
> > The cxgb4 driver happens to even use the firmware API 3 times!
> 
> There should be no problem for the firmware requests issued through
> ethtool in cxgb4.

OK.

> 
> [...]
> > netdev: how worthy is this effort?
> 
> Biased comment below :o)
> 
> I'm wondering the benefit of automatic API changes when it could be argued
> that the symptoms call for driver dependant code rework.

I should have elaborated a bit more on motivation. Tons of drivers don't use
request_firmware_nowait() which means boot time is increased given that probe
won't complete until firmware loading completes. The cxgb4 driver is a good
example of one that takes quite a bit of time so learning that firmware loading
can take over a minute seemed to beg a rework to use request_firmware_nowait().
Note that in the worst case if udev is present in the worst case if the firmware
is not present loading can take up to timeout * num CPUs [0], but work is
underway to try to remove udev firmware loading support [1]. Regardless
then the current approach seemed to beg a rework.

[0] https://lkml.org/lkml/2013/10/23/264
[1] http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19440

> The 60 seconds delay is kind of a pavlovian signal: one can bet that the
> driver includes a request_firmware in its probe method. So does cxgb4.

The kernel's timeout is 60 seconds, and this is static, but lets be clear
that there is a difference between the timeout for reading the firmware
from the filesystem and actually dumping the firmware onto the device
by the driver and ensuring that the driver is done poking at it. The
kernel timeout is for the kernel reading it and tossing it back to the
driver.

> I still believe in the old school "request firmware from net_device_ops.open".
> I've been happy with it since f1e02ed109df5f99abf942b8ccc99960cb09dd38.

I was actually in the hopes a suitable transormation can be designed
to put a wait_for_completion() in say ndo_init(). I was looking to
see if a tranformation can be generalized of course if the above
observations on probe() is something desirable to be addressed.

> This kind of rework may not be trivial for cxgb4. Please get code tested on
> real hardware (modular/monolithic build, with/without firmware, etc.) as I
> won't argue against your crusade for cxgb4.

OK I'll look for hardware but if some folks already have it and are
interesed in some parts of this patch set my hope was that it can be
slightly modified to move the wait_for_completion() to an ndo_init() then
as well. That would really put better use of the API.

> Asynchronous firmware loading provides a rather nice high level API but
> it's imho not the essence of network devices firmware loading problems.

Agreed.

  Luis
