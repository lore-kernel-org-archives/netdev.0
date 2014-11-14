From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 06:50:56 -0800
Message-ID: <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <4086c7bc9f7f9e8e2de9656c9e27ef1e71bb6423.1415973706.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41493 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964875AbaKNOvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 09:51:00 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so1621329igd.2
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 06:50:59 -0800 (PST)
In-Reply-To: <4086c7bc9f7f9e8e2de9656c9e27ef1e71bb6423.1415973706.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-14 at 15:06 +0100, Hannes Frederic Sowa wrote:
> In case the arch_fast_hash call gets inlined we need to tell gcc which
> registers are clobbered with. Most callers where fine, as rhashtable
> used arch_fast_hash via function pointer and thus the compiler took care
> of that. In case of openvswitch the call got inlined and arch_fast_hash
> touched registeres which gcc didn't know about.
> 
> Also don't use conditional compilation inside arguments, as this confuses
> sparse.
> 

Please add a 
Fixes: 12-sha1 ("patch title")

> Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  arch/x86/include/asm/hash.h | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
> index a881d78..771cee0 100644
> --- a/arch/x86/include/asm/hash.h
> +++ b/arch/x86/include/asm/hash.h
> @@ -23,11 +23,14 @@ static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
>  {
>  	u32 hash;
>  
> -	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
>  #ifdef CONFIG_X86_64
> -			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
> +	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
> +			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
> +			 : "rcx", "r8", "r9", "r10", "r11", "cc", "memory");
>  #else




> -			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
> +	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
> +			 "=a" (hash), "a" (data), "d" (len), "c" (seed)
> +			 : "cc", "memory");
>  #endif
>  	return hash;
>  }
> @@ -36,11 +39,14 @@ static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
>  {
>  	u32 hash;
>  
> -	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
>  #ifdef CONFIG_X86_64
> -			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
> +	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
> +			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
> +			 : "rcx", "r8", "r9", "r10", "r11", "cc", "memory");


Thats a lot of clobbers.

Alternative would be to use an assembly trampoline to save/restore them
before calling __jhash2

__intel_crc4_2_hash2 can probably be written in assembly, it is quite
simple.
