From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Sun, 25 May 2008 20:13:29 +0200
Message-ID: <20080525181329.GA5044@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080518150908.GA4606@yamamaya.is-a-geek.org> <20080525150444.GA29739@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:36105 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757091AbYEYSOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 14:14:06 -0400
Content-Disposition: inline
In-Reply-To: <20080525150444.GA29739@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> So my BIOS is not as borked as I thought and it should be possible
> to wake up the machine even with platform.  Further debugging will
> have to wait until at least next weekend though (maybe longer)...

Or maybe it doesn't have to wait, I was just too curious:

Summary first: I got platform mode to work!

After grepping and reading through kernel/power/disk.c and
(rather obfuscated) drivers/acpi/.* code, and reading up on
ACPI _GPE (General Purpose Event?), and having a look at my DSDT I
noticed two things:

1) The network controllers are assigned to their own _GPE bits(pins?):
|[...]
|    Scope (\_GPE)
|    {
|[...]
|        Method (_L0B, 0, NotSerialized)
|        {
|            Notify (\_SB.PCI0.MMAC, 0x02)
|        }
|
|        Method (_L0A, 0, NotSerialized)
|        {
|            Notify (\_SB.PCI0.MAC1, 0x02)
|        }
|[...]

2) drivers/acpi/sleep/proc.c registers a 'wakeup' file:
|        proc_create("wakeup", S_IFREG | S_IRUGO | S_IWUSR,
|                    acpi_root_dir, &acpi_system_wakeup_device_fops);

And I then remembered that someone said in
http://bugzilla.kernel.org/show_bug.cgi?id=3D8381
it works for him if he writes $MAGICVALUE into a proc file.

And yes, if I write 'MMAC' and 'MAC1' into /proc/acpi/wakeup, then
wake-on-lan works even in platform mode.

So...
AFAICS this bit of setup magic should not be required, because:

1) /proc/acpi/wakeup knows which pci device is associated to each GPE b=
it
|ranma@melchior:~$ cat /proc/acpi/wakeup=20
|Device	S-state	  Status   Sysfs node
|HUB0	  S5	 disabled  pci:0000:00:06.0
|XVR0	  S5	 disabled =20
|XVR1	  S5	 disabled  pci:0000:00:0e.0
|XVR2	  S5	 disabled =20
|XVR3	  S5	 disabled =20
|XVR4	  S5	 disabled =20
|XVR5	  S5	 disabled  pci:0000:00:0a.0
|UAR1	  S5	 disabled  pnp:00:09
|PS2K	  S4	 disabled  pnp:00:0b
|USB0	  S4	 disabled  pci:0000:00:02.0
|USB2	  S4	 disabled  pci:0000:00:02.1
|AZAD	  S5	 disabled  pci:0000:00:06.1
|MMAC	  S5	 enabled   pci:0000:00:08.0
|MAC1	  S5	 enabled   pci:0000:00:09.0
(values after manually enabling MMAC and MAC1)

2) kernel/power/disk.c calls hibernation_ops->enter(), which is
acpi_suspend_enter, which calls acpi_enable_wakeup_device, which
sets up GPE wakup bits.  This _should_ take care of enabling MMAC
and MAC1 automatically, but apparently does not work correctly at
some point.

I guess someone more knowledgable in ACPI stuff should have a look
at this.

Hope that helps,

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
