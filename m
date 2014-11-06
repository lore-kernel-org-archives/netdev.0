From: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Subject: RE: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net onarndale platform
Date: Thu, 6 Nov 2014 15:01:56 +0100
Message-ID: <C89EFD3CD56F64468D3D206D683A8D22039FFE39@ldam-msx2.fugro-nl.local>
References: <C89EFD3CD56F64468D3D206D683A8D2203985F49@ldam-msx2.fugro-nl.local> <20141104094336.GA3145@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D2203985FA9@ldam-msx2.fugro-nl.local> <20141104200914.GN23178@opensource.wolfsonmicro.com> <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local> <20141105150258.GR23178@opensource.wolfsonmicro.com> <20141106090651.GA19109@afflict.kos.to> <20141106100104.GS23178@opensource.wolfsonmicro.com> <20141106120416.GA20162@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D22039FFE16@ldam-msx2.fugro-nl.local> <20141106124653.GV23178@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Riku Voipio" <riku.voipio@iki.fi>, <freddy@asix.com.tw>,
	<davem@davemloft.net>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-samsung-soc@vger.kernel.org>
To: "Charles Keepax" <ckeepax@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20141106124653.GV23178@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Charles and Riku,

I've quickly tested this on a 3.10 kernel i had around;
I enabled CONFIG_PM, CONFIG_PM_RUNTIME, CONFIG_PM_AUTOSLEEP,
CONFIG_SUSPEND, CONFIG_SUSPEND_FREEZER, CONFIG_FREEZER in the kernel (by
default they are disabled for our setup, I enabled anything regarded to
runtime powermanagement to be sure I would trigger suspend/resume).

Then:
cd /sys/bus/usb/devices/1-2/power
echo auto > control
echo 1 > autosuspend
echo 0 > autosuspend_delay_ms
echo enabled > wakeup

# make sure there's no processes routing traffic over the eth1 interface

ifconfig eth1 down
sleep 4 # sleep some arbitrary long time
ifconfig eth1 up

check dmesg; it will reset back to 100 Mbps/full duplex.

This confirms that the suspend / resume does not work well. So long as
the suspend is not triggered, it does seem to work, though. I cannot say
whether the original issue that triggered this is still around; the ASIX
chip setup we use is soldered to the PCB and hooked up to a fixed device
on-board. 
I also tried to ping the device on the other side of the ASIX chip after
the suspend/resume cycle, I could not ping it. I cannot conclusively say
that this is due to the ASIX driver, as the device on the other side
does not like switching PHY speeds (it may go into a non-responsive
state). It is for this reason that we run it at half duplex/ 10Mbps at
all times.

As said; we are not using this kind of power management, so it does not
raise any issues for us. I am merely pointing out that this may need
work (in the future?).

Kind regards,

Michel Stam
-----Original Message-----
From: Charles Keepax [mailto:ckeepax@opensource.wolfsonmicro.com] 
Sent: Thursday, November 06, 2014 13:47 PM
To: Stam, Michel [FINT]
Cc: Riku Voipio; freddy@asix.com.tw; davem@davemloft.net;
linux-usb@vger.kernel.org; netdev@vger.kernel.org;
linux-kernel@vger.kernel.org; linux-samsung-soc@vger.kernel.org
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net
onarndale platform

On Thu, Nov 06, 2014 at 01:39:07PM +0100, Stam, Michel [FINT] wrote:
> Hello Riku and Charles,
> 
> I tried this with my original patch and the suggested patch applied, 
> this seems to work for me too.
> 
> One thing that bothers me, is the suspend / resume situation; usbnet.c

> seems to call the bind( ) on probe( ). Suspend / resume do not seem to

> call bind( ) directly.
> 
> As Riku pointed out, the original patch I reverted was because of 
> suspend/resume issues. I wonder if this will still work?

I seem to remember I had a few issues with Arndale suspend and resume
last time I tried it anyways, so not sure I will be able to test for
that. But I will have a go. But in either case I guess a fix for that is
probably orthogonal to my suggested fix here, as it looks pretty clear
we intended to fully reset the device in bind and were appartently not
doing that. So this patch is probably a needed fix anyway. Even if there
are seperate issues relating to suspend and resume.

Thanks,
Charles
