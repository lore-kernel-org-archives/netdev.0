From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 06:03:41 -0700
Message-ID: <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <a070f6f7-ed85-c909-ce8b-748210402211@stressinduktion.org>
	 <1463572995-17432-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463572995-17432-1-git-send-email-aryabinin@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-18 at 15:03 +0300, Andrey Ryabinin wrote:
> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
> sock_setsockopt() may write to these bits, while holding the socket lock.
> 
> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
> to corrupting these bits.
> 
> Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
> This will not change the 'struct sock' size since ->sk_shutdown moved into
> previously unused 16-bit hole.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/sock.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index c9c8b19..04dc131 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -383,8 +383,7 @@ struct sock {
>  	int			sk_sndbuf;
>  	struct sk_buff_head	sk_write_queue;
>  	kmemcheck_bitfield_begin(flags);
> -	unsigned int		sk_shutdown  : 2,


Please replace by a padding, so that sk_protocol is sill a byte,
not 8 bits spaning 2 bytes in memory.

> -				sk_no_check_tx : 1,
> +	unsigned int		sk_no_check_tx : 1,
>  				sk_no_check_rx : 1,
>  				sk_userlocks : 4,
>  				sk_protocol  : 8,
> @@ -418,6 +417,7 @@ struct sock {
>  	struct timer_list	sk_timer;
>  	ktime_t			sk_stamp;
>  	u16			sk_tsflags;
> +	u8			sk_shutdown;
>  	u32			sk_tskey;
>  	struct socket		*sk_socket;
>  	void			*sk_user_data;

Thanks.
