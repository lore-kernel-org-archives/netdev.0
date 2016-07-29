From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] tcp: fix functions of tcp_congestion_ops from being
 called before initialization
Date: Fri, 29 Jul 2016 14:09:18 +0200
Message-ID: <20160729120918.GB26237@breakpoint.cc>
References: <63F9B5BB-7E97-4774-AD98-5FA4010B2BE9@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"glenn.judd@morganstanley.com" <glenn.judd@morganstanley.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "Li, Ji" <jli@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39748 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750948AbcG2MJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 08:09:25 -0400
Content-Disposition: inline
In-Reply-To: <63F9B5BB-7E97-4774-AD98-5FA4010B2BE9@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li, Ji <jli@akamai.com> wrote:
> In Linux 3.17 and earlier, tcp_init_congestion_ops (i.e. tcp_reno) is
> used as the ca_ops during 3WHS, and after 3WHS, ca_ops is assigned as 
> the default congestion control set by sysctl and immediately its parameters
> stored in icsk_ca_priv[] are initialized. Commit 55d8694fa82c ("net:
> tcp: assign tcp cong_ops when tcp sk is created") splits assignment and
> initialization into two steps: assignment is done before SYN or SYN-ACK
> is sent out; initialization is done after 3WHS (assume without
> fastopen). But this can cause out-of-order invocation for ca_ops functions
> other than .init() during 3WHS, as they could be called before its
> parameters get initialized. It may cause unexpected behavior for
> congestion controls, and make troubles for those that need dynamic
> object allocation, like tcp_cdg etc.

What exactly is the problem?
Kernel crash?

AFAICS cdg can cope with NULL ca->gradients.

> We used tcp_dctcp as an example to visualize the problem, and set it as
> default congestion control via sysctl. Three parameters
> (ca->prior_snd_una, ca->prior_rcv_nxt, ca->dctcp_alpha) were monitored
> when functions, such as dctcp_update_alpha() and dctcp_ssthresh(), are
> called during 3WHS. All of three are found to be zero, which is likely
> impossible if dctcp_init() was called ahead, where those three
> parameters should be initialized. Some other congestion controls are
> examined too and the same problem was reproduced.

Why is this a problem?

> diff --git a/include/net/tcp.h b/include/net/tcp.h
> +{
> +       if (inet_csk(sk)->icsk_ca_initialized)
> +               return inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
> +       else
> +               return tcp_reno_ssthresh(sk);
> +}
> +
>  /* Enter Loss state. If we detect SACK reneging, forget all SACK information
>   * and reset tags completely, otherwise preserve SACKs. If receiver
>   * dropped its ofo queue, we will know this due to reneging detection.
> @@ -1896,7 +1904,7 @@ void tcp_enter_loss(struct sock *sk)
>             !after(tp->high_seq, tp->snd_una) ||
>             (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
>                 tp->prior_ssthresh = tcp_current_ssthresh(sk);
> -               tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
> +               tp->snd_ssthresh = tcp_ca_ssthresh(sk);
>                 tcp_ca_event(sk, CA_EVENT_LOSS);
>                 tcp_init_undo(tp);
>         }

Can you explain how we can do loss recovery on a non-established
connection ....?

> @@ -3335,7 +3343,8 @@ static void tcp_cong_control(struct sock *sk, u32 ack, u32 acked_sacked,
>         if (tcp_in_cwnd_reduction(sk)) {
>                 /* Reduce cwnd if state mandates */
>                 tcp_cwnd_reduction(sk, acked_sacked, flag);
> -       } else if (tcp_may_raise_cwnd(sk, flag)) {
> +       } else if (tcp_may_raise_cwnd(sk, flag) &&
> +                  inet_csk(sk)->icsk_ca_initialized) {
>                 /* Advance cwnd if state allows */
>                 tcp_cong_avoid(sk, ack, acked_sacked);

Same here.  How is this called for minisock/sk with non-inited cong ops?
Once sk moves to TCP_ESTABLISHED congestion ops are supposed to
be initialized.

If thats not the case then thats a bug and should be fixed rather
than not calling the cc state machinery any more.
