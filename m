From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] r8152: correct error returns
Date: Sun, 03 Aug 2014 09:06:58 +0200
Message-ID: <1407049618.26893.8.camel@linux-fkkt.site>
References: <1406901370-6847-1-git-send-email-oneukum@suse.de>
	 <20140802.163418.1314777407262254543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44638 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaHCHHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2014 03:07:03 -0400
In-Reply-To: <20140802.163418.1314777407262254543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-08-02 at 16:34 -0700, David Miller wrote:
> From: Oliver Neukum <oneukum@suse.de>
> Date: Fri,  1 Aug 2014 15:56:10 +0200
> 
> > If an autoresume fails the internal error codes of the PM
> > subsystem mustn't be leaked to user space. Replace them by EIO
> > 
> > Signed-off-by: Oliver Neukum <oneukum@suse.de>
> 
> Really?

Yes. You can get results like returning -EINVAL
from open().

You can call down into
drivers/core/power/runtime.c::static int rpm_resume(struct device *dev,
int rpmflags)

As you can see it uses errors in its own ways:

static int rpm_resume(struct device *dev, int rpmflags)
        __releases(&dev->power.lock) __acquires(&dev->power.lock)
{
        int (*callback)(struct device *);
        struct device *parent = NULL;
        int retval = 0;

        trace_rpm_resume(dev, rpmflags);

 repeat:
        if (dev->power.runtime_error)
                retval = -EINVAL;
        else if (dev->power.disable_depth == 1 &&
dev->power.is_suspended
            && dev->power.runtime_status == RPM_ACTIVE)
                retval = 1;
        else if (dev->power.disable_depth > 0)
                retval = -EACCES;
        if (retval)
                goto out;

The call chain is
usb_autopm_get_interface()->pm_runtime_get_sync()->__pm_runtime_resume()
->rpm_resume()

> Then even the core usbnet driver gets this wrong, as well as many
> other drivers I scanned over for this problem.

OK, I just looked at this single driver. I'll try to come up with
a generic solution. The mapping is a bit simplistic. I should let
-ENOMEM pass for example.

	Regards
		Oliver
