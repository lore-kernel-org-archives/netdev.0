From: Ray Cole <ray_cole@earthlink.net>
Subject: Re: r8169 driver in 2.6.6
Date: Tue, 25 May 2004 23:11:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525231140.1325daa7.ray_cole@earthlink.net>
References: <20040524210148.2172d684.ray_cole@earthlink.net>
	<20040525091915.A12162@electric-eye.fr.zoreil.com>
	<20040525230831.4747005f.ray_cole@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
In-Reply-To: <20040525230831.4747005f.ray_cole@earthlink.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Oh...forgot to mention where this line was at :-)  rtl8169_start_xmit is the function...

On Tue, 25 May 2004 23:08:31 -0500
Ray Cole <ray_cole@earthlink.net> wrote:

> I found the problem - I think.  At least I'll say I found a line of code that I modified and it started working :-)
> 
> Here is the offending line:
> 
> 		tp->TxDescArray[entry].status = cpu_to_le32(OWNbit | FSbit |
> 			LSbit | len | (EORbit * !((entry + 1) % NUM_TX_DESC)));
> 
> Here is what I changed it into (based on the 2.6.5 flavor of r8169.c):
> 
> 		if (entry != (NUM_TX_DESC - 1))
> 			tp->TxDescArray[entry].status =
> 			    (OWNbit | FSbit | LSbit) | len;
> 		else
> 			tp->TxDescArray[entry].status =
> 			    (OWNbit | EORbit | FSbit | LSbit) | len;
> 
> Once I changed this it started working great.  I picked up on this when I noticed it was only sending 64 packets then failing.  I looked for differences in the way 2.6.5 and 2.6.6 handled a full transmit ring and this line looked suspicious...I figure it is perhaps a difference in the compiler I'm using (2.95.3) vs what others using this module are using...perhaps?
> 
> -- Ray		
> 
> 
> On Tue, 25 May 2004 09:19:15 +0200
> Francois Romieu <romieu@fr.zoreil.com> wrote:
> 
> > Ray Cole <ray_cole@earthlink.net> :
> > [...]
> > > I was wondering if you were aware of such issues in the 2.6.6 flavor of
> > > r8169.  If not, I'm more than willing to provide any information you need.
> > 
> > Nope, you are the first one. If time permits today, I'll check if the mobo
> > appears on the usual suspects list.
> > 
> > >  Either way I'm more than willing to try any patches for it.
> > 
> > Nice :o)
> > 
> > > Attach is my config for the kernel in case that helps.  Oh, BTW, I don't
> > > actually have a gigbit network - running a 100M network.  I don't know if
> > > that makes any difference or not.  I also don't see any error messages when
> > 
> > It may make things simpler.
> > 
> > > the network stops working (aside from my application, which simply reports
> > > a timeout error communicating with the POP email server :-)
> > 
> > Some more information may help. Typically:
> > - lspci -vx output
> > - dmesg after boot and insertion of the module (usually a combination of
> >   /var/log/dmesg and 'dmesg' output as this one may be truncated)
> > - lsmod output
> > - /proc/interrupts contents before/after foobar
> > - which (if any) was the latest known working kernel, be it 2.4.x or 2.6.x
> >   (2.5.5 apparently) ?
> > - can you enumerate all the dysfunctionnal kernel ?
> > - which distribution/compiler ?
> > - does it still fail if you do a simple 'ping' for an extended period of
> >   time instead of pop (same thing with lengthy ftp/http transfer, say a file
> >   of a few megs) ?
> > 
> > A few things you may want to try:
> > - disable ACPI (acpi=none on the boot cmd line, do not confuse it with APIC)
> > - PREEMPT may change a few things though it is less on the radar than ACPI
> > - http://www.fr.zoreil.com/people/francois/misc/20040525-2.6.7-rc1-r8169.c-test.patch applied on 2.6.6 (some link related things may come into play but
> >   I am a bit sceptical)
> > - as the system does not hang (only the network trafic), can you see if
> >   it makes a difference if you
> >   - ifconfig down/up the network card ?
> >   - same thing + removal/insertion of the driver ?
> >   - unplug/plug again the cable (wait for 10~15 seconds then) ?
> >   -> dmesg output welcome.
> > 
> > Please Cc: future traffic to netdev@oss.sgi.com as well (if you can tell
> > sylphid to cut the lines at 72/80 chars, I will not complain either :o) ).
> > 
> > Do not hesitate to ping me if you feel like I forget your problem (I try
> > to avoid it but it may happen).
> > 
> > --
> > Ueimor
