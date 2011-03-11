From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: Re: [PATCH 5/6] tcp_cubic: fix clock dependency
Date: Fri, 11 Mar 2011 11:26:42 -0500
Message-ID: <AANLkTinRFfXv_cqE92f7Kz=1V8Hf_byxeUur0Bwp_OL_@mail.gmail.com>
References: <20110310165119.224046957@vyatta.com>
	<20110310165329.187344604@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, rhee@ncsu.edu, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62798 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab1CKQ1C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 11:27:02 -0500
Received: by fxm17 with SMTP id 17so1138740fxm.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 08:27:01 -0800 (PST)
In-Reply-To: <20110310165329.187344604@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Stephen.

The patch is useful since I had to increase CA_PRIV_SIZE to use
ktime_t for the testing.
Indeed, CUBIC already used up the limit CA_PRIV_SIZE for its variables.

I've got compilation errors because of "jiffies_to_ms" and I corrected
it to "jiffies_to_msecs"

-       return jiffies_to_ms(jiffies);
+       return jiffies_to_msecs(jiffies);

Also, >=3D instead of <=3D, which Lucas already found and reported.

-                       if ((s32)(now - ca->round_start) <=3D ca->delay=
_min >> 4)
+                       if ((s32)(now - ca->round_start) >=3D ca->delay=
_min >> 4)


Sangtae

On Thu, Mar 10, 2011 at 11:51 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> The hystart code was written with assumption that HZ=3D1000.
> Replace the use of jiffies with bictcp_clock as a millisecond
> real time clock.
>
> Warning: this is still experimental, there may still be mistakes
> in units (ms vs. jiffies).
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> P.s: tried using ktime_t but 'struct bictcp' is bumping against limit
> of CA_PRIV_SIZE.
>
> --- a/net/ipv4/tcp_cubic.c =A0 =A0 =A02011-03-10 08:35:45.532695373 -=
0800
> +++ b/net/ipv4/tcp_cubic.c =A0 =A0 =A02011-03-10 08:35:59.968882888 -=
0800
> @@ -88,7 +88,7 @@ struct bictcp {
> =A0 =A0 =A0 =A0u32 =A0 =A0 last_time; =A0 =A0 =A0/* time when updated=
 last_cwnd */
> =A0 =A0 =A0 =A0u32 =A0 =A0 bic_origin_point;/* origin point of bic fu=
nction */
> =A0 =A0 =A0 =A0u32 =A0 =A0 bic_K; =A0 =A0 =A0 =A0 =A0/* time to origi=
n point from the beginning of the current epoch */
> - =A0 =A0 =A0 u32 =A0 =A0 delay_min; =A0 =A0 =A0/* min delay */
> + =A0 =A0 =A0 u32 =A0 =A0 delay_min; =A0 =A0 =A0/* min delay (msec <<=
 3) */
> =A0 =A0 =A0 =A0u32 =A0 =A0 epoch_start; =A0 =A0/* beginning of an epo=
ch */
> =A0 =A0 =A0 =A0u32 =A0 =A0 ack_cnt; =A0 =A0 =A0 =A0/* number of acks =
*/
> =A0 =A0 =A0 =A0u32 =A0 =A0 tcp_cwnd; =A0 =A0 =A0 /* estimated tcp cwn=
d */
> @@ -98,7 +98,7 @@ struct bictcp {
> =A0 =A0 =A0 =A0u8 =A0 =A0 =A0found; =A0 =A0 =A0 =A0 =A0/* the exit po=
int is found? */
> =A0 =A0 =A0 =A0u32 =A0 =A0 round_start; =A0 =A0/* beginning of each r=
ound */
> =A0 =A0 =A0 =A0u32 =A0 =A0 end_seq; =A0 =A0 =A0 =A0/* end_seq of the =
round */
> - =A0 =A0 =A0 u32 =A0 =A0 last_jiffies; =A0 /* last time when the ACK=
 spacing is close */
> + =A0 =A0 =A0 u32 =A0 =A0 last_ack; =A0 =A0 =A0 /* last time when the=
 ACK spacing is close */
> =A0 =A0 =A0 =A0u32 =A0 =A0 curr_rtt; =A0 =A0 =A0 /* the minimum rtt o=
f current round */
> =A0};
>
> @@ -119,12 +119,21 @@ static inline void bictcp_reset(struct b
> =A0 =A0 =A0 =A0ca->found =3D 0;
> =A0}
>
> +static inline u32 bictcp_clock(void)
> +{
> +#if HZ < 1000
> + =A0 =A0 =A0 return ktime_to_ms(ktime_get_real());
> +#else
> + =A0 =A0 =A0 return jiffies_to_ms(jiffies);
> +#endif
> +}
> +
> =A0static inline void bictcp_hystart_reset(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> =A0 =A0 =A0 =A0struct bictcp *ca =3D inet_csk_ca(sk);
>
> - =A0 =A0 =A0 ca->round_start =3D ca->last_jiffies =3D jiffies;
> + =A0 =A0 =A0 ca->round_start =3D ca->last_ack =3D bictcp_clock();
> =A0 =A0 =A0 =A0ca->end_seq =3D tp->snd_nxt;
> =A0 =A0 =A0 =A0ca->curr_rtt =3D 0;
> =A0 =A0 =A0 =A0ca->sample_cnt =3D 0;
> @@ -239,7 +248,7 @@ static inline void bictcp_update(struct
> =A0 =A0 =A0 =A0 */
>
> =A0 =A0 =A0 =A0/* change the unit from HZ to bictcp_HZ */
> - =A0 =A0 =A0 t =3D ((tcp_time_stamp + (ca->delay_min>>3) - ca->epoch=
_start)
> + =A0 =A0 =A0 t =3D ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min=
>>3) - ca->epoch_start)
> =A0 =A0 =A0 =A0 =A0 =A0 << BICTCP_HZ) / HZ;
>
> =A0 =A0 =A0 =A0if (t < ca->bic_K) =A0 =A0 =A0 =A0 =A0 =A0 =A0/* t - K=
 */
> @@ -342,14 +351,12 @@ static void hystart_update(struct sock *
> =A0 =A0 =A0 =A0struct bictcp *ca =3D inet_csk_ca(sk);
>
> =A0 =A0 =A0 =A0if (!(ca->found & hystart_detect)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 curr_jiffies =3D jiffies;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 now =3D bictcp_clock();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* first detection parameter - ack-tra=
in detection */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((s32)(curr_jiffies - ca->last_jiffi=
es) <=3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs_to_jiffies(hystart_ack_de=
lta)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca->last_jiffies =3D cu=
rr_jiffies;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((s32) (curr_jiffies=
 - ca->round_start) <=3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca->delay_min >=
> 4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((s32)(now - ca->last_ack) <=3D hyst=
art_ack_delta) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca->last_ack =3D now;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((s32)(now - ca->rou=
nd_start) <=3D ca->delay_min >> 4)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ca->fo=
und |=3D HYSTART_ACK_TRAIN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> @@ -396,7 +403,7 @@ static void bictcp_acked(struct sock *sk
> =A0 =A0 =A0 =A0if ((s32)(tcp_time_stamp - ca->epoch_start) < HZ)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 delay =3D usecs_to_jiffies(rtt_us) << 3;
> + =A0 =A0 =A0 delay =3D (rtt_us << 3) / USEC_PER_MSEC;
> =A0 =A0 =A0 =A0if (delay =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delay =3D 1;
>
>
>
>
