From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: 2.6.18-rc4-mm1: eth0: trigger_send() called with the transmitter
 busy
Date: Tue, 15 Aug 2006 01:01:07 +0200
Message-ID: <44E100B3.1060300@free.fr>
References: <20060813012454.f1d52189.akpm@osdl.org> <44E0B72C.6010503@free.fr> <44E0D7C1.7040509@free.fr> <200608142325.59054.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:8071 "EHLO smtp1-g19.free.fr")
	by vger.kernel.org with ESMTP id S965028AbWHNW7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 18:59:24 -0400
To: "Rafael J. Wysocki" <rjw@sisk.pl>
In-Reply-To: <200608142325.59054.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14.08.2006 23:25, Rafael J. Wysocki a =E9crit :
> On Monday 14 August 2006 22:06, Laurent Riffard wrote:
>> Le 14.08.2006 19:47, Laurent Riffard a =E9crit :
>>> Le 14.08.2006 18:50, Andrew Morton a =E9crit :
>>>> On Mon, 14 Aug 2006 16:38:47 +0200
>>>> Laurent Riffard <laurent.riffard@free.fr> wrote:
>>>>
>>>>> Le 13.08.2006 10:24, Andrew Morton a __crit :
>>>>>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.=
6.18-rc4/2.6.18-rc4-mm1/
>>>>> Hello,
>>>>>
>>>>> This morning, while trying to suspend to disk, my box started to =
loop=20
>>>>> displaying the following message:
>>>>> eth0: trigger_send() called with the transmitter busy.
>>>>>
>>>>> Here is the scenario. I booted 2.6.18-rc4-mm1 with this command l=
ine:
>>>>> root=3D/dev/vglinux1/lvroot video=3Dvesafb:ywrap,mtrr splash=3Dsi=
lent resume=3D/dev/hdb7 netconsole=3D@192.163.0.3/,@192.168.0.1/00:0E:9=
B:91:ED:72 init 1
>>>>>
>>>>> Then I issued:
>>>>> # echo 6 > /proc/sys/kernel/printk
>>>>> # echo disk > /sys/power/state
>>>> ne2k isn't <ahem> the most actively-maintained driver.
>>>>
>>>> But most (I think all) net drivers have problems during suspend wh=
en
>>>> netconsole is active.  Does disabling netconsole help?
>>> Yes it does.=20
>>> =20
>>>> Did this operation work OK in earlier kernels, with netconsole ena=
bled?
>>> It's the first time I see such a message. I can't speak for 2.6.18-=
rc3-mm2=20
>>> because it could not suspend at all (did hang right after=20
>>> "echo disk > /sys/power/state"), but it worked in earlier kernels.
>>>
>>> I'll try with plain 2.6.18-rc4.
>> Same problem with 2.6.18-rc4.
>=20
> I think something like this will help (untested):

Well, sort of: it sometimes works, which is better than not. I tried
about 10 times and it sometimes hangs after 'shrinking memory' or whils=
t=20
writing to the swap device. The message "eth0: trigger_send() called=20
with the transmitter busy" didn't appear anymore.

Note that I always have had a warning sowhere in acpi_pci_link_set duri=
ng suspend:
 BUG: sleeping function called from invalid context at include/asm/sema=
phore.h:99

I'm under the impression your patch is a workaround for my network prob=
lem.=20
Or must really netconsole be stopped during device_suspend ?

>  kernel/power/disk.c |    7 +++++++
>  1 files changed, 7 insertions(+)
>=20
> Index: linux-2.6.18-rc4-mm1/kernel/power/disk.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.18-rc4-mm1.orig/kernel/power/disk.c
> +++ linux-2.6.18-rc4-mm1/kernel/power/disk.c
> @@ -119,8 +119,10 @@ int pm_suspend_disk(void)
>  	if (error)
>  		return error;
> =20
> +	suspend_console();
>  	error =3D device_suspend(PMSG_FREEZE);
>  	if (error) {
> +		resume_console();
>  		printk("Some devices failed to suspend\n");
>  		unprepare_processes();
>  		return error;
> @@ -133,6 +135,7 @@ int pm_suspend_disk(void)
> =20
>  	if (in_suspend) {
>  		device_resume();
> +		resume_console();
>  		pr_debug("PM: writing image.\n");
>  		error =3D swsusp_write();
>  		if (!error)
> @@ -148,6 +151,7 @@ int pm_suspend_disk(void)
>  	swsusp_free();
>   Done:
>  	device_resume();
> +	resume_console();
>  	unprepare_processes();
>  	return error;
>  }
> @@ -212,7 +216,9 @@ static int software_resume(void)
> =20
>  	pr_debug("PM: Preparing devices for restore.\n");
> =20
> +	suspend_console();
>  	if ((error =3D device_suspend(PMSG_PRETHAW))) {
> +		resume_console();
>  		printk("Some devices failed to suspend\n");
>  		swsusp_free();
>  		goto Thaw;
> @@ -224,6 +230,7 @@ static int software_resume(void)
>  	swsusp_resume();
>  	pr_debug("PM: Restore failed, recovering.n");
>  	device_resume();
> +	resume_console();
>   Thaw:
>  	unprepare_processes();
>   Done:

BTW, it doesn't apply cleanly:

  CC      kernel/power/disk.o
kernel/power/disk.c: In function 'pm_suspend_disk':
kernel/power/disk.c:122: warning: implicit declaration of function 'sus=
pend_console'
kernel/power/disk.c:125: warning: implicit declaration of function 'res=
ume_console'
--=20
laurent

