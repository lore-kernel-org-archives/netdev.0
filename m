From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Mon, 18 May 2015 13:24:26 -0700
Message-ID: <CAK6E8=eV=0YDs5VY8EfhnVH1=gEZ+X4OzZJzDZihvSOUq6ErGA@mail.gmail.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:36085 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbbERUZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:25:09 -0400
Received: by obbkp3 with SMTP id kp3so140299386obb.3
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 13:25:07 -0700 (PDT)
In-Reply-To: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 17, 2015 at 1:31 PM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
> This is a request for comments.
>
> CAIA Delay-Gradient (CDG) is a TCP congestion control that modifies
> the TCP sender in order to [1]:
>
>   o Use the delay gradient as a congestion signal.
>   o Back off with an average probability that is independent of the RTT.
>   o Compete with flows that use loss-based congestion control.
>   o Tolerate packet loss unrelated to congestion.
>
> Its FreeBSD implementation was presented for the ICCRG in July 2012;
> slides are available at: http://www.ietf.org/proceedings/84/iccrg.html
>
> Our Linux implementation tries to honor the original design without major
> changes. However, we encourage others to experiment with enhancements, e.g.
> switch to the Hybrid Slow start algorithm. We decided to disable the loss
> tolerance heuristic by default due to concerns about its safety outside
> closed environments.
>
> Running the experiment scenarios in [1] suggests that our implementation
> achieves more goodput compared with FreeBSD 10.0 senders, although it also
> induces more queueing for a given backoff factor. We do not currently
> understand all the variables that make these implementations different.
>
> There is a potential misbehavior during slow start: if we back off due to
> delay gradient indications, we might overshoot more than New Reno would
> have due to PRR. This is because a delay gradient backoff only reduces cwnd
> by a factor of 0.7, and subsequent losses (which would have reduced by
> a factor of 0.5) are ignored until we exit recovery.
>
> [1] D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
>     delay gradients." In Networking 2011, pages 328-341. Springer, 2011.
>
> Cc: David Hayes <davihay@ifi.uio.no>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Andreas Petlund <apetlund@simula.no>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
>
> ---
>
> [1] http://caia.swin.edu.au/cv/dahayes/content/networking2011-cdg-preprint.pdf
> ---
>  net/ipv4/Kconfig   |  20 +++
>  net/ipv4/Makefile  |   1 +
>  net/ipv4/tcp_cdg.c | 378 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 399 insertions(+)
>  create mode 100644 net/ipv4/tcp_cdg.c
>
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index d83071d..d2b966c 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -615,6 +615,22 @@ config TCP_CONG_DCTCP
>         For further details see:
>           http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
>
> +config TCP_CONG_CDG
> +       tristate "CAIA Delay-Gradient (CDG)"
> +       default n
> +       ---help---
> +       CAIA Delay-Gradient (CDG) is a TCP congestion control that modifies
> +       the TCP sender in order to:
> +
> +         o Use the delay gradient as a congestion signal.
> +         o Back off with an average probability that is independent of the RTT.
> +         o Compete with flows that use loss-based congestion control.
> +         o Tolerate packet loss unrelated to congestion.
> +
> +       For further details see:
> +         D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
> +         delay gradients." In Networking 2011. Preprint: http://goo.gl/No3vdg
> +
>  choice
>         prompt "Default TCP congestion control"
>         default DEFAULT_CUBIC
> @@ -646,6 +662,9 @@ choice
>         config DEFAULT_DCTCP
>                 bool "DCTCP" if TCP_CONG_DCTCP=y
>
> +       config DEFAULT_CDG
> +               bool "CDG" if TCP_CONG_CDG=y
> +
>         config DEFAULT_RENO
>                 bool "Reno"
>  endchoice
> @@ -668,6 +687,7 @@ config DEFAULT_TCP_CONG
>         default "veno" if DEFAULT_VENO
>         default "reno" if DEFAULT_RENO
>         default "dctcp" if DEFAULT_DCTCP
> +       default "cdg" if DEFAULT_CDG
>         default "cubic"
>
>  config TCP_MD5SIG
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index b36236d..efc43f3 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -42,6 +42,7 @@ obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
>  obj-$(CONFIG_INET_UDP_DIAG) += udp_diag.o
>  obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
>  obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
> +obj-$(CONFIG_TCP_CONG_CDG) += tcp_cdg.o
>  obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
>  obj-$(CONFIG_TCP_CONG_DCTCP) += tcp_dctcp.o
>  obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
> diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
> new file mode 100644
> index 0000000..28abe1f
> --- /dev/null
> +++ b/net/ipv4/tcp_cdg.c
> @@ -0,0 +1,378 @@
> +/*
> + * CAIA Delay-Gradient (CDG) congestion control
> + *
> + * This implementation is based on the paper:
> + *   D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
> + *   delay gradients." In Networking 2011, pages 328-341. Springer, 2011.
> + *
> + * For background traffic, disable coexistence heuristics using parameters
> + * use_shadow=0 ineffective_thresh=0.
> + *
> + * Notable differences from paper and FreeBSD patch:
> + *   o Add toggle for shadow window mechanism. Suggested by David Hayes.
> + *   o Add toggle for non-congestion loss tolerance.
> + *   o Scaling parameter G is changed to a backoff factor;
> + *     conversion is given by: backoff_factor = 1000/G.
> + *   o Clear shadow window on ambiguity between full and empty queue.
> + *   o Limit shadow window when application limited.
> + *   o Re-initialize shadow window on cwnd restart.
> + *   o Infer full queue on ECN signal.
> + *   o More accurate e^-x.
> + */
> +#include <linux/kernel.h>
> +#include <linux/random.h>
> +#include <linux/module.h>
> +#include <net/tcp.h>
> +
> +static  int window __read_mostly = 8;
> +static bool use_shadow __read_mostly = true;
> +static bool use_tolerance __read_mostly;
> +static uint backoff_beta __read_mostly = 0.70 * 1024;
> +static uint backoff_factor __read_mostly = 333;
> +static uint ineffective_thresh __read_mostly = 5;
> +static uint ineffective_hold __read_mostly = 5;
> +
> +module_param(window, int, 0444);
> +MODULE_PARM_DESC(window, "moving average window width (power of two)");
> +module_param(use_shadow, bool, 0644);
> +MODULE_PARM_DESC(use_shadow, "use shadow window heuristic");
> +module_param(use_tolerance, bool, 0644);
> +MODULE_PARM_DESC(use_tolerance, "use loss tolerance heuristic");
> +module_param(backoff_beta, uint, 0444);
> +MODULE_PARM_DESC(backoff_beta, "backoff beta (1-1024)");
> +module_param(backoff_factor, uint, 0444);
> +MODULE_PARM_DESC(backoff_factor, "backoff probability scale factor (1-65535)");
> +module_param(ineffective_thresh, uint, 0644);
> +MODULE_PARM_DESC(ineffective_thresh, "ineffective backoff threshold");
> +module_param(ineffective_hold, uint, 0644);
> +MODULE_PARM_DESC(ineffective_hold, "ineffective backoff hold time");
> +
> +struct minmax {
> +       union {
> +               struct {
> +                       s32 min;
> +                       s32 max;
> +               };
> +               u64 v64;
> +       };
> +};
> +
> +enum cdg_state {
> +       CDG_UNKNOWN = 0,
> +       CDG_FULL    = 0,
> +       CDG_NONFULL = 1,
> +};
> +
> +struct cdg {
> +       struct minmax rtt;
> +       struct minmax rtt_prev;
> +       struct minmax gsum;
> +       struct minmax *gradients;
> +       enum cdg_state state;
> +       u32 rtt_seq;
> +       u32 shadow_wnd;
> +       u32 loss_cwnd;
> +       uint tail;
> +       uint backoff_cnt;
> +       uint delack;
> +       bool ecn_ce;
> +};
> +
> +/**
> + * nexp_u32 - negative base-e exponential
> + * @ux: x in units of micro
> + *
> + * Returns exp(ux * -1e-6) * U32_MAX.
> + */
> +static u32 __pure nexp_u32(u32 ux)
> +{
> +       static const u16 v[] = {
> +               /* exp(-x)*65536-1 for x = 0, 0.000256, 0.000512, ... */
> +               65535,
> +               65518, 65501, 65468, 65401, 65267, 65001, 64470, 63422,
> +               61378, 57484, 50423, 38795, 22965, 8047,  987,   14,
> +       };
> +       u64 res;
> +       u32 msb = ux >> 8;
> +       int i;
> +
> +       /* Cut off when ux >= 2^24 (actual result is <= 222/U32_MAX). */
> +       if (msb > U16_MAX)
> +               return 0;
> +
> +       /* Scale first eight bits linearly: */
> +       res = U32_MAX - (ux & 0xff) * (U32_MAX / 1000000);
> +
> +       /* Obtain e^(x + y + ...) by computing e^x * e^y * ...: */
> +       for (i = 1; msb; i++, msb >>= 1) {
> +               u64 y = v[i & -(msb & 1)] + 1ULL;
> +
> +               res = (res * y) >> 16;
> +       }
> +
> +       return (u32)res;
> +}
> +
> +static s32 tcp_cdg_grad(struct sock *sk)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       s32 grad = 0;
> +
> +       if (ca->rtt_prev.v64) {
> +               s32 gmin = ca->rtt.min - ca->rtt_prev.min;
> +               s32 gmax = ca->rtt.max - ca->rtt_prev.max;
> +               s32 gmin_s;
> +               s32 gmax_s;
> +
> +               ca->gsum.min += gmin - ca->gradients[ca->tail].min;
> +               ca->gsum.max += gmax - ca->gradients[ca->tail].max;
> +               ca->gradients[ca->tail].min = gmin;
> +               ca->gradients[ca->tail].max = gmax;
> +               ca->tail = (ca->tail + 1) & (window - 1);
> +
> +               /* We keep sums to ignore gradients during CWR;
> +                * smoothed gradients otherwise simplify to:
> +                * (rtt_latest - rtt_oldest) / window.
> +                */
> +               gmin_s = DIV_ROUND_CLOSEST(ca->gsum.min, window);
> +               gmax_s = DIV_ROUND_CLOSEST(ca->gsum.max, window);
> +
> +               /* Only use smoothed gradients in CA: */
> +               if (tp->snd_cwnd > tp->snd_ssthresh) {
> +                       grad = gmin_s > 0 ? gmin_s : gmax_s;
> +               } else {
> +                       /* Prefer unsmoothed gradients in slow start. */
> +                       grad = gmin > 0 ? gmin : gmin_s;
> +                       if (grad < 0)
> +                               grad = gmax > 0 ? gmax : gmax_s;
> +               }
> +
> +               if (gmin_s > 0 && gmax_s <= 0)
> +                       ca->state = CDG_FULL;
> +               else if ((gmin_s > 0 && gmax_s > 0) || gmax_s < 0)
> +                       ca->state = CDG_NONFULL;
> +
> +               /* Empty queue: */
> +               if (gmin_s >= 0 && gmax_s < 0)
> +                       ca->shadow_wnd = 0;
> +               /* Backoff was effectual: */
> +               if (gmin_s < 0 || gmax_s < 0)
> +                       ca->backoff_cnt = 0;
> +       }
> +
> +       ca->rtt_prev = ca->rtt;
> +       ca->rtt.v64 = 0;
> +       return grad;
> +}
> +
> +static int tcp_cdg_backoff(struct sock *sk, s32 grad)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       if (grad <= 0 || prandom_u32() <= nexp_u32(grad * backoff_factor))
> +               return 0;
> +
> +       ca->shadow_wnd = max(ca->shadow_wnd, tp->snd_cwnd);
> +       ca->backoff_cnt++;
> +       if (ca->backoff_cnt > ineffective_thresh && ineffective_thresh) {
> +               if (ca->backoff_cnt >= (ineffective_thresh + ineffective_hold))
> +                       ca->backoff_cnt = 0;
> +               return 0;
> +       }
> +
> +       /* reset TLP and prohibit cwnd undo: */
> +       tp->tlp_high_seq = 0;
> +       tp->prior_ssthresh = 0;
> +
> +       /* set PRR target and enter CWR: */
> +       tp->snd_ssthresh = max(2U, (tp->snd_cwnd * backoff_beta) >> 10U);
> +       tp->prr_delivered = 0;
> +       tp->prr_out = 0;
> +       tp->prior_cwnd = tp->snd_cwnd;
> +       tp->high_seq = tp->snd_nxt;
why not just call tcp_init_cwnd_reduction()?

> +
> +       tcp_set_ca_state(sk, TCP_CA_CWR);
> +       return 1;
> +}
> +
> +/* Not called in CWR or Recovery state. */
> +static void tcp_cdg_cong_avoid(struct sock *sk, u32 ack, u32 acked)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       if (unlikely(!ca->gradients))
> +               return tcp_reno_cong_avoid(sk, ack, acked);
> +
> +       /* Measure filtered gradients once per RTT: */
> +       if (after(ack, ca->rtt_seq) && ca->rtt.v64) {
> +               s32 grad = tcp_cdg_grad(sk);
> +
> +               ca->rtt_seq = tp->snd_nxt;
> +
> +               if (tcp_cdg_backoff(sk, grad))
> +                       return;
> +       } else if (tp->snd_cwnd > tp->snd_ssthresh) {
> +               /* In CA, synchronize cwnd growth with delay gradients. */
> +               return;
> +       }
> +
> +       if (!tcp_is_cwnd_limited(sk)) {
> +               ca->shadow_wnd = min(ca->shadow_wnd, tp->snd_cwnd);
> +               return;
> +       }
> +
> +       if (tp->snd_cwnd <= tp->snd_ssthresh)
> +               tcp_slow_start(tp, acked);
> +       else if (tp->snd_cwnd < tp->snd_cwnd_clamp)
> +               tp->snd_cwnd++;
Not sure why having two similar but different cwnd increment functions here...



> +
> +       if (ca->shadow_wnd && ca->shadow_wnd < tp->snd_cwnd_clamp)
> +               ca->shadow_wnd = max(tp->snd_cwnd, ca->shadow_wnd + 1);
> +}
> +
> +static void tcp_cdg_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +
> +       if (rtt_us <= 0)
> +               return;
> +
> +       /* A heuristic for filtering delayed ACKs, adapted from:
> +        * D.A. Hayes. "Timing enhancements to the FreeBSD kernel to support
> +        * delay and rate based TCP mechanisms." TR 100219A. CAIA, 2010.
> +        *
> +        * Assume num_acked == 0 indicates RTT measurement from SACK.
> +        */
> +       if (num_acked == 1 && ca->delack) {
> +               /* A delayed ACK is only used for the minimum if it is
> +                * provenly lower than an existing non-zero minimum.
> +                */
> +               ca->rtt.min = min(ca->rtt.min, rtt_us);
> +               ca->delack--;
> +               return;
> +       } else if (num_acked > 1 && ca->delack < 5) {
> +               ca->delack++;
> +       }
> +
> +       ca->rtt.min = min_not_zero(ca->rtt.min, rtt_us);
> +       ca->rtt.max = max(ca->rtt.max, rtt_us);
> +}
> +
> +static u32 tcp_cdg_ssthresh(struct sock *sk)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       if (unlikely(!ca->gradients))
> +               return tcp_reno_ssthresh(sk);
> +
> +       ca->loss_cwnd = tp->snd_cwnd;
> +
> +       if (use_tolerance && ca->state == CDG_NONFULL && !ca->ecn_ce)
> +               return tp->snd_cwnd;
> +
> +       ca->shadow_wnd >>= 1;
> +       if (!use_shadow)
> +               return max(2U, tp->snd_cwnd >> 1);
> +       return max3(2U, ca->shadow_wnd, tp->snd_cwnd >> 1);
> +}
> +
> +static u32 tcp_cdg_undo_cwnd(struct sock *sk)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +
> +       return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
> +}
> +
> +static void tcp_cdg_cwnd_event(struct sock *sk, const enum tcp_ca_event ev)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       struct minmax *gradients;
> +
> +       switch (ev) {
> +       case CA_EVENT_ECN_NO_CE:
> +               ca->ecn_ce = false;
> +               break;
> +       case CA_EVENT_ECN_IS_CE:
> +               ca->ecn_ce = true;
> +               ca->state = CDG_UNKNOWN;
> +               break;
> +       case CA_EVENT_CWND_RESTART:
> +               gradients = ca->gradients;
> +               if (gradients)
> +                       memset(gradients, 0, window * sizeof(gradients[0]));
> +               memset(ca, 0, sizeof(*ca));
> +
> +               ca->gradients = gradients;
> +               ca->rtt_seq = tp->snd_nxt;
> +               ca->shadow_wnd = tp->snd_cwnd;
> +               break;
> +       case CA_EVENT_COMPLETE_CWR:
> +               ca->state = CDG_UNKNOWN;
> +               ca->rtt_seq = tp->snd_nxt;
> +               ca->rtt_prev = ca->rtt;
> +               ca->rtt.v64 = 0;
> +               break;
> +       default:
> +               break;
> +       }
> +}
> +
> +static void tcp_cdg_init(struct sock *sk)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       /* May fail. Not allocating from emergency pools. */
> +       ca->gradients = kcalloc(window, sizeof(ca->gradients[0]), GFP_NOWAIT);
> +       ca->shadow_wnd = tp->snd_cwnd;
> +       ca->rtt_seq = tp->snd_nxt;
> +}
> +
> +static void tcp_cdg_release(struct sock *sk)
> +{
> +       struct cdg *ca = inet_csk_ca(sk);
> +
> +       kfree(ca->gradients);
> +}
> +
> +struct tcp_congestion_ops tcp_cdg __read_mostly = {
> +       .cong_avoid = tcp_cdg_cong_avoid,
> +       .cwnd_event = tcp_cdg_cwnd_event,
> +       .pkts_acked = tcp_cdg_acked,
> +       .undo_cwnd = tcp_cdg_undo_cwnd,
> +       .ssthresh = tcp_cdg_ssthresh,
> +       .release = tcp_cdg_release,
> +       .init = tcp_cdg_init,
> +       .owner = THIS_MODULE,
> +       .name = "cdg",
> +};
> +
> +static int __init tcp_cdg_register(void)
> +{
> +       window = clamp(window, 1, 256);
> +       backoff_beta = clamp(backoff_beta, 1U, 1024U);
> +       backoff_factor = clamp(backoff_factor, 1U, 65535U);
> +
> +       if (!is_power_of_2(window))
> +               return -EINVAL;
> +
> +       BUILD_BUG_ON(sizeof(struct cdg) > ICSK_CA_PRIV_SIZE);
> +       tcp_register_congestion_control(&tcp_cdg);
> +       return 0;
> +}
> +
> +static void __exit tcp_cdg_unregister(void)
> +{
> +       tcp_unregister_congestion_control(&tcp_cdg);
> +}
> +
> +module_init(tcp_cdg_register);
> +module_exit(tcp_cdg_unregister);
> +MODULE_AUTHOR("Kenneth Klette Jonassen");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("TCP CDG");
> --
> 2.1.0
>
