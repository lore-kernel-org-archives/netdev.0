From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Kernel Panic with vti Interfaces
Date: Thu, 26 Feb 2015 12:40:53 +0100
Message-ID: <20150226114052.GB20631@secunet.com>
References: <54EC4C63.3050006@marcant.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Andre Valentin <avalentin@marcant.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57261 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597AbbBZLk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 06:40:56 -0500
Content-Disposition: inline
In-Reply-To: <54EC4C63.3050006@marcant.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ccing netdev.

On Tue, Feb 24, 2015 at 11:03:15AM +0100, Andre Valentin wrote:
> Hi!
> 
> I noticed kernel panics on my mips platform while using vti interfaces. After taking a deeper look,
> it seems that if the SA changes or the WAN interface changes I get this error. I could find the
> code where it crashes. But I'm not sure if my solution is right. Perhaps you could take a look.
> 


> From: =?utf8?q?Andr=C3=A9=20Valentin?= <avalentin@marcant.net>
> Date: Tue, 24 Feb 2015 00:24:08 +0100
> Subject: [PATCH] kernel: fix xfrm tunnel checks if vti parent SA/device is in transition
> 
> The outer_mode check results in the error if it is not checked for validity.
> Because I do not know how to handle this situation, I decided to return
> -EINVAL if outer_mode is null.
> 
> ---
>  .../618-net_fixup_xfrm_tunnel_check.patch          |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
>  create mode 100644 target/linux/generic/patches-3.18/618-net_fixup_xfrm_tunnel_check.patch
> 
> diff --git a/target/linux/generic/patches-3.18/618-net_fixup_xfrm_tunnel_check.patch b/target/linux/generic/patches-3.18/618-net_fixup_xfrm_tunnel_check.patch
> new file mode 100644
> index 0000000..f79b1f7
> --- /dev/null
> +++ b/target/linux/generic/patches-3.18/618-net_fixup_xfrm_tunnel_check.patch
> @@ -0,0 +1,16 @@
> +--- a/include/net/xfrm.h	2015-02-11 08:01:12.000000000 +0100
> ++++ b/include/net/xfrm.h	2015-02-24 00:04:03.102709830 +0100
> +@@ -1805,8 +1805,12 @@ static inline int xfrm_tunnel_check(stru
> + 			tunnel = true;
> + 		break;
> + 	}
> +-	if (tunnel && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL))
> ++	if (tunnel && !x->outer_mode) {
> ++                printk(KERN_NOTICE "xfrm_tunnel_check: outer_mode is 0, returning -EINVAL\n");
> + 		return -EINVAL;

Returning -EINVAL here would just paper over the real bug.

We should never get a state without outer_mode from a lookup.
Using such a state will lead to a crash anyway, even without
using vti devices. Looks like you get an uninitialized state
with the lookup. When a xfrm_state is initialized, the outer
mode is added and after that inserted to the lookup tables.
It should never loose the outer_mode pointer.

I have never seen this, is the patch above the only locally
applied patch?

Is this reproducible?
