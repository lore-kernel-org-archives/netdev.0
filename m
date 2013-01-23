From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] tcp: make tcp_timestamp dependent on tcp_sock
Date: Wed, 23 Jan 2013 08:25:17 -0800
Message-ID: <1358958317.12374.814.camel@edumazet-glaptop>
References: <1358953314-12979-1-git-send-email-avagin@openvz.org>
	 <1358953314-12979-2-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358953314-12979-2-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-23 at 19:01 +0400, Andrey Vagin wrote:
> This will be used for setting timestamp offset.
> 
> This patch converts the macros tcp_timestamp to a function with one
> argument "struct tcp_sock *tp" and nothing else.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  include/net/tcp.h       | 15 +++++++++-----
>  net/ipv4/syncookies.c   |  4 ++--
>  net/ipv4/tcp.c          |  2 +-
>  net/ipv4/tcp_bic.c      | 10 +++++-----
>  net/ipv4/tcp_cubic.c    | 14 ++++++-------
>  net/ipv4/tcp_htcp.c     |  2 +-
>  net/ipv4/tcp_input.c    | 53 ++++++++++++++++++++++++++-----------------------
>  net/ipv4/tcp_ipv4.c     | 19 ++++++++++--------
>  net/ipv4/tcp_lp.c       |  8 ++++----
>  net/ipv4/tcp_metrics.c  |  2 +-
>  net/ipv4/tcp_output.c   | 35 +++++++++++++++++---------------
>  net/ipv4/tcp_timer.c    |  9 +++++----
>  net/ipv4/tcp_westwood.c |  8 +++++---
>  net/ipv6/tcp_ipv6.c     | 22 +++++++++++---------
>  14 files changed, 112 insertions(+), 91 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index aed42c7..3e242ba 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -503,7 +503,7 @@ static inline __u32 cookie_v4_init_sequence(struct sock *sk,
>  }
>  #endif
>  
> -extern __u32 cookie_init_timestamp(struct request_sock *req);
> +extern __u32 cookie_init_timestamp(struct tcp_sock *tp, struct request_sock *req);
>  extern bool cookie_check_timestamp(struct tcp_options_received *opt, bool *);
>  
>  /* From net/ipv6/syncookies.c */
> @@ -675,7 +675,10 @@ void tcp_send_window_probe(struct sock *sk);
>   * to use only the low 32-bits of jiffies and hide the ugly
>   * casts with the following macro.
>   */
> -#define tcp_time_stamp		((__u32)(jiffies))
> +static inline u32 tcp_time_stamp(const struct tcp_sock *tp)
> +{
> +	return (__u32)jiffies;
> +}
>  
>  #define tcp_flag_byte(th) (((u_int8_t *)th)[13])
>  
> @@ -1142,9 +1145,11 @@ static inline void tcp_openreq_init(struct request_sock *req,
>  static inline void tcp_synack_rtt_meas(struct sock *sk,
>  				       struct request_sock *req)
>  {
> +	const struct tcp_sock *tp = tcp_sk(sk);
> +
>  	if (tcp_rsk(req)->snt_synack)
>  		tcp_valid_rtt_meas(sk,
> -		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
> +		    tcp_time_stamp(tp) - tcp_rsk(req)->snt_synack);
>  }
>  

This first chunk looks not needed.

Can SYN_RECV sockets be live-migrated ? Probably not.

Quite frankly I am sure there is an issue for timewait (not real
sockets).

Have you really tested this patch, or is it an RFC ?
