From: Andrew Vagin <avagin@virtuozzo.com>
Subject: Re: [PATCH] tcp: extend window to fit all restored unacked data in a
 send queue
Date: Wed, 1 Jun 2016 09:26:06 -0700
Message-ID: <20160601162605.GC22074@outlook.office365.com>
References: <1464706956-29291-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<criu@openvz.org>, Pavel Emelyanov <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464706956-29291-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2016 at 08:02:36AM -0700, Andrey Vagin wrote:
> Data from a send queue is sent only if there is enough space in a
> window, so when we restore unacked data, we need to expand a window to
> fit this data.
> 
> Currently we don't do this and tcp_acceptable_seq() returns
> tcp_wnd_end(tp) instead of tp->snd_nxt. The other side drops packets
> with this seq, becuse tcp_sequence() returns false (seq < tp->rcv_nxt).

It's a bad idea to change snd_wnd without changing snd_wl1 and
max_window. Alexey suggests to save and restore these parametrs, because
they were set by a remote side.

So pls drop this patch.

> 
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  net/ipv4/tcp_output.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 79a03b8..b36f968 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -75,6 +75,10 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
>  	tcp_advance_send_head(sk, skb);
>  	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
>  
> +	/* All sent data have to fit into the window */
> +	if (unlikely(tp->repair) && before(tcp_wnd_end(tp), tp->snd_nxt))
> +		tp->snd_wnd = tp->snd_nxt - tp->snd_una;
> +
>  	tp->packets_out += tcp_skb_pcount(skb);
>  	if (!prior_packets || icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
>  	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
> -- 
> 2.5.5
> 
