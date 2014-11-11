From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: unlink URB when request timed out
Date: Tue, 11 Nov 2014 12:05:39 +0100
Message-ID: <5461ED83.7070509@broadcom.com>
References: <545FAE05.2030701@gmail.com> <54609F09.6070807@broadcom.com> <5460E2FA.40201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Mathy Vanhoef <vanhoefm@gmail.com>, <brudley@broadcom.com>,
	<frankyl@broadcom.com>, <meuleman@broadcom.com>,
	<linville@tuxdriver.com>, <pieterpg@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:30205 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbaKKLFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 06:05:49 -0500
In-Reply-To: <5460E2FA.40201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-11-14 17:08, Mathy Vanhoef wrote:
> On 11/10/2014 06:18 AM, Arend van Spriel wrote:
>> On 09-11-14 19:10, Mathy Vanhoef wrote:
>>> From: Mathy Vanhoef <vanhoefm@gmail.com>
>>>
>>> Unlink the submitted URB in brcmf_usb_dl_cmd if the request timed out. This
>>> assures the URB is never submitted twice, preventing a driver crash.
>>
>> Hi Mathy,
>>
>> What driver crash are you referring to? The log only shows the WARNING
>> ending in a USB disconnect but no actual crash. Does your patch get the
>> driver running properly or does it only avoid the warning.
> 
> Hi Arend,
> 
> It shows a warning, after which the device doesn't work (but the computer is
> still usable). But I've noticed that when *unplugging* the USB cable the OS may
> freeze. This doesn't always happen though, sometimes unplugging works OK. The
> patch both avoids the warning, and gets the device/driver running properly
> (unplugging also works OK).
> 
>>
>> With that said, it seems there is some need for improvement, but I also
>> notice you are running this on a virtual machine so could that affect
>> the timeout to kick in before completion. Could you try to increase the
>> timeout. Still when a timeout occurs this needs to be handled properly.
>> Could you also try the following patch?
> 
> I did a few additional tests:
> 
> 1. When increasing IOCTL_RESP_TIMEOUT to 20000 (ten times the normal value) the
>    timeout and warning still occur. Device/driver doesn't work.
> 2. When increasing BRCMF_USB_RESET_GETVER_SPINWAIT to 1000 (ten timers the
>    normal value) everything works. Device/driver works.

This means the ctl_urb completes on your system within 3sec, but not
within 2.1sec. After discussing this with my colleague, we think you
should use usb_kill_urb() instead of usb_unlink_urb() as it assures the
completion handler is called. Could you retest that and let us know.

Regards,
Arend

> 3. Quick test using backports-3.18-rc1-1 (aka unpatched driver) on a non-
>    virtualized Linux install: In that case everything worked fine. So the bug
>    may only be triggered in a virtualized environment / VMWare.
> 4. When applying your patch, the driver stops early during initialization of
>    the device. I included a WARN_ONCE before returning EINVAL and got the
>    output below.
> 
> Kind regards,
> Mathy
> ---
> [  220.955647] usb 1-1: new high-speed USB device number 3 using ehci-pci
> [  221.487797] usb 1-1: New USB device found, idVendor=043e, idProduct=3004
> [  221.487802] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> [  221.487804] usb 1-1: Product: Remote Download Wireless Adapter
> [  221.487806] usb 1-1: Manufacturer: Broadcom
> [  221.487808] usb 1-1: SerialNumber: 000000000001
> [  221.490472] brcmfmac: brcmf_usb_probe Enter 0x043e:0x3004
> [  221.490476] brcmfmac: brcmf_usb_probe Broadcom high speed USB WLAN interface detected
> [  221.490477] brcmfmac: brcmf_usb_probe_cb Enter
> [  221.490480] brcmfmac: brcmf_usb_attach Enter
> [  221.490494] brcmfmac: brcmf_usb_dlneeded Enter
> [  221.490495] ------------[ cut here ]------------
> [  221.490503] WARNING: CPU: 0 PID: 100 at drivers/net/wireless/brcm80211/brcmfmac/usb.c:716 brcmf_usb_dl_cmd+0x75/0x1a0 [brcmfmac]()
> [  221.490505] EINVAL devinfo=c0044000 ctl_rub=ef898380 completed=0
> [  221.490506] Modules linked in: brcmfmac brcmutil vmw_pvscsi pcnet32 mptspi mptscsih mptbase
> [  221.490514] CPU: 0 PID: 100 Comm: kworker/0:1 Not tainted 3.18.0-rc3-wl+ #2
> [  221.490515] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  221.490528] Workqueue: usb_hub_wq hub_event
> [  221.490530]  00000000 00000000 eecffb58 c1711f4a eecffb98 eecffb88 c103edaf f11cbc58
> [  221.490534]  eecffbb4 00000064 f11cbc84 000002cc f11c1595 f11c1595 c0044000 ffffffea
> [  221.490537]  ef726000 eecffba0 c103ee4e 00000009 eecffb98 f11cbc58 eecffbb4 eecffbd0
> [  221.490541] Call Trace:
> [  221.490550]  [<c1711f4a>] dump_stack+0x41/0x52
> [  221.490558]  [<c103edaf>] warn_slowpath_common+0x7f/0xa0
> [  221.490563]  [<f11c1595>] ? brcmf_usb_dl_cmd+0x75/0x1a0 [brcmfmac]
> [  221.490567]  [<f11c1595>] ? brcmf_usb_dl_cmd+0x75/0x1a0 [brcmfmac]
> [  221.490570]  [<c103ee4e>] warn_slowpath_fmt+0x2e/0x30
> [  221.490575]  [<f11c1595>] brcmf_usb_dl_cmd+0x75/0x1a0 [brcmfmac]
> [  221.490580]  [<f11c2cd8>] brcmf_usb_probe+0x3c8/0x640 [brcmfmac]
> [  221.490583]  [<c1717d53>] ? mutex_lock+0x13/0x32
> [  221.490586]  [<c1493ae3>] usb_probe_interface+0xa3/0x180
> [  221.490590]  [<c13f5690>] ? __driver_attach+0x90/0x90
> [  221.490592]  [<c13f546e>] driver_probe_device+0x5e/0x1f0
> [  221.490595]  [<c13f5690>] ? __driver_attach+0x90/0x90
> [  221.490597]  [<c13f56c9>] __device_attach+0x39/0x50
> [  221.490600]  [<c13f3d84>] bus_for_each_drv+0x34/0x70
> [  221.490602]  [<c13f53db>] device_attach+0x7b/0x90
> [  221.490604]  [<c13f5690>] ? __driver_attach+0x90/0x90
> [  221.490607]  [<c13f4b8f>] bus_probe_device+0x6f/0x90
> [  221.490609]  [<c13f3256>] device_add+0x426/0x520
> [  221.490611]  [<c1491503>] ? usb_control_msg+0xb3/0xd0
> [  221.490614]  [<c1717d53>] ? mutex_lock+0x13/0x32
> [  221.490627]  [<c14922f8>] usb_set_configuration+0x3f8/0x700
> [  221.490630]  [<c13f5690>] ? __driver_attach+0x90/0x90
> [  221.490633]  [<c149ac7b>] generic_probe+0x2b/0x90
> [  221.490637]  [<c1188bc0>] ? sysfs_create_link+0x20/0x40
> [  221.490639]  [<c1492bec>] usb_probe_device+0xc/0x10
> [  221.490641]  [<c13f546e>] driver_probe_device+0x5e/0x1f0
> [  221.490644]  [<c13f5690>] ? __driver_attach+0x90/0x90
> [  221.490646]  [<c13f56c9>] __device_attach+0x39/0x50
> [  221.490649]  [<c13f3d84>] bus_for_each_drv+0x34/0x70
> [  221.490651]  [<c13f53db>] device_attach+0x7b/0x90
> [  221.490653]  [<c13f5690>] ? __driver_attach+0x90/0x90
> [  221.490656]  [<c13f4b8f>] bus_probe_device+0x6f/0x90
> [  221.490658]  [<c13f3256>] device_add+0x426/0x520
> [  221.490661]  [<c148aa2e>] ? usb_new_device+0x16e/0x3a0
> [  221.490663]  [<c148aad7>] usb_new_device+0x217/0x3a0
> [  221.490666]  [<c148bff7>] hub_event+0xa17/0xda0
> [  221.490668]  [<c1716918>] ? __schedule+0x2f8/0x710
> [  221.490672]  [<c105127c>] ? pwq_dec_nr_in_flight+0x3c/0x90
> [  221.490674]  [<c10513ee>] process_one_work+0x11e/0x360
> [  221.490677]  [<c1051750>] worker_thread+0xf0/0x3c0
> [  221.490680]  [<c106e14a>] ? __wake_up_locked+0x1a/0x20
> [  221.490682]  [<c1051660>] ? process_scheduled_works+0x30/0x30
> [  221.490685]  [<c1055b56>] kthread+0x96/0xb0
> [  221.490687]  [<c1050000>] ? put_unbound_pool+0x110/0x170
> [  221.490691]  [<c1719c81>] ret_from_kernel_thread+0x21/0x30
> [  221.490693]  [<c1055ac0>] ? kthread_worker_fn+0x110/0x110
> [  221.490695] ---[ end trace 9befd914693f3083 ]---
> [  221.490697] brcmfmac: brcmf_usb_dlneeded chip 57005 rev 0xf11cfcec
> [  221.490699] brcmfmac: brcmf_fw_get_firmwares enter: dev=1-1
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> index 5265aa7..15b1aa7 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> @@ -709,8 +709,13 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info *devinfo, u8 cmd,
>  	char *tmpbuf;
>  	u16 size;
>  
> -	if ((!devinfo) || (devinfo->ctl_urb == NULL))
> +	if (!devinfo || !devinfo->ctl_urb || !devinfo->ctl_completed) {
> +		WARN_ONCE(1, "EINVAL devinfo=%p ctl_rub=%p completed=%d\n",
> +			devinfo,
> +			devinfo ? devinfo->ctl_urb : NULL,
> +			devinfo ? devinfo->ctl_completed : -1);
>  		return -EINVAL;
> +	}
>  
>  	tmpbuf = kmalloc(buflen, GFP_ATOMIC);
>  	if (!tmpbuf)
> 
> 
>>
>> Regards,
>> Arend
>> ---
>>  drivers/net/wireless/brcm80211/brcmfmac/usb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>> b/drivers/net/wireles
>> index dc13591..786c40b 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>> @@ -640,7 +640,7 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info
>> *devinf
>>         char *tmpbuf;
>>         u16 size;
>>
>> -       if ((!devinfo) || (devinfo->ctl_urb == NULL))
>> +       if (!devinfo || !devinfo->ctl_urb || !devinfo->ctl_completed)
>>                 return -EINVAL;
>>
>>         tmpbuf = kmalloc(buflen, GFP_ATOMIC);
>>
>>> Signed-off-by: Mathy Vanhoef <vanhoefm@gmail.com>
>>> ---
>>> Currently brcmfmac may crash when a USB device is attached (tested with a LG
>>> TWFM-B003D). In particular it fails on the second call to brcmf_usb_dl_cmd in
>>> the while loop of brcmf_usb_resetcfg. The problem is that an URB is being
>>> submitted twice:
>>>
>>> [  169.861800] brcmfmac: brcmf_usb_dl_writeimage Enter, fw f14db000, len 348160
>>> [  171.787791] brcmfmac: brcmf_usb_dl_writeimage Exit, err=0
>>> [  171.787797] brcmfmac: brcmf_usb_dlstart Exit, err=0
>>> [  171.787799] brcmfmac: brcmf_usb_dlrun Enter
>>> [  171.791794] brcmfmac: brcmf_usb_resetcfg Enter
>>> [  173.988072] ------------[ cut here ]------------
>>> [  173.988083] WARNING: CPU: 0 PID: 369 at drivers/usb/core/urb.c:339 usb_submit_urb+0x4e6/0x500()
>>> [  173.988085] URB eaf45f00 submitted while active
>>> [  173.988086] Modules linked in: brcmfmac brcmutil vmw_pvscsi pcnet32 mptspi mptscsih mptbase
>>> [  173.988100] CPU: 0 PID: 369 Comm: kworker/0:2 Not tainted 3.18.0-rc3-wl #1
>>> [  173.988102] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
>>> [  173.988106] Workqueue: events request_firmware_work_func
>>> [  173.988108]  00000000 00000000 ee747db8 c1711f4a ee747df8 ee747de8 c103edaf c18d1e10
>>> [  173.988112]  ee747e14 00000171 c18a8b29 00000153 c1490556 c1490556 eaf45f00 eafdc660
>>> [  173.988115]  f14b8fa0 ee747e00 c103ee4e 00000009 ee747df8 c18d1e10 ee747e14 ee747e50
>>> [  173.988119] Call Trace:
>>> [  173.988129]  [<c1711f4a>] dump_stack+0x41/0x52
>>> [  173.988136]  [<c103edaf>] warn_slowpath_common+0x7f/0xa0
>>> [  173.988139]  [<c1490556>] ? usb_submit_urb+0x4e6/0x500
>>> [  173.988141]  [<c1490556>] ? usb_submit_urb+0x4e6/0x500
>>> [  173.988147]  [<f14b8fa0>] ? brcmf_usb_ioctl_resp_wake+0x40/0x40 [brcmfmac]
>>> [  173.988150]  [<c103ee4e>] warn_slowpath_fmt+0x2e/0x30
>>> [  173.988152]  [<c1490556>] usb_submit_urb+0x4e6/0x500
>>> [  173.988156]  [<c1123de1>] ? __kmalloc+0x21/0x140
>>> [  173.988161]  [<f14b91c3>] ? brcmf_usb_dl_cmd+0x33/0x120 [brcmfmac]
>>> [  173.988166]  [<f14b9243>] brcmf_usb_dl_cmd+0xb3/0x120 [brcmfmac]
>>> [  173.988170]  [<f14ba6c4>] brcmf_usb_probe_phase2+0x4e4/0x640 [brcmfmac]
>>> [  173.988176]  [<f14b4900>] brcmf_fw_request_code_done+0xd0/0xf0 [brcmfmac]
>>> [  173.988178]  [<c1400876>] request_firmware_work_func+0x26/0x50
>>> [  173.988182]  [<c10513ee>] process_one_work+0x11e/0x360
>>> [  173.988184]  [<c1051750>] worker_thread+0xf0/0x3c0
>>> [  173.988205]  [<c106e14a>] ? __wake_up_locked+0x1a/0x20
>>> [  173.988208]  [<c1051660>] ? process_scheduled_works+0x30/0x30
>>> [  173.988211]  [<c1055b56>] kthread+0x96/0xb0
>>> [  173.988214]  [<c1719c81>] ret_from_kernel_thread+0x21/0x30
>>> [  173.988217]  [<c1055ac0>] ? kthread_worker_fn+0x110/0x110
>>> [  173.988219] ---[ end trace 0c88bf46801de083 ]---
>>> [  173.988221] brcmf_usb_dl_cmd: usb_submit_urb failed -16
>>> [  173.988396] brcmfmac: brcmf_usb_probe_phase2 failed: dev=1-1, err=-19
>>> [  173.989503] brcmfmac: brcmf_usb_disconnect Enter
>>>
>>> This patch fixes the brcmf_usb_dl_cmd function to prevent an URB from being
>>> submitted twice. Tested using a LG TWFM-B003D, which now works properly.
>>>
>>>
>>>  drivers/net/wireless/brcm80211/brcmfmac/usb.c |    6 ++++--
>>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>>> index 5265aa7..1bc7858 100644
>>> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>>> @@ -738,10 +738,12 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info *devinfo, u8 cmd,
>>>  		goto finalize;
>>>  	}
>>>  
>>> -	if (!brcmf_usb_ioctl_resp_wait(devinfo))
>>> +	if (!brcmf_usb_ioctl_resp_wait(devinfo)) {
>>> +		usb_unlink_urb(devinfo->ctl_urb);
>>>  		ret = -ETIMEDOUT;
>>> -	else
>>> +	} else {
>>>  		memcpy(buffer, tmpbuf, buflen);
>>> +	}
>>>  
>>>  finalize:
>>>  	kfree(tmpbuf);
>>>
>>
