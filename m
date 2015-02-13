From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv4: Use binary search to choose tcp PMTU probe_size
Date: Fri, 13 Feb 2015 12:52:49 -0500
Message-ID: <CABrhC0mPhY1u5rb=KsaF96fLqw_QYLUGm_D9_Yhn655JxLN1Xw@mail.gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
	<1423815405-32644-3-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:48729 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbbBMRwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 12:52:51 -0500
Received: by mail-lb0-f171.google.com with SMTP id b6so16906684lbj.2
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 09:52:50 -0800 (PST)
In-Reply-To: <1423815405-32644-3-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2015 at 3:16 AM, Fan Du <fan.du@intel.com> wrote:
> Current probe_size is chosen by doubling mss_cache,
> the initial mss base is 512 Bytes, as a result the
> converged probe_size will only be 1024 Bytes, there
> is still big gap between 1024 and common 1500 bytes
> of mtu.
>
> Use binary search to choose probe_size in a fine
> granularity manner, an optimal mss will be found
> to boost performance as its maxmium.
>
> Test env:
> Docker instance with vxlan encapuslation(82599EB)
> iperf -c 10.0.0.24  -t 60
>
> before this patch:
> 1.26 Gbits/sec
>
> After this patch: increase 26%
> 1.59 Gbits/sec
>
> Signed-off-by: Fan Du <fan.du@intel.com>

Thanks for looking into making mtu probing better.  Improving the
search strategy is commendable.  One high level comment though is that
there's some cost associated with probing and diminishing returns the
smaller the interval (search_high - search_low), so there should be
some threshold below which further probing is deemed no longer useful.

Aside from that, some things in this patch don't look right to me.
Comments inline below.


> ---
>  include/net/inet_connection_sock.h |    3 +++
>  net/ipv4/tcp_input.c               |    5 ++++-
>  net/ipv4/tcp_output.c              |   12 +++++++++---
>  net/ipv4/tcp_timer.c               |    2 +-
>  4 files changed, 17 insertions(+), 5 deletions(-)
>
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> index 5976bde..3d0932e 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -124,6 +124,9 @@ struct inet_connection_sock {
>                 int               search_high;
>                 int               search_low;
>
> +               int               search_high_sav;
> +               int               search_low_sav;
> +
>                 /* Information on the current probe. */
>                 int               probe_size;
>         } icsk_mtup;


What are these for?  They're assigned but not used.


> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 8fdd27b..20b28e9 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2613,7 +2613,10 @@ static void tcp_mtup_probe_success(struct sock *sk)
>         tp->snd_cwnd_stamp = tcp_time_stamp;
>         tp->snd_ssthresh = tcp_current_ssthresh(sk);
>
> -       icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
> +       if (icsk->icsk_mtup.search_low == icsk->icsk_mtup.probe_size)
> +               icsk->icsk_mtup.search_low = icsk->icsk_mtup.search_high;
> +       else
> +               icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
>         icsk->icsk_mtup.probe_size = 0;
>         tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
>  }

It would be cleaner to handle this in tcp_mtu_probe, in deciding
whether to issue a probe, than to change the semantics of search_high
and search_low.  Issuing a probe where probe_size == search_low seems
like the wrong thing to do.


> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a2a796c..0a60deb 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1349,10 +1349,13 @@ void tcp_mtup_init(struct sock *sk)
>         struct inet_connection_sock *icsk = inet_csk(sk);
>         struct net *net = sock_net(sk);
>
> -       icsk->icsk_mtup.enabled = net->ipv4.sysctl_tcp_mtu_probing > 1;
> +       icsk->icsk_mtup.enabled = net->ipv4.sysctl_tcp_mtu_probing;
>         icsk->icsk_mtup.search_high = tp->rx_opt.mss_clamp + sizeof(struct tcphdr) +
>                                icsk->icsk_af_ops->net_header_len;
>         icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, net->ipv4.sysctl_tcp_base_mss);
> +
> +       icsk->icsk_mtup.search_high_sav = icsk->icsk_mtup.search_high;
> +       icsk->icsk_mtup.search_low_sav = icsk->icsk_mtup.search_low;
>         icsk->icsk_mtup.probe_size = 0;
>  }
>  EXPORT_SYMBOL(tcp_mtup_init);

You're changing the meaning of sysctl_tcp_mtu_probing.  I don't think
that's what you want.  From Documentation/networking/ip-sysctl.txt:

tcp_mtu_probing - INTEGER
Controls TCP Packetization-Layer Path MTU Discovery.  Takes three
values:
 0 - Disabled
 1 - Disabled by default, enabled when an ICMP black hole detected
 2 - Always enabled, use initial MSS of tcp_base_mss.



> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 0732b78..9d1cfe0 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -113,7 +113,7 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
>                         struct tcp_sock *tp = tcp_sk(sk);
>                         int mss;
>
> -                       mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low) >> 1;
> +                       mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low);
>                         mss = min(net->ipv4.sysctl_tcp_base_mss, mss);
>                         mss = max(mss, 68 - tp->tcp_header_len);
>                         icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);

Why did you change this?  I think this breaks black hole detection.

Thanks,
  -John
