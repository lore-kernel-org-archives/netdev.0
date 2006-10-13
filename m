From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7362] New: tun/tap device needs root
 permission for TUNSETIFF ioctl
Date: Fri, 13 Oct 2006 14:43:16 -0700
Message-ID: <20061013144316.a8dcbc95.akpm@osdl.org>
References: <200610132122.k9DLMmiD025915@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8155 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030185AbWJMVnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 17:43:33 -0400
To: murguia@acm.org
In-Reply-To: <200610132122.k9DLMmiD025915@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Oct 2006 14:22:48 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7362
> 
>            Summary: tun/tap device needs root permission for TUNSETIFF ioctl
>     Kernel Version: 2.6.18
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: murguia@acm.org
> 
> 
> Most recent kernel where this bug did not occur: 2.6.17.13
> 
> Distribution: Slackware 10.2
> 
> Problem Description:
> Applying TUNSETIFF ioctl needs root permissions that wasn't needed in previous
> versions. I was using qemu 0.8.2 (a virtual machine emulator) which uses a tap
> device to emulate a network between the guest and host operating system. 
> 
> The relevant part of the patch-2.6.18 file says:
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a1ed2d9..329d9fe 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -39,7 +39,6 @@ #define DRV_VERSION   "1.6"
>  #define DRV_DESCRIPTION        "Universal TUN/TAP device driver"
>  #define DRV_COPYRIGHT  "(C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>"
> 
> -#include <linux/config.h>
>  #include <linux/module.h>
>  #include <linux/errno.h>
>  #include <linux/kernel.h>
> @@ -490,6 +489,9 @@ static int tun_set_iff(struct file *file
> 
>                 err = -EINVAL;
> 
> +               if (!capable(CAP_NET_ADMIN))
> +                       return -EPERM;
> +
>                 /* Set dev type */
>                 if (ifr->ifr_flags & IFF_TUN) {
>                         /* TUN device */ 
> ...
> 
> I was handling security by limiting access to /dev/net/tun from a privileged
> unix group, but now even if I can open the /dev/net/tun device, I need
> CAP_NET_ADMIN to use the TUNSETIFF ioctl.
> 

Changelog for ca6bb5d7ab22ac79f608fe6cbc6b12de6a5a19f0 says

    The tuntap driver allows an admin to create persistent devices and
    assign ownership of them to individual users. Unfortunately, relaxing
    the permissions on the /dev/net/tun device node so that they can
    actually use those devices will _also_ allow those users to create
    arbitrary new devices of their own. This patch corrects that, and
    adjusts the recommended permissions for the device node accordingly.

So I suspect you're out of luck.
