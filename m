From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: (4.3.0) r8152: deadlock related to runtime suspend?
Date: Mon, 7 Dec 2015 12:22:32 +0100
Message-ID: <20151207112232.GB4283@al>
References: <20151205105912.GA1766@al>
 <56654D56.3080402@linux.intel.com>
 <20151207093755.GA4283@al>
 <566568C2.60004@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, hayeswang@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lu Baolu <baolu.lu@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lekensteyn.nl ([178.21.112.251]:40500 "EHLO lekensteyn.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664AbbLGLWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 06:22:41 -0500
Content-Disposition: inline
In-Reply-To: <566568C2.60004@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2015 at 07:08:50PM +0800, Lu Baolu wrote:
> 
> 
> On 12/07/2015 05:37 PM, Peter Wu wrote:
> > On Mon, Dec 07, 2015 at 05:11:50PM +0800, Lu Baolu wrote:
> >> Hi Peter,
> >>
> >> Have you ever tried disabling auto-pm? Did things go smoothly if auto-pm is disabled?
> >>
> >> I always disable usb auto-pm in below way.
> >>
> >> # echo on | tee /sys/bus/usb/devices/*/power/control
> >> # echo on > /sys/bus/pci/devices/<bus_name>/power/control
> >>
> >> Thanks,
> >> Baolu
> > Hi Baolu,
> >
> > The deadlock does not seem to occur with auto-PM disabled, but that is a
> > workaround for the issue. The hang can always be reproduced under this
> > test:
> >
> >  - Start a QEMU VM, passing through the USB adapter
> 
> I would suggest you to start with bare metal.
> 
> When you pass through the host controller to a guest VM, you
> probably use IOMMU unit to let hardware access the memory
> directly, but things like pci configure space access, interrupt and
> IO port access still rely on QEMU. This introduces a lot of complexities.

It is a USB device, not a PCI device, so such issues do not apply here
I think.

I have found a possible reason for this lockup. The resume code may
execute napi_disable while napi_enable was not called before. This
autoresume thing happens in the open function which explains why all
other rtnl users are blocked.

Is this a sane analysis?

Kind regards,
Peter

> Thanks,
> Baolu
> 
> >  - This VM boots to a busybox shell with no other services running or
> >    udev magic (to reduce interference).
> >  - Enable runtime PM for all devices by default (see script below)
> >  - From the console, invoke "ip link set eth1 up" (eth0 is a virtio
> >    adapter).
> >
> >     # somewhere in /init after mounting filesystems
> >     echo /sbin/hotplug > /proc/sys/kernel/hotplug
> >     echo auto | tee  /sys/bus/pci/devices/*/power/control \
> >         /sys/bus/usb/devices/*/power/control >/dev/null
> >
> >     #!/bin/sh
> >     # /sbin/hotplug
> >     path="/sys/$DEVPATH/power/control"
> >     [ -e "$path" ] || return
> >     newval=auto
> >     read status < "$path"
> >     if [ "x$status" != "x$newval" ]; then
> >         echo "$DEVPATH: $status -> $newval" >/dev/kmsg
> >         echo $newval > "$path"
> >     fi
> >
> > With "auto", the ip command hangs (a trace can be found on the bottom of
> > this mail). With "on", it does not.
> >
> > If I keep a loop spinning that invokes `ethtool eth1`, the command
> > returns immediately without issues (presumably because the device is not
> > suspended through runtime PM).
> >
> > Under some circumstances I get a lockdep warning (when trying to bring
> > an interface down if I remember correctly). Its trace can be found on
> > the bottom of this mail.
> >
> > I'll keep testing. For the lockdep warning, my initial guess is that
> > calling schedule_delayed_work_sync under tp->lock is a bad idea because
> > scheduled work can execute and try to claim tp->lock too.
> >
> > Maybe there are two different lockup cases here, I'll keep testing.
> >
> > Kind regards,
> > Peter
> >
> >> On 12/05/2015 06:59 PM, Peter Wu wrote:
> >>> Hi,
> >>>
> >>> I rarely use a Realtek USB 3.0 Gigabit Ethernet adapter (vid/pid
> >>> 0bda:8153), but when I did last night, it resulted in a lockup of
> >>> processes doing networking ("ip link", "ping", "ethtool", ...).
> >>>
> >>> A (few) minute(s) before that event, I noticed that there was no network
> >>> connectivity (ping hung) which was somehow solved by invoking "ethtool
> >>> eth1" (triggering runtime pm wakeup?). This same trick did not work at
> >>> the next event. Invoking "ethtool eth1", "ip link", etc. hung completely
> >>> and interrupt (^C) did not work at all.
> >>>
> >>> Since that did not work, I pulled the USB adapter and re-inserted it,
> >>> hoping it would reset things. That did not work at all, there was a
> >>> "usb disconnect" message, but no further driver messages.
> >>>
> >>> Fast forward an hour, and it has become a disaster. I have terminated
> >>> and killed many programs via SysRq but am still unable to get a stable
> >>> system that does not hang on network I/O. Even the suspend process
> >>> fails so in the end I attempted to shutdown the system. After half an
> >>> hour after getting the poweroff message, I issued SysRq + B to reboot
> >>> (since SysRq + O did not shut down either).
> >>>
> >>> Attached are logs with various various backtraces from SysRq and failed
> >>> suspend. Let me know if you need more information!
> >>>
> >>> By the way, often I have to rmmod xhci and re-insert it, otherwise
> >>> plugging it in does not result in a detection. A USB 2.0 port does not
> >>> have this problem (runtime PM is enabled for all devices). This is the
> >>> USB 3.0 port:
> >>>
> >>>     02:00.0 USB controller [0c03]: NEC Corporation uPD720200 USB 3.0
> >>>     Host Controller [1033:0194] (rev 03)
> 

-- 
Kind regards,
Peter Wu
https://lekensteyn.nl
