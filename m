From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] flowcache: make struct
 flow_cache_percpu::hash_rnd_recalc bool
Date: Sun, 19 Mar 2017 16:11:59 -0700
Message-ID: <1489965119.16816.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170319222743.GC17015@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35760 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752459AbdCSXMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 19:12:02 -0400
Received: by mail-pg0-f66.google.com with SMTP id g2so17053769pge.2
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 16:12:01 -0700 (PDT)
In-Reply-To: <20170319222743.GC17015@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-20 at 01:27 +0300, Alexey Dobriyan wrote:
> ->hash_rnd_recalc is only used in boolean context.
> 
> Space savings on x86_64 come from the fact that "MOV rm8, imm8" is
> shorter than "MOV rm32, imm32" by at least 3 bytes.
> 
> 	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-10 (-10)
> 	function                                     old     new   delta
> 	flow_cache_new_hashrnd                       166     163      -3
> 	flow_cache_cpu_up_prep                       171     168      -3
> 	flow_cache_lookup                           1148    1144      -4
> 	Total: Before=170822872, After=170822862, chg -0.00%
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/net/flowcache.h |    2 +-
>  net/core/flow.c         |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> --- a/include/net/flowcache.h
> +++ b/include/net/flowcache.h
> @@ -10,7 +10,7 @@ struct flow_cache_percpu {
>  	struct hlist_head		*hash_table;
>  	int				hash_count;
>  	u32				hash_rnd;
> -	int				hash_rnd_recalc;
> +	bool				hash_rnd_recalc;

hash_rnd_recalc can be written from flow_cache_new_hashrnd() without any
locking.

Some arches do not have the ability to store an u8 atomically.

So your patch adds a possibility that in the future, we might have a
bug, if another field is added there.

Basically the whole integer here should be reserved, or converted to a
real flag (that can be manipulated with clear_bit() and set_bit()),
but this would consume 8 bytes instead of 4 ;)
