From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next 3/4] ipv4: Use probe_size to check write queue
 data length
Date: Tue, 10 Mar 2015 08:26:26 -0400
Message-ID: <CABrhC0=+c1XpVZZpRyhrFJmUwdf1mp1RtWUh+jV-Mg3GXDAqwQ@mail.gmail.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
	<1425978986-8512-4-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:32896 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbCJM02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 08:26:28 -0400
Received: by labmn12 with SMTP id mn12so1307490lab.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 05:26:27 -0700 (PDT)
In-Reply-To: <1425978986-8512-4-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NACK.  From RFC4821:

   In addition, the timely loss detection algorithms in most protocols
   have pre-conditions that SHOULD be satisfied before sending a probe.
   For example, TCP Fast Retransmit is not robust unless there are
   sufficient segments following a probe; that is, the sender SHOULD
   have enough data queued and sufficient receiver window to send the
   probe plus at least Tcprexmtthresh [RFC2760] additional segments.
   This restriction may inhibit probing in some protocol states, such as
   too close to the end of a connection, or when the window is too
   small.


On Tue, Mar 10, 2015 at 5:16 AM, Fan Du <fan.du@intel.com> wrote:
> When building a probe segment, only 'probe_size' of bytes
> is needed, so check write queue data length with probe_size
> instead of size_needed.
>
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  net/ipv4/tcp_output.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 79977d1..89d3f84 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1872,7 +1872,6 @@ static int tcp_mtu_probe(struct sock *sk)
>         struct net *net = sock_net(sk);
>         int len;
>         int probe_size;
> -       int size_needed;
>         int copy;
>         int mss_now;
>         int interval;
> @@ -1895,7 +1894,6 @@ static int tcp_mtu_probe(struct sock *sk)
>         mss_now = tcp_current_mss(sk);
>         probe_size = tcp_mtu_to_mss(sk, (icsk->icsk_mtup.search_high +
>                                     icsk->icsk_mtup.search_low) >> 1);
> -       size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
>         interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
>         /* When misfortune happens, we are reprobing actively,
>          * and then reprobe timer has expired. We stick with current
> @@ -1911,12 +1909,12 @@ static int tcp_mtu_probe(struct sock *sk)
>         }
>
>         /* Have enough data in the send queue to probe? */
> -       if (tp->write_seq - tp->snd_nxt < size_needed)
> +       if (tp->write_seq - tp->snd_nxt < probe_size)
>                 return -1;
>
> -       if (tp->snd_wnd < size_needed)
> +       if (tp->snd_wnd < probe_size)
>                 return -1;
> -       if (after(tp->snd_nxt + size_needed, tcp_wnd_end(tp)))
> +       if (after(tp->snd_nxt + probe_size, tcp_wnd_end(tp)))
>                 return 0;
>
>         /* Do we need to wait to drain cwnd? With none in flight, don't stall */
> --
> 1.7.1
>
