From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] net: core: Quiet W=1 warnings for unused vars
 and static functions
Date: Mon, 6 Oct 2014 15:12:28 -0700
Message-ID: <CAHA+R7NjP42U+oggUMVXLOde22=d46BGA2Hrjms16+288pGbuw@mail.gmail.com>
References: <1412632298.2916.42.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:35216 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaJFWMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:12:30 -0400
Received: by mail-la0-f50.google.com with SMTP id s18so5349026lam.9
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:12:28 -0700 (PDT)
In-Reply-To: <1412632298.2916.42.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 2:51 PM, Joe Perches <joe@perches.com> wrote:
> John, can you please verify that these gen_stats accesses
> are unnecessary?  I believe the compiler can elide them in
> any case, but I'm not sure what you intended here.
>
>  net/core/dev.c       | 4 ++--
>  net/core/gen_stats.c | 4 ----
>  net/core/rtnetlink.c | 3 +--
>  3 files changed, 3 insertions(+), 8 deletions(-)

You need to split this patch.


> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 14681b9..01be9cf 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -106,13 +106,9 @@ __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
>         for_each_possible_cpu(i) {
>                 struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(cpu, i);
>                 unsigned int start;
> -               __u64 bytes;
> -               __u32 packets;
>
>                 do {
>                         start = u64_stats_fetch_begin_irq(&bcpu->syncp);
> -                       bytes = bcpu->bstats.bytes;
> -                       packets = bcpu->bstats.packets;
>                 } while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));


Looks like we really need them:

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 14681b9..7948ecf 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -115,8 +115,8 @@ __gnet_stats_copy_basic_cpu(struct
gnet_stats_basic_packed *bstats,
                        packets = bcpu->bstats.packets;
                } while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));

-               bstats->bytes += bcpu->bstats.bytes;
-               bstats->packets += bcpu->bstats.packets;
+               bstats->bytes += bytes;
+               bstats->packets += packets;
        }
 }
