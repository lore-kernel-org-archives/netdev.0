From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Thu, 02 Aug 2012 16:03:30 -0700
Message-ID: <87vch0x5fh.fsf@xmission.com>
References: <5017E786.5000102@free.fr> <5017F96B.1060701@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <5017F96B.1060701@free.fr> (Bernard Pidoux's message of "Tue, 31
	Jul 2012 17:27:39 +0200")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernard Pidoux <bernard.pidoux@free.fr> writes:

> Here is a complementary observation.
> Trying to remove rose module with rmmod rose did not create any kernel panic.
> However, there is an endless message from the kernel saying :
>
> Message from syslogd@raspberrypi at Jul 31 17:22:40 ...
>  kernel:[  831.579007] unregister_netdevice: waiting for rose0 to become
> free. Usage count = 23
>
> Message from syslogd@raspberrypi at Jul 31 17:22:50 ...
>  kernel:[  841.739390] unregister_netdevice: waiting for rose0 to become
> free. Usage count = 23
>
> Message from syslogd@raspberrypi at Jul 31 17:23:00 ...
>  kernel:[  851.899758] unregister_netdevice: waiting for rose0 to become
> free. Usage count = 23
> .....
>
> As observed at many occasions, count number seems to be random ! and
> the same message keeps going without any change of count number.
> At the same time, there is no possibility to recover the command line on any
> console.
> However I could loggin via ssh and I noticed that rose0 device is actually no
> more in the ifconfig list.
>
> If I try to remove rose with rmmod rose I get :
>
> root@raspberrypi:/home/pi# rmmod rose
> libkmod: ERROR ../libkmod/libkmod-module.c:753 kmod_module_remove_module: could
> not remove 'rose': Device or resource busy
> Error: could not remove module rose: Device or resource busy
>
>
> Does this help ?

Something presumably in the rose code is leaking a reference to the rose
device.  That is probably a separate bug than your other one, but it may
be related.  These are some of my least favorite bugs to track down.

That said in rose there is only one call to dev_hold and only one call
to dev_put.

Hmm.  Looking at it dev_hold happens in rose_dev_get, and of which there
are several callers and only one of those callers calls dev_put.  So
it should just be a matter of adding some more dev_put calls in the
appropriate places.

The usage in rose_loopback_timer looks easy to fix, the usage in
rose_bind seems more of a challenge.

Are you enough of a developer to take that observation and look at
the code and fix it?

Eric
