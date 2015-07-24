From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH v2 net-next 3/3] tcp: add NV congestion control
Date: Fri, 24 Jul 2015 00:47:36 +0000
Message-ID: <D1D6D627.5ED3%brakmo@fb.com>
References: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
 <1437538896-1330704-4-git-send-email-brakmo@fb.com>
 <CAK6E8=cmjY1HNhwx3rnXq3h3Gz2c5Mj7x_7LVg97bLwJ0EqeCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
	"Neal Cardwell" <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39473 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752694AbbGXArn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 20:47:43 -0400
In-Reply-To: <CAK6E8=cmjY1HNhwx3rnXq3h3Gz2c5Mj7x_7LVg97bLwJ0EqeCw@mail.gmail.com>
Content-Language: en-US
Content-ID: <AA4424B768249E4689DF48AA6D3D1897@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you all for your comments, I=B9m currently testing the changes.
Other comments inline.

On 7/21/15, 11:50 PM, "Yuchung Cheng" <ycheng@google.com> wrote:

>On Tue, Jul 21, 2015 at 9:21 PM, Lawrence Brakmo <brakmo@fb.com> wrote=
:
>> This is a request for comments.
>>
>> TCP-NV (New Vegas) is a major update to TCP-Vegas. An earlier versio=
n of
>> NV was presented at 2010's LPC (slides). It is a delayed based
>> congestion avoidance for the data center. This version has been test=
ed
>> within a 10G rack where the HW RTTs are 20-50us.
>>
>> A description of TCP-NV, including implementation and experimental
>> results, can be found at:
>>=20
>>https://urldefense.proofpoint.com/v1/url?u=3Dhttp://www.brakmo.org/ne=
tworki
>>ng/tcp-nv/TCPNV.html&k=3DZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=3Dm30SgjN0=
7T%2FK%2
>>FdV1ZIt1iA%3D%3D%0A&m=3DXeELWxnafKynbNgkHg6RW%2F85hv1bPWlufUn2Dh4cOH4=
%3D%0A
>>&s=3D0029c47e62d84d6ffd22bd33e1895a3f61eaa21d88cbfb553aa1df780bbbdcf9
>>
>> The current version includes many module parameters to support
>> experimentation with the parameters.
>>
>> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
>> ---
>>  include/net/tcp.h          |   1 +
>>  net/ipv4/Kconfig           |  16 ++
>>  net/ipv4/Makefile          |   1 +
>>  net/ipv4/sysctl_net_ipv4.c |   9 +
>>  net/ipv4/tcp_input.c       |   2 +
>>  net/ipv4/tcp_nv.c          | 479
>>+++++++++++++++++++++++++++++++++++++++++++++
>>  6 files changed, 508 insertions(+)
>>  create mode 100644 net/ipv4/tcp_nv.c
>>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 2e62efe..c0690ae 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -281,6 +281,7 @@ extern unsigned int sysctl_tcp_notsent_lowat;
>>  extern int sysctl_tcp_min_tso_segs;
>>  extern int sysctl_tcp_autocorking;
>>  extern int sysctl_tcp_invalid_ratelimit;
>> +extern int sysctl_tcp_nv_enable;
>>
>>  extern atomic_long_t tcp_memory_allocated;
>>  extern struct percpu_counter tcp_sockets_allocated;
>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> index 6fb3c90..c37b374 100644
>> --- a/net/ipv4/Kconfig
>> +++ b/net/ipv4/Kconfig
>> @@ -539,6 +539,22 @@ config TCP_CONG_VEGAS
>>         window. TCP Vegas should provide less packet loss, but it is
>>         not as aggressive as TCP Reno.
>>
>> +config TCP_CONG_NV
>> +       tristate "TCP NV"
>> +       default m
>> +       ---help---
>> +       TCP NV is a follow up to TCP Vegas. It has been modified to
>>deal with
>> +       10G networks, measurement noise introduced by LRO, GRO and
>>interrupt
>> +       coalescence. In addition, it will decrease its cwnd
>>multiplicative
>multiplicatively
>
>> +       instead of linearly.
>> +
>> +       Note that in general congestion avoidance (cwnd decreased wh=
en
>># packets
>> +       queued grows) cannot coexist with congestion control (cwnd
>>decreased only
>> +       when there is packet loss) due to fairness issues. One scena=
rio
>>when the
>s/the/they
>> +       can coexist safely is when the CA flows have RTTs << CC flow=
s
>>RTTs.
>> +
>> +       For further details see
>>https://urldefense.proofpoint.com/v1/url?u=3Dhttp://www.brakmo.org/ne=
tworki
>>ng/tcp-nv/&k=3DZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=3Dm30SgjN07T%2FK%2Fd=
V1ZIt1iA
>>%3D%3D%0A&m=3DXeELWxnafKynbNgkHg6RW%2F85hv1bPWlufUn2Dh4cOH4%3D%0A&s=3D=
3441162
>>a0eefcad01003dbf0ba478e00a2080f76cd460eaf12213eb74f2eedbd
>> +
>>  config TCP_CONG_SCALABLE
>>         tristate "Scalable TCP"
>>         default n
>> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
>> index efc43f3..06f335f 100644
>> --- a/net/ipv4/Makefile
>> +++ b/net/ipv4/Makefile
>> @@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_HSTCP) +=3D tcp_highspeed.o
>>  obj-$(CONFIG_TCP_CONG_HYBLA) +=3D tcp_hybla.o
>>  obj-$(CONFIG_TCP_CONG_HTCP) +=3D tcp_htcp.o
>>  obj-$(CONFIG_TCP_CONG_VEGAS) +=3D tcp_vegas.o
>> +obj-$(CONFIG_TCP_CONG_NV) +=3D tcp_nv.o
>>  obj-$(CONFIG_TCP_CONG_VENO) +=3D tcp_veno.o
>>  obj-$(CONFIG_TCP_CONG_SCALABLE) +=3D tcp_scalable.o
>>  obj-$(CONFIG_TCP_CONG_LP) +=3D tcp_lp.o
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index 433231c..31846d5 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -730,6 +730,15 @@ static struct ctl_table ipv4_table[] =3D {
>>                 .proc_handler   =3D proc_dointvec_ms_jiffies,
>>         },
>>         {
>> +               .procname       =3D "tcp_nv_enable",
>> +               .data           =3D &sysctl_tcp_nv_enable,
>> +               .maxlen         =3D sizeof(int),
>> +               .mode           =3D 0644,
>> +               .proc_handler   =3D proc_dointvec_minmax,
>> +               .extra1         =3D &zero,
>> +               .extra2         =3D &one,
>> +       },
>> +       {
>>                 .procname       =3D "icmp_msgs_per_sec",
>>                 .data           =3D &sysctl_icmp_msgs_per_sec,
>>                 .maxlen         =3D sizeof(int),
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index aca4ae5..87560d9 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -101,6 +101,8 @@ int sysctl_tcp_thin_dupack __read_mostly;
>>  int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
>>  int sysctl_tcp_early_retrans __read_mostly =3D 3;
>>  int sysctl_tcp_invalid_ratelimit __read_mostly =3D HZ/2;
>> +int sysctl_tcp_nv_enable __read_mostly =3D 1;
>> +EXPORT_SYMBOL(sysctl_tcp_nv_enable);
>>
>>  #define FLAG_DATA              0x01 /* Incoming frame contained dat=
a.
>>        */
>>  #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was a
>>window update.       */
>> diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
>> new file mode 100644
>> index 0000000..af451b6
>> --- /dev/null
>> +++ b/net/ipv4/tcp_nv.c
>> @@ -0,0 +1,479 @@
>> +/*
>> + * TCP NV: TCP with Congestion Avoidance
>> + *
>> + * TCP-NV is a successor of TCP-Vegas that has been developed to
>> + * deal with the issues that occur in modern networks.
>> + * Like TCP-Vegas, TCP-NV supports true congestion avoidance,
>> + * the ability to detect congestion before packet losses occur.
>> + * When congestion (queue buildup) starts to occur, TCP-NV
>> + * predicts what the cwnd size should be for the current
>> + * throughput and it reduces the cwnd proportionally to
>> + * the difference between the current cwnd and the predicted cwnd.
>> + * TCP-NV behaves like Reno when no congestion is detected, or when
>> + * recovering from packet losses.
>what happens when loss is not related to congestion?

This version makes no distinction. I will update a patch later (after I=
=B9ve
done enough testing) that adds the option of not decreasing cwnd in som=
e
cases (such as no congestion detected) as long as they are reasonable.

>> + *
>> + * TODO:
>> + * 1) Modify the behavior so cwnd can grow faster under certain
>>conditions
>> + * 2) Add mechanism to deal with reverse congestion.
>> + */
>> +
>> +#include <linux/mm.h>
>> +#include <linux/module.h>
>> +#include <linux/math64.h>
>> +#include <net/tcp.h>
>> +#include <linux/inet_diag.h>
>> +
>> +/* TCP NV parameters */
>> +static int nv_pad __read_mostly =3D 10;
>> +static int nv_pad_buffer __read_mostly =3D 2;
>> +static int nv_reset_period __read_mostly =3D 5;
>> +static int nv_min_cwnd =3D 10;
>> +static int nv_dec_eval_min_calls =3D 100;
>> +static int nv_ssthresh_eval_min_calls =3D 30;
>> +static int nv_rtt_min_cnt =3D 2;
>> +static int nv_cong_decrease_mult =3D 30*128/100;
>> +static int nv_ssthresh_factor =3D 8;
>> +static int nv_rtt_factor =3D 128;
>> +static int nv_rtt_cnt_dec_delta =3D 20; /* dec cwnd by this many RT=
Ts */
>> +static int nv_dec_factor =3D 5;  /* actual value is factor/8 */
>> +static int nv_loss_dec_factor =3D 820; /* on loss reduce cwnd by 20=
% */
>> +static int nv_cwnd_growth_factor =3D 2; /* larger =3D> cwnd grows s=
lower */
>> +
>> +module_param(nv_pad, int, 0644);
>> +MODULE_PARM_DESC(nv_pad, "extra packets above congestion level");
>> +module_param(nv_pad_buffer, int, 0644);
>> +MODULE_PARM_DESC(nv_pad_buffer, "no growth buffer zone");
>> +module_param(nv_reset_period, int, 0644);
>> +MODULE_PARM_DESC(nv_reset_period, "nv_min_rtt reset period (secs)")=
;
>> +module_param(nv_min_cwnd, int, 0644);
>> +MODULE_PARM_DESC(nv_min_cwnd, "NV will not decrease cwnd below this
>>value"
>> +                " without losses");
>> +module_param(nv_dec_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_dec_eval_min_calls, "Wait for this many data
>>points "
>> +                "before declaring congestion (< 256)");
>> +module_param(nv_ssthresh_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_ssthresh_eval_min_calls, "Wait for this many da=
ta
>>points "
>> +                "before declaring congestion during initial
>>slow-start");
>> +module_param(nv_rtt_min_cnt, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_min_cnt, "Wait for this many RTTs before
>>declaring"
>> +                " congestion (<64)");
>> +module_param(nv_cong_decrease_mult, int, 0644);
>> +MODULE_PARM_DESC(nv_cong_decrease_mult, "Congestion decrease factor=
");
>> +module_param(nv_ssthresh_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_ssthresh_factor, "ssthresh factor");
>> +module_param(nv_rtt_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_factor, "rtt averaging factor (0-256)");
>> +module_param(nv_rtt_cnt_dec_delta, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_cnt_dec_delta, "decrease cwnd for this many
>>RTTs "
>> +                "every 100 RTTs");
>> +module_param(nv_dec_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_dec_factor, "decrease cwnd every ~192 RTTS by
>>factor/8");
>> +module_param(nv_loss_dec_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_loss_dec_factor, "on loss new cwnd =3D cwnd * t=
his /
>>1024");
>> +module_param(nv_cwnd_growth_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_cwnd_growth_factor, "larger =3D> cwnd grows slo=
wer");
>> +
>> +/* TCP NV Parameters */
>> +struct tcpnv {
>> +       unsigned long nv_min_rtt_reset_jiffies;  /* when to switch t=
o
>> +                                                 * nv_min_rtt_new *=
/
>> +       u32 cnt;                /* increase cwnd by 1 after ACKs */
>> +       u32 loss_cwnd;  /* cwnd at last loss */
>> +       u8  nv_enable:1,
>> +               nv_allow_cwnd_growth:1,         /* whether cwnd can
>>grow */
>> +               nv_rtt_cnt:6;   /* RTTs without making ca decision *=
/
>> +       u8  nv_eval_call_cnt;/* call count since last eval */
>> +       u8  nv_min_cwnd;        /* nv won't make a ca decision if cw=
nd
>>is
>> +                                * smaller than this. It may grow to
>>handle
>> +                                * TSO, LRO and interrupt coalescenc=
e
>>because
>> +                                * with these a small cwnd cannot
>>saturate
>> +                                * the link. Note that this is
>>different from
>> +                                * sysctl_tcp_nv_min_cwnd */
>> +       u8  available;
>> +       u32 nv_last_rtt;        /* last rtt */
>> +       u32 nv_min_rtt;         /* active min rtt. Used to determine
>>slope */
>> +       u32 nv_min_rtt_new;     /* min rtt for future use */
>> +       u32 nv_rtt_max_rate;    /* max rate seen during current RTT =
*/
>> +       u32 nv_rtt_start_seq;   /* current RTT ends when packet arri=
ves
>> +                                * acking beyond nv_rtt_start_seq */
>> +       u32 nv_last_snd_una;    /* Previous value of tp->snd_una. It=
 is
>> +                                * used to determine bytes acked sin=
ce
>>last
>> +                                * call to bictcp_acked */
>> +       u32 nv_no_cong_cnt;     /* Consecutive no congestion decisio=
ns
>>*/
>> +       u32 nv_rtt_cnt_dec;     /* RTTs since last temporary cwnd
>>decrease */
>> +};
>> +
>> +#define NV_INIT_RTT      0xffffffff
>> +#define NV_MIN_CWND      4
>> +#define NV_MIN_CWND_GROW  2
>> +#define NV_TSO_CWND_BOUND 80
>> +
>> +static inline void tcpnv_reset(struct tcpnv *ca, struct sock *sk)
>> +{
>> +       struct tcp_sock *tp =3D tcp_sk(sk);
>> +
>> +       ca->loss_cwnd =3D 0;
>> +       ca->nv_no_cong_cnt =3D 0;
>> +       ca->cnt =3D 0;
>> +       ca->nv_rtt_cnt =3D 0;
>> +       ca->nv_rtt_cnt_dec =3D 0;
>> +       ca->nv_allow_cwnd_growth =3D 1;
>> +       ca->nv_last_rtt =3D 0;
>> +       ca->nv_rtt_max_rate =3D 0;
>> +       ca->nv_rtt_start_seq =3D tp->snd_una;
>> +       ca->nv_eval_call_cnt =3D 0;
>> +       ca->nv_last_snd_una =3D tp->snd_una;
>> +}
>> +
>> +static void tcpnv_init(struct sock *sk)
>> +{
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       tcpnv_reset(ca, sk);
>> +
>> +       ca->nv_min_rtt_reset_jiffies =3D jiffies + 2*HZ;
>> +       ca->nv_min_rtt =3D NV_INIT_RTT;
>> +       ca->nv_min_rtt_new =3D NV_INIT_RTT;
>> +       ca->nv_enable =3D sysctl_tcp_nv_enable;
>> +       ca->nv_min_cwnd =3D NV_MIN_CWND;
>> +       if (nv_dec_eval_min_calls > 255)
>> +               nv_dec_eval_min_calls =3D 255;
>> +       if (nv_rtt_min_cnt > 63)
>> +               nv_rtt_min_cnt =3D 63;
>> +}
>> +
>> +static void tcpnv_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>> +{
>> +       struct tcp_sock *tp =3D tcp_sk(sk);
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       if (!tcp_is_cwnd_limited(sk))
>> +               return;
>> +
>> +       /* Only grow cwnd if NV has not detected congestion */
>> +       if (sysctl_tcp_nv_enable && ca->nv_enable &&
>> +           !ca->nv_allow_cwnd_growth)
>> +               return;
>> +
>> +       if (tp->snd_cwnd <=3D tp->snd_ssthresh) {
>> +               acked =3D tcp_slow_start(tp, acked);
>> +               if (!acked)
>> +                       return;
>> +       }
>> +       if (ca->cnt =3D=3D 0 || !(sysctl_tcp_nv_enable || ca->nv_ena=
ble))
>> +               ca->cnt =3D tp->snd_cwnd;
>> +
>> +       tcp_cong_avoid_ai(tp, ca->cnt, acked);
>> +}
>> +
>> +static u32 tcpnv_recalc_ssthresh(struct sock *sk)
>> +{
>> +       const struct tcp_sock *tp =3D tcp_sk(sk);
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       ca->loss_cwnd =3D tp->snd_cwnd;
>> +       return max((tp->snd_cwnd * nv_loss_dec_factor) >> 10, 2U);
>> +}
>> +
>> +static u32 tcpnv_undo_cwnd(struct sock *sk)
>> +{
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
>> +}
>> +
>> +static void tcpnv_state(struct sock *sk, u8 new_state)
>> +{
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       if (new_state =3D=3D TCP_CA_Open) {
>> +               ca->nv_enable =3D 1;
>> +               tcpnv_reset(ca, sk);
>> +       } else if (new_state =3D=3D TCP_CA_Loss) {
>> +               ca->nv_enable =3D 0;
>> +       }
>> +}
>> +
>> +/* Do congestion avoidance calculaitons for TCP-NV
>> + */
>> +static void tcpnv_acked(struct sock *sk, struct ack_sample sample)
>> +{
>> +       const struct inet_connection_sock *icsk =3D inet_csk(sk);
>> +       struct tcp_sock *tp =3D tcp_sk(sk);
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +       unsigned long now =3D jiffies;
>> +       s64 rate64 =3D 0;
>> +       u32 rate, max_win, cwnd_by_slope;
>> +       u32 avg_rtt;
>> +       u32 bytes_acked =3D 0;
>> +
>> +       /* Some calls are for duplicates without timetamps */
>> +       if (sample.rtt_us < 0)
>> +               return;
>> +
>> +       /* If not in TCP_CA_Open state, skip. */
>> +       if (icsk->icsk_ca_state !=3D TCP_CA_Open)
>> +               return;
>> +
>> +       /* If NV mode is not enabled, behave like Reno */
>> +       if (!sysctl_tcp_nv_enable  ||  !ca->nv_enable) {
>> +               ca->nv_allow_cwnd_growth =3D 1;
>what's the use case of using NV with sysctl_tcp_nv_enable=3D0?

I=B9m paranoid, this is to turn NV behavior off in case it starts actin=
g
badly.
I=B9ve done some testing within a rack, have plans to do more extensive
testing.

As per Neal=B9s comment, I=B9ve changed it to a module parameter making=
 NV
even less
intrusive.
=20
>
>> +               return;
>> +       }
>> +
>> +       bytes_acked =3D tp->snd_una - ca->nv_last_snd_una;
>> +       ca->nv_last_snd_una =3D tp->snd_una;
>> +
>> +       if (sample.in_flight =3D=3D 0)
>> +               return;
>> +
>> +       /* Calculate moving average of RTT */
>> +       if (nv_rtt_factor > 0) {
>> +               if (ca->nv_last_rtt > 0) {
>> +                       avg_rtt =3D (((u64)sample.rtt_us) * nv_rtt_f=
actor
>>+
>> +                                  ((u64)ca->nv_last_rtt)
>> +                                  * (256 - nv_rtt_factor)) >> 8;
>> +               } else {
>> +                       avg_rtt =3D sample.rtt_us;
>> +                       ca->nv_min_rtt =3D avg_rtt << 1;
>> +               }
>> +               ca->nv_last_rtt =3D avg_rtt;
>> +       } else {
>> +               avg_rtt =3D sample.rtt_us;
>> +       }
>> +
>> +       /* rate in 100's bits per second */
>> +       rate64 =3D ((u64)sample.in_flight) * 8000000;
>> +       rate =3D (u32)div64_u64(rate64, (u64)(avg_rtt*100));
>> +
>> +       /* Remember the maximum rate seen during this RTT
>> +        * Note: It may be more than one RTT. This function should b=
e
>> +        *       called at least nv_dec_eval_min_calls times.
>> +        */
>> +       if (ca->nv_rtt_max_rate < rate)
>> +               ca->nv_rtt_max_rate =3D rate;
>> +
>> +       /* We have valid information, increment counter */
>> +       if (ca->nv_eval_call_cnt < 255)
>> +               ca->nv_eval_call_cnt++;
>> +
>> +       /* update min rtt if necessary */
>> +       if (avg_rtt < ca->nv_min_rtt)
>> +               ca->nv_min_rtt =3D avg_rtt;
>> +
>> +       /* update future min_rtt if necessary */
>> +       if (avg_rtt < ca->nv_min_rtt_new)
>> +               ca->nv_min_rtt_new =3D avg_rtt;
>> +
>> +       /* nv_min_rtt is updated with the minimum (possibley average=
d)
>>rtt
>> +        * seen in the last sysctl_tcp_nv_reset_period seconds (i.e.=
 a
>> +        * warm reset). This new nv_min_rtt will be continued to be
>>updated
>> +        * and be used for another sysctl_tcp_nv_reset_period second=
s,
>> +        * when it will be updated again.
>> +        * In practice we introduce some randomness, so the actual
>>period used
>> +        * is chosen randomly from the range:
>> +        *   [sysctl_tcp_nv_reset_period*3/4,
>>sysctl_tcp_nv_reset_period*5/4)
>> +        */
>> +       if (time_after_eq(now, ca->nv_min_rtt_reset_jiffies)) {
>> +               unsigned char rand;
>> +               ca->nv_min_rtt =3D ca->nv_min_rtt_new;
>> +               ca->nv_min_rtt_new =3D NV_INIT_RTT;
>> +               get_random_bytes(&rand, 1);
>> +               ca->nv_min_rtt_reset_jiffies =3D
>> +                       now + ((nv_reset_period*(384 + rand)*HZ)>>9)=
;
>> +               /* Every so often we decrease nv_min_cwnd in case
>>previous
>> +                *  value is no longer accurate.
>> +                */
>> +               ca->nv_min_cwnd =3D max(ca->nv_min_cwnd/2, NV_MIN_CW=
ND);
>> +       }
>> +
>> +       /* Once per RTT check if we need to do congestion avoidance =
*/
>> +       if (before(ca->nv_rtt_start_seq, tp->snd_una)) {
>> +               ca->nv_rtt_start_seq =3D tp->snd_nxt;
>> +               if (ca->nv_rtt_cnt < 63)
>> +                       /* Increase counter for RTTs without CA
>>decision */
>> +                       ca->nv_rtt_cnt++;
>> +               if (ca->nv_rtt_cnt_dec < 255)
>> +                       /* Increase counter for temporary cwnd decre=
ase
>>*/
>> +                       ca->nv_rtt_cnt_dec++;
>> +
>> +               /* If this function is only called once within an RT=
T
>> +                * the cwnd is probably too small (in some cases due=
 to
>> +                * tso, lro or interrupt coalescence), so we increas=
e
>> +                * nv_min_cwnd.
>> +                */
>> +               if (ca->nv_eval_call_cnt =3D=3D 1
>> +                   && bytes_acked >=3D (ca->nv_min_cwnd - 1) *
>>tp->mss_cache
>> +                   && ca->nv_min_cwnd < (NV_TSO_CWND_BOUND + 1)
>> +                   && ca->nv_rtt_cnt_dec < 192) {
>> +                       ca->nv_min_cwnd =3D min(ca->nv_min_cwnd
>> +                                             + NV_MIN_CWND_GROW,
>> +                                             NV_TSO_CWND_BOUND + 1)=
;
>> +                       ca->nv_rtt_start_seq =3D tp->snd_nxt +
>> +                               ca->nv_min_cwnd*tp->mss_cache;
>> +                       ca->nv_eval_call_cnt =3D 0;
>> +                       ca->nv_allow_cwnd_growth =3D 1;
>> +                       return;
>> +               }
>> +
>> +               /* Every 192 to 320 RTTs decrease cwnd to get better
>>min RTT
>> +                * measurement. In practice we accomplish this by
>>initializing
>> +                * nv_rtt_cnd_dec randomly form the range [0, 128) a=
nd
>> +                * stopping at 320.
>> +                * We keep the value low for nv_rtt_cnt_dec_delta RT=
Ts
>>and then
>> +                * we restore cwnd to its previous value (by setting
>> +                * ssthresh to the previous value).
>> +                */
>> +               if (ca->nv_rtt_cnt_dec =3D=3D 320) {
>> +                       /* decrease cwnd and ssthresh */
>> +                       tp->snd_cwnd =3D
>> +                               max((unsigned int)nv_min_cwnd,
>> +                                   ((tp->snd_cwnd * nv_dec_factor) =
>>
>>3));
>> +                       tp->snd_ssthresh =3D
>> +                               max(tp->snd_cwnd,
>> +                                   ((tp->snd_ssthresh * nv_dec_fact=
or)
>>>> 3));
>> +                       ca->nv_allow_cwnd_growth =3D 0;
>> +                       return;
>> +               } else if (ca->nv_rtt_cnt_dec > 320) {
>> +                       if (ca->nv_rtt_cnt_dec - 320 >=3D
>>nv_rtt_cnt_dec_delta) {
>> +                               /* Restore ssthresh to restore cwnd =
*/
>> +                               unsigned char rand;
>> +                               get_random_bytes(&rand, 1);
>> +                               ca->nv_rtt_cnt_dec =3D rand >> 1;
>> +                               tp->snd_ssthresh =3D (tp->snd_ssthre=
sh <<
>>3)
>> +                                       / nv_dec_factor;
>> +                               ca->nv_allow_cwnd_growth =3D 1;
>> +                               ca->nv_no_cong_cnt =3D 0;
>> +                       }
>> +                       return;
>> +               }
>> +
>> +               /* Find the ideal cwnd for current rate from slope
>> +                * slope =3D 80000.0 * mss / nv_min_rtt
>> +                * cwnd_by_slope =3D nv_rtt_max_rate / slope
>> +                */
>> +               cwnd_by_slope =3D (u32)
>> +                       div64_u64(((u64)ca->nv_rtt_max_rate) *
>>ca->nv_min_rtt,
>> +                                 (u64)(80000 * tp->mss_cache));
>> +               max_win =3D cwnd_by_slope + nv_pad;
>> +
>> +               /* If cwnd > max_win, decrease cwnd
>> +                * if cwnd < max_win, grow cwnd
>> +                * else leave the same
>> +                */
>> +               if (tp->snd_cwnd > max_win) {
>> +                       /* there is congestion, check that it is ok
>> +                        * to make a CA decision
>> +                        * 1. We should have at least
>>nv_dec_eval_min_calls
>> +                        *    data points before making a CA  decisi=
on
>> +                        * 2. We only make a congesion decision afte=
r
>> +                        *    nv_rtt_min_cnt RTTs
>> +                        */
>> +                       if (ca->nv_rtt_cnt < nv_rtt_min_cnt)
>> +                               return;
>> +                       else if (tp->snd_ssthresh =3D=3D
>>TCP_INFINITE_SSTHRESH) {
>> +                               if (ca->nv_eval_call_cnt <
>> +                                   nv_ssthresh_eval_min_calls)
>> +                                       return;
>> +                       } else if (ca->nv_eval_call_cnt <
>> +                                  nv_dec_eval_min_calls) {
>> +                               return;
>> +                       }
>> +
>> +                       /* We have enough data to determine we are
>>congested */
>> +                       ca->nv_allow_cwnd_growth =3D 0;
>> +                       tp->snd_ssthresh =3D
>> +                               (nv_ssthresh_factor * max_win) >> 3;
>> +                       if (tp->snd_cwnd - max_win > 2) {
>> +                               /* gap > 2, we do exponential cwnd
>>decrease */
>> +                               int dec;
>> +                               dec =3D max(2U, ((tp->snd_cwnd - max=
_win)
>>*
>> +                                              nv_cong_decrease_mult=
)
>>>> 7);
>> +                               tp->snd_cwnd -=3D dec;
>> +                       } else if (nv_cong_decrease_mult > 0) {
>> +                               tp->snd_cwnd =3D max_win;
>> +                       }
>> +                       ca->cnt =3D tp->snd_cwnd;
>> +                       ca->nv_no_cong_cnt =3D 0;
>> +               } else if (tp->snd_cwnd <=3D  max_win - nv_pad_buffe=
r) {
>> +                       /* We allow growth of cwnd every RTT since w=
e
>>would
>> +                        * have grown even if we waited (just slower=
)
>> +                        */
>> +                       ca->nv_allow_cwnd_growth =3D 1;
>> +                       ca->nv_no_cong_cnt++;
>> +                       if (nv_cwnd_growth_factor > 0 &&
>> +                           ca->nv_no_cong_cnt > nv_cwnd_growth_fact=
or)
>>{
>> +                               ca->cnt =3D max(ca->cnt >> 1, (u32) =
4);
>> +                               ca->nv_no_cong_cnt =3D 0;
>> +                       }
>> +               } else {
>> +                       ca->nv_allow_cwnd_growth =3D 0;
>> +               }
>> +
>> +               /* update state */
>> +               ca->nv_eval_call_cnt =3D 0;
>> +               ca->nv_rtt_cnt =3D 0;
>> +               ca->nv_rtt_max_rate =3D 0;
>> +
>> +               /* Don't want to make cwnd < nv_min_cwnd
>> +                * (it wasn't before, if it is now is because nv
>> +                *  decreased it).
>> +                */
>> +               if (tp->snd_cwnd < nv_min_cwnd)
>> +                       tp->snd_cwnd =3D nv_min_cwnd;
>> +
>> +  }
>> +}
>> +
>> +/* Extract info for Tcp socket info provided via netlink */
>> +size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
>> +                      union tcp_cc_info *info)
>> +{
>> +       const struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
>> +               info->vegas.tcpv_enabled =3D ca->nv_enable
>> +                       && sysctl_tcp_nv_enable;
>> +               info->vegas.tcpv_rttcnt =3D ca->nv_rtt_cnt;
>> +               info->vegas.tcpv_rtt =3D ca->nv_last_rtt;
>> +               info->vegas.tcpv_minrtt =3D ca->nv_min_rtt;
>> +
>> +               *attr =3D INET_DIAG_VEGASINFO;
>> +               return sizeof(struct tcpvegas_info);
>> +       }
>> +       return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(tcpnv_get_info);
>> +
>> +static struct tcp_congestion_ops tcpnv __read_mostly =3D {
>> +       .init           =3D tcpnv_init,
>> +       .ssthresh       =3D tcpnv_recalc_ssthresh,
>> +       .cong_avoid     =3D tcpnv_cong_avoid,
>> +       .set_state      =3D tcpnv_state,
>> +       .undo_cwnd      =3D tcpnv_undo_cwnd,
>> +       .pkts_acked     =3D tcpnv_acked,
>> +       .get_info       =3D tcpnv_get_info,
>> +
>> +       .owner          =3D THIS_MODULE,
>> +       .name           =3D "nv",
>> +};
>> +
>> +static int __init tcpnv_register(void)
>> +{
>> +       BUILD_BUG_ON(sizeof(struct tcpnv) > ICSK_CA_PRIV_SIZE);
>> +
>> +       return tcp_register_congestion_control(&tcpnv);
>> +}
>> +
>> +static void __exit tcpnv_unregister(void)
>> +{
>> +       tcp_unregister_congestion_control(&tcpnv);
>> +}
>> +
>> +module_init(tcpnv_register);
>> +module_exit(tcpnv_unregister);
>> +
>> +MODULE_AUTHOR("Lawrence Brakmo");
>> +MODULE_LICENSE("GPL");
>> +MODULE_DESCRIPTION("TCP NV");
>> +MODULE_VERSION("1.0");
>> --
>> 1.8.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
