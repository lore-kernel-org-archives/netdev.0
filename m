From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: unlink URB when request timed out
Date: Mon, 10 Nov 2014 12:18:33 +0100
Message-ID: <54609F09.6070807@broadcom.com>
References: <545FAE05.2030701@gmail.com>
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
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:60338 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaKJLTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 06:19:51 -0500
In-Reply-To: <545FAE05.2030701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09-11-14 19:10, Mathy Vanhoef wrote:
> From: Mathy Vanhoef <vanhoefm@gmail.com>
> 
> Unlink the submitted URB in brcmf_usb_dl_cmd if the request timed out. This
> assures the URB is never submitted twice, preventing a driver crash.

Hi Mathy,

What driver crash are you referring to? The log only shows the WARNING
ending in a USB disconnect but no actual crash. Does your patch get the
driver running properly or does it only avoid the warning.

With that said, it seems there is some need for improvement, but I also
notice you are running this on a virtual machine so could that affect
the timeout to kick in before completion. Could you try to increase the
timeout. Still when a timeout occurs this needs to be handled properly.
Could you also try the following patch?

Regards,
Arend
---
 drivers/net/wireless/brcm80211/brcmfmac/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
b/drivers/net/wireles
index dc13591..786c40b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -640,7 +640,7 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info
*devinf
        char *tmpbuf;
        u16 size;

-       if ((!devinfo) || (devinfo->ctl_urb == NULL))
+       if (!devinfo || !devinfo->ctl_urb || !devinfo->ctl_completed)
                return -EINVAL;

        tmpbuf = kmalloc(buflen, GFP_ATOMIC);

> Signed-off-by: Mathy Vanhoef <vanhoefm@gmail.com>
> ---
> Currently brcmfmac may crash when a USB device is attached (tested with a LG
> TWFM-B003D). In particular it fails on the second call to brcmf_usb_dl_cmd in
> the while loop of brcmf_usb_resetcfg. The problem is that an URB is being
> submitted twice:
> 
> [  169.861800] brcmfmac: brcmf_usb_dl_writeimage Enter, fw f14db000, len 348160
> [  171.787791] brcmfmac: brcmf_usb_dl_writeimage Exit, err=0
> [  171.787797] brcmfmac: brcmf_usb_dlstart Exit, err=0
> [  171.787799] brcmfmac: brcmf_usb_dlrun Enter
> [  171.791794] brcmfmac: brcmf_usb_resetcfg Enter
> [  173.988072] ------------[ cut here ]------------
> [  173.988083] WARNING: CPU: 0 PID: 369 at drivers/usb/core/urb.c:339 usb_submit_urb+0x4e6/0x500()
> [  173.988085] URB eaf45f00 submitted while active
> [  173.988086] Modules linked in: brcmfmac brcmutil vmw_pvscsi pcnet32 mptspi mptscsih mptbase
> [  173.988100] CPU: 0 PID: 369 Comm: kworker/0:2 Not tainted 3.18.0-rc3-wl #1
> [  173.988102] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  173.988106] Workqueue: events request_firmware_work_func
> [  173.988108]  00000000 00000000 ee747db8 c1711f4a ee747df8 ee747de8 c103edaf c18d1e10
> [  173.988112]  ee747e14 00000171 c18a8b29 00000153 c1490556 c1490556 eaf45f00 eafdc660
> [  173.988115]  f14b8fa0 ee747e00 c103ee4e 00000009 ee747df8 c18d1e10 ee747e14 ee747e50
> [  173.988119] Call Trace:
> [  173.988129]  [<c1711f4a>] dump_stack+0x41/0x52
> [  173.988136]  [<c103edaf>] warn_slowpath_common+0x7f/0xa0
> [  173.988139]  [<c1490556>] ? usb_submit_urb+0x4e6/0x500
> [  173.988141]  [<c1490556>] ? usb_submit_urb+0x4e6/0x500
> [  173.988147]  [<f14b8fa0>] ? brcmf_usb_ioctl_resp_wake+0x40/0x40 [brcmfmac]
> [  173.988150]  [<c103ee4e>] warn_slowpath_fmt+0x2e/0x30
> [  173.988152]  [<c1490556>] usb_submit_urb+0x4e6/0x500
> [  173.988156]  [<c1123de1>] ? __kmalloc+0x21/0x140
> [  173.988161]  [<f14b91c3>] ? brcmf_usb_dl_cmd+0x33/0x120 [brcmfmac]
> [  173.988166]  [<f14b9243>] brcmf_usb_dl_cmd+0xb3/0x120 [brcmfmac]
> [  173.988170]  [<f14ba6c4>] brcmf_usb_probe_phase2+0x4e4/0x640 [brcmfmac]
> [  173.988176]  [<f14b4900>] brcmf_fw_request_code_done+0xd0/0xf0 [brcmfmac]
> [  173.988178]  [<c1400876>] request_firmware_work_func+0x26/0x50
> [  173.988182]  [<c10513ee>] process_one_work+0x11e/0x360
> [  173.988184]  [<c1051750>] worker_thread+0xf0/0x3c0
> [  173.988205]  [<c106e14a>] ? __wake_up_locked+0x1a/0x20
> [  173.988208]  [<c1051660>] ? process_scheduled_works+0x30/0x30
> [  173.988211]  [<c1055b56>] kthread+0x96/0xb0
> [  173.988214]  [<c1719c81>] ret_from_kernel_thread+0x21/0x30
> [  173.988217]  [<c1055ac0>] ? kthread_worker_fn+0x110/0x110
> [  173.988219] ---[ end trace 0c88bf46801de083 ]---
> [  173.988221] brcmf_usb_dl_cmd: usb_submit_urb failed -16
> [  173.988396] brcmfmac: brcmf_usb_probe_phase2 failed: dev=1-1, err=-19
> [  173.989503] brcmfmac: brcmf_usb_disconnect Enter
> 
> This patch fixes the brcmf_usb_dl_cmd function to prevent an URB from being
> submitted twice. Tested using a LG TWFM-B003D, which now works properly.
> 
> 
>  drivers/net/wireless/brcm80211/brcmfmac/usb.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> index 5265aa7..1bc7858 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
> @@ -738,10 +738,12 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info *devinfo, u8 cmd,
>  		goto finalize;
>  	}
>  
> -	if (!brcmf_usb_ioctl_resp_wait(devinfo))
> +	if (!brcmf_usb_ioctl_resp_wait(devinfo)) {
> +		usb_unlink_urb(devinfo->ctl_urb);
>  		ret = -ETIMEDOUT;
> -	else
> +	} else {
>  		memcpy(buffer, tmpbuf, buflen);
> +	}
>  
>  finalize:
>  	kfree(tmpbuf);
> 
