From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Fw: [Bugme-new] [Bug 7952] New: slattach only works every other time
Date: Mon, 12 Feb 2007 09:36:09 +0100
Message-ID: <20070212083609.GA1946@ff.dom.local>
References: <20070206135754.0a0415b9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	mfuzzey@mailclub.net,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:49519 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933122AbXBLIdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 03:33:04 -0500
Content-Disposition: inline
In-Reply-To: <20070206135754.0a0415b9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-02-2007 22:57, Andrew Morton wrote:
...
> First time slattach is run to set up a SLIP line all is ok.
> If slattach process is then killed and restarted it fails with message:
> SLIP_set_disc(1): File exists
> Problem still occurs in 2.6.20rc6 kernel
> 
> dmesg shows:
> object_add failed for sl0 with -EEXIST, don't try to register things 
> with the same name in the same directory.
>  [<c01b7b54>] kobject_add+0x147/0x16d
>  [<c0211209>] class_device_add+0x9d/0x3b3
>  [<c022829d>] register_netdevice+0x21a/0x2d0
>  [<c8903213>] slip_open+0x3a1/0x4e2 [slip]
>  [<c01fc709>] tty_ioctl+0x922/0xbac
... 
> Steps to reproduce:
> (requires a serial port but nothing needs to be attached to it):
> # slattach -L -vd -p slip -s 115200 /dev/ttyS0
...
> slip started on /dev/ttyS0 interface sl0
> 
> Above is OK, now kill process with CTRL-C
> 
> slattach: tty_set_speed: 0
> # slattach -L -vd -p slip -s 115200 /dev/ttyS0
...
> SLIP_set_disc(1): File exists
...
> I believe this is called by this changeset :
> http://www2.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.17.y.git;a=commit;h=b17a7c179dd3ce7d04373fddf660eda21efc9db9

I think Martin is probably right here.

It would be useful to check if time has anything to do
with this and wait longer (e.g. >= 1 min.) before the
second slattach.

Anyway, even if there is some other reason, the above
trace shows (IMHO) some inconsistency in register/
unregister_netdevice: if class_device_add is reached
it means the name is valid (so was unregistered) and
EEXIST from netdev_register_sysfs is wrong about the
state of this device. So maybe there should be some
warning plus some delayed action instead of register
cancelled?

Regards,
Jarek P. 
