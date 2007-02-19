From: Greg KH <gregkh@suse.de>
Subject: Re: Converting network devices from class devices causes namespace pollution
Date: Sun, 18 Feb 2007 19:01:14 -0800
Message-ID: <20070219030114.GA13666@suse.de>
References: <m1lkiv8npz.fsf@ebiederm.dsl.xmission.com> <20070218194641.GA9929@suse.de> <m1bqjr84fe.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:50510 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbXBSDCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Feb 2007 22:02:44 -0500
Content-Disposition: inline
In-Reply-To: <m1bqjr84fe.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 18, 2007 at 03:52:05PM -0700, Eric W. Biederman wrote:
> Greg KH <gregkh@suse.de> writes:
> 
> > On Sun, Feb 18, 2007 at 08:55:20AM -0700, Eric W. Biederman wrote:
> >> User space is allowed to rename network devices to anything any name
> >> not currently taken by another network device.
> >> 
> >> However when I now do something like:
> >> 
> >> ip link set eth0 name irq
> >> 
> >> The rename half happens (because it is legal), but sysfs can't support
> >> it because of the ridiculous directory eth0 is in.  After that
> >> point things go hideously wrong.
> >
> > What goes wrong?  What is not renamed properly?
> 
> It gets half renamed. 

Ick :(

> > Oh, you can't rename it to something like "irq".  Well that's pretty
> > foolish on your behalf :)
> 
> No it is pretty foolish on your behalf to add this extra restriction.
> Currently this is a worse set of restrictions than DOS had with
> it's magic character devices.

Hey, don't be mean here...

> >> The current situation is hideous namespace pollution, and breaks user
> >> space, and is only likely only a matter of time before we have a
> >> reasonable instead of an strained conflict of names.
> >
> > Do we really have a problem here?
> 
> Yes.

Actually, you are right, I fixed this problem over a year ago, and then
introduced it recently again :(

We need our own namespace for these devices, and we have it today
already.  Look if you enable CONFIG_SYSFS_DEPRECATED, or on a pre-2.6.19
machine at what shows up in the pci device directories:
$ ls -l /sys/devices/pci0000:00/0000:00:1c.0/0000:02:00.0/
total 0
lrwxrwxrwx  1 root root     0 2007-02-18 18:56 bus -> ../../../../bus/pci
-r--r--r--  1 root root  4096 2007-02-18 18:56 class
-rw-r--r--  1 root root  4096 2007-02-18 18:56 config
-r--r--r--  1 root root  4096 2007-02-18 13:06 device
lrwxrwxrwx  1 root root     0 2007-02-18 18:56 driver -> ../../../../bus/pci/drivers/tg3
-r--r--r--  1 root root  4096 2007-02-18 18:56 irq
-r--r--r--  1 root root  4096 2007-02-18 18:56 local_cpus
-r--r--r--  1 root root  4096 2007-02-18 18:56 modalias
lrwxrwxrwx  1 root root     0 2007-02-18 18:56 net:eth0 -> ../../../../class/net/eth0
drwxr-xr-x  2 root root     0 2007-02-12 08:06 power
-r--r--r--  1 root root  4096 2007-02-18 18:56 resource
-rw-------  1 root root 65536 2007-02-18 18:56 resource0
-r--r--r--  1 root root  4096 2007-02-18 13:06 subsystem_device
-r--r--r--  1 root root  4096 2007-02-18 13:06 subsystem_vendor
--w-------  1 root root  4096 2007-02-18 18:56 uevent
-r--r--r--  1 root root  4096 2007-02-18 13:06 vendor

So, all we need to do is rename these devices back to the "net:eth0"
name, and everything will be fine.  I'll work on fixing that tomorrow as
it will take a bit of hacking on the kobject symlink function and the
driver core code (but it gets us rid of a symlink in "compatiblity
mode", which is always a nice win...)

And thanks for your calm and reasoned statements in pointing out this
bug, it wasn't deliberate by any means :)

thanks,

greg k-h
