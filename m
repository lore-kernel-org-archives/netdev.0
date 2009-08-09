From: Sergei Poselenov <sposelenov@emcraft.com>
Subject: [Fwd: Re: [PATCH] Fix userland build failure in linux/if_tunnel.h]
Date: Sun, 09 Aug 2009 13:41:58 +0400
Message-ID: <4A7E99E6.4080700@emcraft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "wd@denx.de >> Wolfgang Denk" <wd@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ocean.emcraft.com ([213.221.7.182]:41869 "EHLO
	ocean.emcraft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbZHIKVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 06:21:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

As suggested, reposting the message in this list. Could someone please 
comment?
Original message here:
http://lkml.org/lkml/2009/6/18/223

Thanks in advance,
Sergei

-------- Original Message --------
Subject: 	Re: [PATCH] Fix userland build failure in linux/if_tunnel.h
Date: 	Fri, 7 Aug 2009 15:31:06 +0400
From: 	Sergei Poselenov <sposelenov@emcraft.com>
Organisation: 	Emcraft Systems
To: 	linux-kernel@vger.kernel.org
CC: 	wd@denx.de
References: 	<20090618183738.662f7ef1@emcraft.com>



Hello all,

Unfortunately, received no replies, but the problem still persists.

Probably, I was unclear describing the issue. It is not the busybox
build problem - any application including exported linux/if_tunnel.h
could fail the linkage because of unresolved __cpu_to_be16().

Here is a reduced testcase program:

#include <netinet/ip.h>
#include <net/if.h>
#include <net/if_arp.h>
#include <asm/types.h>

#include <linux/if_tunnel.h>

void foo(void);
void foo(void)
{
	int a = GRE_CSUM;
}

How to reproduce:

bash> arm-linux-gcc -c t.c
bash> nm -n t.o
         U __cpu_to_be16
00000000 t $a
00000000 T foo

As you see, __cpu_to_be16 is undefined, so linking will fail.
Adding <asm/byteorder.h> to if_tunnel.h, as I suggested, fixes the
problem.

Thanks for any comments,
Sergei

On Thu, 18 Jun 2009 18:37:38 +0400
Sergei Poselenov <sposelenov@emcraft.com> wrote:

> Hello all,
> 
> The last commit to linux/if_tunnel.h broke the busybox
> application build.
> When linking the final image linker complains:
> networking/libiproute/lib.a(iptunnel.o): In function `parse_args':
> /work/psl/e/arm-aa/target_rpms/busybox/BUILD/busybox-1.7.1/networking/libiproute/iptunnel.c:189:
> undefined reference to
> `__cpu_to_be16' /work/psl/e/arm-aa/target_rpms/busybox/BUILD/busybox-1.7.1/networking/libiproute/iptunnel.c:190:
> undefined reference to
> `__cpu_to_be16' /work/psl/e/arm-aa/target_rpms/busybox/BUILD/busybox-1.7.1/networking/libiproute/iptunnel.c:202:
> undefined reference to `__cpu_to_be16'
> ...
> 
> Please review the following patch, which fixes the build error.
> 
> Subject: [PATCH] The busybox application build failed in linking
> complaining to unresolved __cpu_to_be16 (ARM target). This patch
> fixes this.
> 
> Signed-off-by: Sergei Poselenov <sposelenov@emcraft.com>
> ---
>  include/linux/if_tunnel.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
> index 5a9aae4..137130b 100644
> --- a/include/linux/if_tunnel.h
> +++ b/include/linux/if_tunnel.h
> @@ -2,6 +2,7 @@
>  #define _IF_TUNNEL_H_
>  
>  #include <linux/types.h>
> +#include <asm/byteorder.h>
>  
>  #ifdef __KERNEL__
>  #include <linux/ip.h>

