From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv4 net-next 3/3] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Tue, 3 Mar 2015 11:39:53 -0500
Message-ID: <CABrhC0nQcFSkAcMmnJ+fw0nhOGKiebEDnU4P9=nRsn=u16Lotw@mail.gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com>
	<1425374361-21047-4-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:40294 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757061AbbCCQjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 11:39:55 -0500
Received: by labgd6 with SMTP id gd6so38690823lab.7
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 08:39:53 -0800 (PST)
In-Reply-To: <1425374361-21047-4-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 4:19 AM, Fan Du <fan.du@intel.com> wrote:
> As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
> be armed once probing has converged. Once this timer expired,
> probing again to take advantage of any path PMTU change. The
> recommended probing interval is 10 minutes per RFC1981. Probing
> interval could be sysctled by sysctl_tcp_probe_interval.
>
> Eric Dumazet suggested to implement pseudo timer based on 32bits
> jiffies tcp_time_stamp instead of using classic timer for such
> rare event.
>
> Signed-off-by: Fan Du <fan.du@intel.com>

> @@ -1823,6 +1825,31 @@ send_now:
>         return false;
>  }
>
> +static inline void tcp_mtu_check_reprobe(struct sock *sk)
> +{
> +       struct inet_connection_sock *icsk = inet_csk(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       struct net *net = sock_net(sk);
> +       u32 interval;
> +       s32 delta;
> +
> +       interval = net->ipv4.sysctl_tcp_probe_interval;
> +       delta = tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;
> +       if (unlikely(delta >= interval * HZ)) {
> +               int mss = tcp_current_mss(sk);
> +
> +               /* Update current search range */
> +               icsk->icsk_mtup.search_high = tp->rx_opt.mss_clamp +
> +                       sizeof(struct tcphdr) +
> +                       icsk->icsk_af_ops->net_header_len;
> +               icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
> +               icsk->icsk_mtup.probe_size = 0;
> +
> +               /* Update probe time stamp */
> +               icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
> +       }
> +}
> +
>  /* Create a new MTU probe if we are ready.
>   * MTU probe is regularly attempting to increase the path MTU by
>   * deliberately sending larger packets.  This discovers routing

I think the only update to the search range required here is
potentially moving search_high upward.  Touching search_low seems
unnecessary, and probe_size better be zero when executing this anyway.
(We don't want to be changing the state while a probe is in flight.)



> @@ -1866,8 +1893,11 @@ static int tcp_mtu_probe(struct sock *sk)
>         size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
>         interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
>         if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
> -           interval < max(1, net->ipv4.sysctl_tcp_probe_threshold)) {
> -               /* TODO: set timer for probe_converge_event */
> +               interval < net->ipv4.sysctl_tcp_probe_threshold) {
> +               /* Check whether enough time has elaplased for
> +                * another round of probing.
> +                */
> +               tcp_mtu_check_reprobe(sk);
>                 return -1;
>         }

The way this check works, I think putting it here may not be exactly
what we want.  The comment was to set a timer here, but that's not
exactly what tcp_mtu_check_reprobe does.  Since it may update the
search range, I think it would be better to call prior to comparing
the candidate probe_size to search_high.

Thanks,
  -John
