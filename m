From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v2 2/2] tcp: allow to turn tcp timestamp
 randomization off
Date: Wed, 30 Nov 2016 23:12:17 -0800
Message-ID: <CAK6E8=cntqXf7r5Vkce3DPYmNmrUZV5m=dC7kztDY0RFDsUtwg@mail.gmail.com>
References: <1480508930-24406-1-git-send-email-fw@strlen.de> <1480508930-24406-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33010 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbcLAHM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 02:12:59 -0500
Received: by mail-io0-f170.google.com with SMTP id j65so404323571iof.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 23:12:59 -0800 (PST)
In-Reply-To: <1480508930-24406-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 4:28 AM, Florian Westphal <fw@strlen.de> wrote:
> Eric says: "By looking at tcpdump, and TS val of xmit packets of multiple
> flows, we can deduct the relative qdisc delays (think of fq pacing).
> This should work even if we have one flow per remote peer."
>
> Having random per flow (or host) offsets doesn't allow that anymore so add
> a way to turn this off.
>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  change since v2: do check in secure_tcpv4/6_sequence_number so outgoing
>  syn packets won't have a random offset either in if randomization is off.
>
>  Tested:
>  sysctl_tcp_timestamps==1, tcpdump on lo, both ends have same values.
>
>  Documentation/networking/ip-sysctl.txt | 9 +++++++--
>  net/core/secure_seq.c                  | 5 +++--
>  net/ipv4/tcp_input.c                   | 3 ++-
>  3 files changed, 12 insertions(+), 5 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 5af48dd7c5fc..de2448313799 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -610,8 +610,13 @@ tcp_syn_retries - INTEGER
>         with the current initial RTO of 1second. With this the final timeout
>         for an active TCP connection attempt will happen after 127seconds.
>
> -tcp_timestamps - BOOLEAN
> -       Enable timestamps as defined in RFC1323.
> +tcp_timestamps - INTEGER
> +Enable timestamps as defined in RFC1323.
> +       0: Disabled.
> +       1: Enable timestamps as defined in RFC1323.
> +       2: Like 1, but also use a random offset for each connection
> +       rather than only using the current time.
> +       Default: 2
Small suggestion: I suspect host/server configs manually set the knob
to 1. Perhaps swap 1 and 2 to maximize the coverage of this new
feature?

>
>  tcp_min_tso_segs - INTEGER
>         Minimal number of segments per TSO frame.
> diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
> index a8d6062cbb4a..36addd3d9633 100644
> --- a/net/core/secure_seq.c
> +++ b/net/core/secure_seq.c
> @@ -12,6 +12,7 @@
>  #include <net/secure_seq.h>
>
>  #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
> +#include <net/tcp.h>
>  #define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
>
>  static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
> @@ -58,7 +59,7 @@ u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
>
>         md5_transform(hash, secret);
>
> -       *tsoff = hash[1];
> +       *tsoff = sysctl_tcp_timestamps == 2 ? hash[1] : 0;
>         return seq_scale(hash[0]);
>  }
>  EXPORT_SYMBOL(secure_tcpv6_sequence_number);
> @@ -100,7 +101,7 @@ u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
>
>         md5_transform(hash, net_secret);
>
> -       *tsoff = hash[1];
> +       *tsoff = sysctl_tcp_timestamps == 2 ? hash[1] : 0;
>         return seq_scale(hash[0]);
>  }
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 1b1921c71f7c..5f6d4efd2551 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -76,7 +76,7 @@
>  #include <asm/unaligned.h>
>  #include <linux/errqueue.h>
>
> -int sysctl_tcp_timestamps __read_mostly = 1;
> +int sysctl_tcp_timestamps __read_mostly = 2;
>  int sysctl_tcp_window_scaling __read_mostly = 1;
>  int sysctl_tcp_sack __read_mostly = 1;
>  int sysctl_tcp_fack __read_mostly = 1;
> @@ -85,6 +85,7 @@ int sysctl_tcp_dsack __read_mostly = 1;
>  int sysctl_tcp_app_win __read_mostly = 31;
>  int sysctl_tcp_adv_win_scale __read_mostly = 1;
>  EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
> +EXPORT_SYMBOL(sysctl_tcp_timestamps);
>
>  /* rfc5961 challenge ack rate limiting */
>  int sysctl_tcp_challenge_ack_limit = 1000;
> --
> 2.7.3
>
