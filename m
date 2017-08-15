From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
Date: Tue, 15 Aug 2017 09:51:36 -0400
Message-ID: <CADVnQymS_n=ihTaBCx-A6rw2Xxj264ua5xK7mKCppe5r_aR+ig@mail.gmail.com>
References: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Mohamed Othman <mothman@upm.edu.my>,
        Borhanuddin Ali <borhan@upm.edu.my>,
        Zurina Hanapi <zurinamh@upm.edu.my>
To: mohamedalrshah <mohamed.a.alrshah@ieee.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2017 at 9:08 AM, mohamedalrshah
<mohamed.a.alrshah@ieee.org> wrote:
> +
> +/* Agile-SD Parameters */
> +struct agilesdtcp {
> +       u32     loss_cwnd;             /* congestion window at last loss.*/

Please rebase your change on top of the latest net-next changes and
update this module to use the latest approach from the recent commit:

  https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=f1722a1be19dc38e0a4b282d4e6e6ec5e1b11a67
  tcp: consolidate congestion control undo functions

Specifically:

- reference tp->prior_cwnd instead of ca->loss_cwnd
- remove the  ca->loss_cwnd field
- have the .undo_cwnd field reference tcp_reno_undo_cwnd

> +       u32     frac_tracer;           /* This is to trace the fractions of the increment.*/
> +       u32     degraded_loss_cwnd;    /* loss_cwnd after degradation.*/
> +       enum    dystate{SS=0, CA=1} agilesd_tcp_status;

Per Linux style, please define the enum separately before declaring
the variable of that type, and format the enum using Linux style. Also
please use a longer, more specific name, to avoid name collisions. I'd
suggest:

enum dystate {
        AGILE_SD_SS = 0,  /* comment ... */
        AGILE_SD_CA = 1,  /* comment ... */
};


> +};
> +
> +/* To reset the parameters if needed*/
> +static inline void agilesdtcp_reset(struct sock *sk)
> +{
> +
> +}
> +
> +/* This function is called after the first acknowledgment is received and before the congestion
> + * control algorithm will be called for the first time. If the congestion control algorithm has
> + * private data, it should initialize its private date here. */

Multi-line comments should end with the trailing */ on a line by
itself. Here and elsewhere.

Please read:
  https://www.kernel.org/doc/html/v4.10/process/coding-style.html

Please check the style of patches before submitting with the following
script in the Linux kernel tree:
  scripts/checkpatch.pl

> +static void agilesdtcp_init(struct sock *sk)
> +{
> +       struct agilesdtcp *ca = inet_csk_ca(sk);
> +
> +       /* The value of initial_ssthresh parameter is not used here, thus, snd_ssthresh is initialized by a large value.*/
> +       tcp_sk(sk)->snd_ssthresh = 0x7fffffff;
> +
> +       ca->loss_cwnd           = 0;
> +       ca->frac_tracer         = 0;
> +       ca->agilesd_tcp_status  = SS;
> +}
> +
> +/* This function is called whenever an ack is received and the congestion window can be increased.
> + * This is equivalent to opencwnd in tcp.cc.
> + * ack is the number of bytes that are acknowledged in the latest acknowledgment;
> + * rtt is the the rtt measured by the latest acknowledgment;
> + * in_flight is the packet in flight before the latest acknowledgment;
> + * good_ack is an indicator whether the current situation is normal (no duplicate ack, no loss and no SACK). */
> +static void agilesdtcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
> +{
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       struct agilesdtcp *ca = inet_csk_ca(sk);
> +       u32 inc_factor;
> +       u32 ca_inc;
> +       u32 current_gap, total_gap;

For coding style, please order local variable declarations from
longest to shortest line, also know as Reverse Christmas Tree Format.

> +       /* The value of inc_factor is limited by lower_fl and upper_fl.
> +        * The lower_fl must be always = 1. The greater the upper_fl the higher the aggressiveness.
> +        * But, if upper_fl set to 1, Agile-SD will work exactly as newreno.
> +        * We have already designed an equation to calculate the optimum upper_fl based on the given beta.
> +        * This equation will be revealed once its article is published*/
> +       u32 lower_fl = 1 * SCALE;
> +       u32 upper_fl = 3 * SCALE;
> +
> +       if (!tcp_is_cwnd_limited(sk)) return;

Please put this return (or any if/else body) on a line by itself.

> +
> +       if (tp->snd_cwnd < tp->snd_ssthresh){

Need a space between ) and {.

> +               ca->agilesd_tcp_status = SS;
> +               tcp_slow_start(tp, in_flight);
> +       }
> +       else {

The else needs to go on the same line as the closing brace.


> +               inc_factor = min(max(((upper_fl * current_gap) / total_gap), lower_fl), upper_fl);

Please use the existing kernel helper macro for this:

#define clamp(val, lo, hi) min((typeof(val))max(val, lo), hi)


> +
> +               ca_inc = ((inc_factor * SCALE) / tp->snd_cwnd);   /* SCALE is used to avoid fractions*/
> +
> +               ca->frac_tracer += ca_inc;                        /* This in order to take the fraction increase into account */
> +               if (ca->frac_tracer >= Double_SCALE)              /* To take factor scale into account */
> +               {

The opening brace goes on the previous line.

> +/* This function is called when the TCP flow detects a loss.
> + * It returns the slow start threshold of a flow, after a packet loss is detected. */

Trailing */ style issue again.

> +static u32 agilesdtcp_recalc_ssthresh(struct sock *sk)
> +{
> +       const struct tcp_sock *tp = tcp_sk(sk);
> +       struct agilesdtcp *ca = inet_csk_ca(sk);
> +
> +       ca->loss_cwnd = tp->snd_cwnd;
> +
> +       if (ca->agilesd_tcp_status == CA)
> +               ca->degraded_loss_cwnd = max((tp->snd_cwnd * beta) / SCALE, 2U);
> +       else
> +               ca->degraded_loss_cwnd = max((tp->snd_cwnd * beta) / SCALE, 2U);

These two branches of the if/else look the same? Can they be condensed
to a single line?

Thanks,
neal
