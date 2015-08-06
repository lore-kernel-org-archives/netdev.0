From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [RFC PATCH v5 net-next 4/4] tcp: add NV congestion control
Date: Thu, 6 Aug 2015 02:51:39 +0200
Message-ID: <CA++eYdvYopM+TSiWa+gt4Z0RkjAM2Kyxvga8XodSm4w=kSmxVw@mail.gmail.com>
References: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
	<1438738748-1756255-5-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33646 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbHFAvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 20:51:40 -0400
Received: by wijp15 with SMTP id p15so3128947wij.0
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 17:51:39 -0700 (PDT)
In-Reply-To: <1438738748-1756255-5-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 5, 2015 at 3:39 AM, Lawrence Brakmo <brakmo@fb.com> wrote:
> This is a request for comments.

Nice to see more development on delay-based congestion control.

It would be good to see how NV stacks up against CDG. Any chance of
adding cdg as a congestion control parameter to your experiments?
Experiments on NV without its temporary cwnd reductions would also be
of interest -- to get a reference of how effective this mechanism is.


> +#define NV_INIT_RTT      0xffffffff

Maybe use U32_MAX?


> +static void tcpnv_init(struct sock *sk)
> +{
> +       struct tcpnv *ca = inet_csk_ca(sk);
> +
> +       tcpnv_reset(ca, sk);
> +
> +       ca->nv_min_rtt_reset_jiffies = jiffies + 2*HZ;
> +       ca->nv_min_rtt = NV_INIT_RTT;
> +       ca->nv_min_rtt_new = NV_INIT_RTT;
> +       ca->nv_enable = nv_enable;

Can this assignment be ca->nv_enable = 1? That would match the
TCP_CA_Open case in tcpnv_state().


> +       if (nv_dec_eval_min_calls > 255)
> +               nv_dec_eval_min_calls = 255;
> +       if (nv_rtt_min_cnt > 63)
> +               nv_rtt_min_cnt = 63;

nv_dec_eval_min_calls can be clamped to 0-255 by changing its type to u8.

nv_rtt_min_cnt can also be u8? In struct tcpnv, perhaps move
nv_rtt_cnt to the available byte.


> +static void tcpnv_cong_avoid(struct sock *sk, u32 ack, u32 acked)
> +{
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       struct tcpnv *ca = inet_csk_ca(sk);
> +
> +       if (!tcp_is_cwnd_limited(sk))
> +               return;
> +
> +       /* Only grow cwnd if NV has not detected congestion */
> +       if (nv_enable && ca->nv_enable && !ca->nv_allow_cwnd_growth)
> +               return;

The check for ca->nv_enable might be overly harsh on some unfortunate
sockets in TCP_CA_Disorder. Is it needed here?


> +static void tcpnv_acked(struct sock *sk, struct ack_sample *sample)

Maybe move some of this function to tcpnv_cong_avoid()?


> +{
> +       const struct inet_connection_sock *icsk = inet_csk(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       struct tcpnv *ca = inet_csk_ca(sk);
> +       unsigned long now = jiffies;
> +       s64 rate64 = 0;
> +       u32 rate, max_win, cwnd_by_slope;
> +       u32 avg_rtt;
> +       u32 bytes_acked = 0;
> +
> +       /* Some calls are for duplicates without timetamps */
> +       if (sample->rtt_us < 0)
> +               return;
> +
> +       /* If not in TCP_CA_Open state, skip. */
> +       if (icsk->icsk_ca_state != TCP_CA_Open)
> +               return;

Consider using samples in other states too, especially
TCP_CA_Disorder. Linux 4.2 enhances RTT sampling from SACKs, so any
non-negative RTT sample should be fully usable.
