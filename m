From: Jerry Chu <hkchu@google.com>
Subject: Re: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 30 Sep 2010 20:27:05 -0700
Message-ID: <AANLkTinsNEeTK=SrGpqEjF8VtZZWpiWydgSc+3M854pD@mail.gmail.com>
References: <20101001124830.9c35d36f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101001124830.9c35d36f.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In tcp_write_timeout():

if (retransmits_timed_out(sk, retry_until,
            (1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV) ? 0 :
            icsk->icsk_user_timeout, syn_set)) {

should be simplified to

if (retransmits_timed_out(sk, retry_until,
    syn_set ? 0 : icsk->icsk_user_timeout, syn_set)) {


Thanks,

Jerry

On Thu, Sep 30, 2010 at 7:48 PM, Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
> Hi all,
>
> Today's linux-next merge of the net tree got a conflict in
> net/ipv4/tcp_timer.c between commit
> 4d22f7d372f5769c6c0149e427ed6353e2dcfe61 ("net-2.6: SYN retransmits: =
Add
> new parameter to retransmits_timed_out()") from the net-current tree =
and
> commit dca43c75e7e545694a9dd6288553f55c53e2a3a3 ("tcp: Add
> TCP_USER_TIMEOUT socket option") from the net tree.
>
> I fixed it up (see below) and can carry the fix as necessary.
> --
> Cheers,
> Stephen Rothwell =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfr@canb.auug=
=2Eorg.au
>
> diff --cc net/ipv4/tcp_timer.c
> index 74c54b3,baea4a1..0000000
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@@ -140,11 -139,9 +140,11 @@@ static void tcp_mtu_probing(struct ine=
t
> =A0 */
> =A0static bool retransmits_timed_out(struct sock *sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0un=
signed int boundary,
> =A0- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u=
nsigned int timeout)
> ++ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uns=
igned int timeout,
> =A0+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0b=
ool syn_set)
> =A0{
> - =A0 =A0 =A0 unsigned int timeout, linear_backoff_thresh;
> - =A0 =A0 =A0 unsigned int start_ts;
> + =A0 =A0 =A0 unsigned int linear_backoff_thresh, start_ts;
> =A0+ =A0 =A0 =A0unsigned int rto_base =3D syn_set ? TCP_TIMEOUT_INIT =
: TCP_RTO_MIN;
>
> =A0 =A0 =A0 =A0if (!inet_csk(sk)->icsk_retransmits)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> @@@ -154,14 -151,15 +154,16 @@@
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0start_ts =3D tcp_sk(sk)->retrans_stamp=
;
>
> - =A0 =A0 =A0 linear_backoff_thresh =3D ilog2(TCP_RTO_MAX/rto_base);
> + =A0 =A0 =A0 if (likely(timeout =3D=3D 0)) {
> =A0- =A0 =A0 =A0 =A0 =A0 =A0 =A0linear_backoff_thresh =3D ilog2(TCP_R=
TO_MAX/TCP_RTO_MIN);
> ++ =A0 =A0 =A0 =A0 =A0 =A0 =A0linear_backoff_thresh =3D ilog2(TCP_RTO=
_MAX/rto_base);
>
> - =A0 =A0 =A0 if (boundary <=3D linear_backoff_thresh)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 timeout =3D ((2 << boundary) - 1) * rto=
_base;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 timeout =3D ((2 << linear_backoff_thres=
h) - 1) * rto_base +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (boundary - linear_=
backoff_thresh) * TCP_RTO_MAX;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (boundary <=3D linear_backoff_thresh=
)
> =A0- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0timeout =3D ((2 << bo=
undary) - 1) * TCP_RTO_MIN;
> ++ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0timeout =3D ((2 << boun=
dary) - 1) * rto_base;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> =A0- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0timeout =3D ((2 << li=
near_backoff_thresh) - 1) * TCP_RTO_MIN +
> ++ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0timeout =3D ((2 << line=
ar_backoff_thresh) - 1) * rto_base +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (bounda=
ry - linear_backoff_thresh) * TCP_RTO_MAX;
> =A0+
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return (tcp_time_stamp - start_ts) >=3D timeout;
> =A0}
>
> @@@ -176,9 -174,8 +178,9 @@@ static int tcp_write_timeout(struct soc
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (icsk->icsk_retransmits)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dst_negative_advice(sk=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retry_until =3D icsk->icsk_syn_retries=
 ? : sysctl_tcp_syn_retries;
> =A0+ =A0 =A0 =A0 =A0 =A0 =A0 =A0syn_set =3D 1;
> =A0 =A0 =A0 =A0} else {
> -- =A0 =A0 =A0 =A0 =A0 =A0 =A0if (retransmits_timed_out(sk, sysctl_tc=
p_retries1, 0)) {
> ++ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (retransmits_timed_out(sk, sysctl_tc=
p_retries1, 0, 0)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Black hole detectio=
n */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_mtu_probing(icsk, =
sk);
>
> @@@ -191,14 -188,16 +193,16 @@@
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retry_until =3D tcp_or=
phan_retries(sk, alive);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_reset =3D alive ||
> -- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !r=
etransmits_timed_out(sk, retry_until, 0);
> ++ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !r=
etransmits_timed_out(sk, retry_until, 0, 0);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tcp_out_of_resourc=
es(sk, do_reset))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (retransmits_timed_out(sk, retry_until, syn_set)) {
> + =A0 =A0 =A0 if (retransmits_timed_out(sk, retry_until,
> + =A0 =A0 =A0 =A0 =A0 (1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN=
_RECV) ? 0 :
> =A0- =A0 =A0 =A0 =A0 =A0icsk->icsk_user_timeout)) {
> ++ =A0 =A0 =A0 =A0 =A0icsk->icsk_user_timeout, syn_set)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Has it gone just too far? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_write_err(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> @@@ -440,7 -439,7 +444,7 @@@ out_reset_timer
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0icsk->icsk_rto =3D min(icsk->icsk_rto =
<< 1, TCP_RTO_MAX);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk-=
>icsk_rto, TCP_RTO_MAX);
> -- =A0 =A0 =A0if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, =
0))
> ++ =A0 =A0 =A0if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, =
0, 0))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__sk_dst_reset(sk);
>
> =A0out:;
>
