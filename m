From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 16:46:38 -0300
Message-ID: <20130218164638.7cb53baa@redhat.com>
References: <20130218153316.GA2663@arwen.pp.htv.fi>
	<20130218155012.GA30974@kroah.com>
	<20130218155215.GB2663@arwen.pp.htv.fi>
	<20130218171334.GA31329@kroah.com>
	<20130218172700.GH2663@arwen.pp.htv.fi>
	<20130218174916.GA2070@kroah.com>
	<20130218184633.GC10755@arwen.pp.htv.fi>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20130218184633.GC10755@arwen.pp.htv.fi>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, 18 Feb 2013 20:46:33 +0200
Felipe Balbi <balbi@ti.com> escreveu:

> Hi, On Mon, Feb 18, 2013 at 09:49:16AM -0800, Greg KH wrote:
> > > Input/output error - /sys/devices/cpu/power/autosuspend_delay_ms
> > 
> > The issue with this file is, if the power.use_autosuspend flag is not
> > set for the device, then it can't be read or written to.  This flag
> > changes dynamically with the system state
> > (__pm_runtime_use_autosuspend() can change it), so we can't just not
> > show the file if the flag is not set properly, sorry.
> > 
> > So the "error" is correct here, as is the 0644 file value.
> 
> hmm... we could create the file at pm_runtime_enable() time and remove
> it on pm_runtime_disable() time, no ? Addin Rafael to Cc

...


> > 
> > > No such device - /sys/devices/system/edac/mc/mc0/sdram_scrub_rate
> > 
> > Odd, go ask the edac developers
> 
> will do ;-)

Well, the question is missing ;) /me assumes that you want to talk about
suspending/resume and EDAC, right?

In general, memory controllers don't supports suspend, as far as I can tell. 
Still, I've seen a few ones that support, but the current drivers and/or the
EDAC core currently doesn't offer any support to it, as such setup is done
by the BIOS, when it detects the used DIMM banks.

I suspect that, when the OS puts the machine on a suspend state, the BIOS may
also suspend also the memory controller or put it into a low power consumption
mode, but it does it without any help from the EDAC drivers.

For most of what's there at EDAC, I don't think it is worth to add any PM support
inside it. There are, however, two cases were we may need to add some support:

1) if user changed the SDRAM scrub rate before suspending, it makes sense to
restore it after resume, on the memory controller drivers that support such
feature (not all supports it);

2) hot-pluggable DIMMs. EDAC currently doesn't support. This could be needed
on some future. In this case, the core may need to re-scan the memory controller,
changing the memory properties. I've no idea if is there any real case needing
it, nor what event would trigger the memory-controller re-scan. Resume is likely
one of the candidates for it, on machines that support hot-pluggable memories.

Regards,
Mauro
