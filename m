From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH v5 net-next 4/4] tcp: add NV congestion control
Date: Fri, 21 Aug 2015 21:29:55 +0000
Message-ID: <D1FCE296.6F6A%brakmo@fb.com>
References: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
 <1438738748-1756255-5-git-send-email-brakmo@fb.com>
 <CA++eYdvYopM+TSiWa+gt4Z0RkjAM2Kyxvga8XodSm4w=kSmxVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
	"Neal Cardwell" <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56477 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752261AbbHUVbU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 17:31:20 -0400
In-Reply-To: <CA++eYdvYopM+TSiWa+gt4Z0RkjAM2Kyxvga8XodSm4w=kSmxVw@mail.gmail.com>
Content-Language: en-US
Content-ID: <9B5F60BEDEADAA44AB2DBBF7474EBE2C@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kenneth, thank you for your comments, I=B9ve implemented most of the
improvements you've mentioned.

I=B9m finishing the new patch and the updated results, they should
be done by Monday (including cdg).

On 8/5/15, 5:51 PM, "knneth@gmail.com on behalf of Kenneth Klette
Jonassen" <knneth@gmail.com on behalf of kennetkl@ifi.uio.no> wrote:

>On Wed, Aug 5, 2015 at 3:39 AM, Lawrence Brakmo <brakmo@fb.com> wrote:
>> This is a request for comments.
>
>Nice to see more development on delay-based congestion control.

Thank you.

>
>It would be good to see how NV stacks up against CDG. Any chance of
>adding cdg as a congestion control parameter to your experiments?
>Experiments on NV without its temporary cwnd reductions would also be
>of interest -- to get a reference of how effective this mechanism is.

I=B9m finishing with cdg experiments, they will be up on Monday togethe=
r
with an update to the NV patch.
I will also have some experiments with variations in the temporary cwnd
reduction. This mechanism is meant to reduce min_rtt creep, but it is
now always successful. Its drawback is that it can increase high
percentile latency.

>
>
>> +#define NV_INIT_RTT      0xffffffff
>
>Maybe use U32_MAX?

Done

>
>
>> +static void tcpnv_init(struct sock *sk)
>> +{
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       tcpnv_reset(ca, sk);
>> +
>> +       ca->nv_min_rtt_reset_jiffies =3D jiffies + 2*HZ;
>> +       ca->nv_min_rtt =3D NV_INIT_RTT;
>> +       ca->nv_min_rtt_new =3D NV_INIT_RTT;
>> +       ca->nv_enable =3D nv_enable;
>
>Can this assignment be ca->nv_enable =3D 1? That would match the
>TCP_CA_Open case in tcpnv_state().

Done

>
>
>> +       if (nv_dec_eval_min_calls > 255)
>> +               nv_dec_eval_min_calls =3D 255;
>> +       if (nv_rtt_min_cnt > 63)
>> +               nv_rtt_min_cnt =3D 63;
>
>nv_dec_eval_min_calls can be clamped to 0-255 by changing its type to =
u8.
>
>nv_rtt_min_cnt can also be u8? In struct tcpnv, perhaps move
>nv_rtt_cnt to the available byte.

Done

>
>
>> +static void tcpnv_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>> +{
>> +       struct tcp_sock *tp =3D tcp_sk(sk);
>> +       struct tcpnv *ca =3D inet_csk_ca(sk);
>> +
>> +       if (!tcp_is_cwnd_limited(sk))
>> +               return;
>> +
>> +       /* Only grow cwnd if NV has not detected congestion */
>> +       if (nv_enable && ca->nv_enable && !ca->nv_allow_cwnd_growth)
>> +               return;
>
>The check for ca->nv_enable might be overly harsh on some unfortunate
>sockets in TCP_CA_Disorder. Is it needed here?

TCP_CA_Disorder should not affect ca->nv_enable in the new patch

>
>
>> +static void tcpnv_acked(struct sock *sk, struct ack_sample *sample)
>
>Maybe move some of this function to tcpnv_cong_avoid()?

It needs to be here since We need the information provided in argument
sample

>
>
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
>> +       if (sample->rtt_us < 0)
>> +               return;
>> +
>> +       /* If not in TCP_CA_Open state, skip. */
>> +       if (icsk->icsk_ca_state !=3D TCP_CA_Open)
>> +               return;
>
>Consider using samples in other states too, especially
>TCP_CA_Disorder. Linux 4.2 enhances RTT sampling from SACKs, so any
>non-negative RTT sample should be fully usable.

Done

>
