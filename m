From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 05:19:12 -0800
Message-ID: <1425388752.5130.164.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1425354527.git.joe@perches.com>
	 <cccde434d9a32d1b9fb3d7604083c05a2ef1fe0e.1425354528.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cccde434d9a32d1b9fb3d7604083c05a2ef1fe0e.1425354528.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-02 at 19:54 -0800, Joe Perches wrote:
> Make the memset possibly more efficient with the appropriate
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS #ifdef
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/linux/etherdevice.h | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index 606563e..22ad94a 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -192,7 +192,12 @@ static inline void eth_random_addr(u8 *addr)
>   */
>  static inline void eth_broadcast_addr(u8 *addr)
>  {
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> +	*(u32 *)addr = 0xffffffff;
> +	*(u16 *)(addr + 4) = 0xffff;
> +#else
>  	memset(addr, 0xff, ETH_ALEN);
> +#endif
>  }
>  

I am pretty sure compiler already does an inline, and might chose to 
emit equivalent instructions for :
 *(u16 *) addr = 0xffff;
 *(u32 *)(addr + 2) = 0xffffffff;

if (addr % 4) is known to be 2
