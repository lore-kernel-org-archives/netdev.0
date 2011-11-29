From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid frag allocation for small frames
Date: Mon, 28 Nov 2011 17:04:00 -0800
Message-ID: <CAGK4HS_Nryz6jWuqcHPu8AK1Rp6kFRp6M_y-yaGFcnX+pjX47Q@mail.gmail.com>
References: <1319286237.6180.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35604 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab1K2BEB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 20:04:01 -0500
Received: by vbbfc26 with SMTP id fc26so4316260vbb.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 17:04:00 -0800 (PST)
In-Reply-To: <1319286237.6180.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 October 2011 05:23, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> tcp_sendmsg() uses select_size() helper to choose skb head size when =
a
> new skb must be allocated.
>
> If GSO is enabled for the socket, current strategy is to force all
> payload data to be outside of headroom, in PAGE fragments.
>
> This strategy is not welcome for small packets, wasting memory.
>
> Experiments show that best results are obtained when using 2048 bytes
> for skb head (This includes the skb overhead and various headers)
>
> This patch provides better len/truesize ratios for packets sent to
> loopback device, and reduce memory needs for in-flight loopback packe=
ts,
> particularly on arches with big pages.
>
> If a sender sends many 1-byte packets to an unresponsive application,
> receiver rmem_alloc will grow faster and will stop queuing these pack=
ets
> sooner, or will collapse its receive queue to free excess memory.
>
> netperf -t TCP_RR results are improved by ~4 %, and many workloads ar=
e
> improved as well (tbench, mysql...)
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0net/ipv4/tcp.c | =A0 =A09 ++++++---
> =A01 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 704adad..cd45b44 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -897,9 +897,12 @@ static inline int select_size(const struct sock =
*sk, int sg)
> =A0 =A0 =A0 =A0int tmp =3D tp->mss_cache;
>
> =A0 =A0 =A0 =A0if (sg) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk_can_gso(sk))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk_can_gso(sk)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Small frames wont us=
e a full page:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Payload will immed=
iately follow tcp header.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D SKB_WITH_OVERHE=
AD(2048 - MAX_TCP_HEADER);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int pgbreak =3D SKB_MA=
X_HEAD(MAX_TCP_HEADER);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tmp >=3D pgbreak &=
&
>
>



This patch from Eric fixing select_size in tcp.c was queued to be
applied but does not seem to be in net-next tree. Was this somehow
overlooked or have I missed something?

Regards,
Vijay Subramanian
