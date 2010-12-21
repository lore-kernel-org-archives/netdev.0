From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Tue, 21 Dec 2010 13:27:00 -0500
Message-ID: <AANLkTikcS-U9yA05dTp_y4EciwtUsjSonjc+bkA=57=4@mail.gmail.com>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:61556 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab0LUS1C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 13:27:02 -0500
Received: by bwz16 with SMTP id 16so4890810bwz.4
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 10:27:00 -0800 (PST)
In-Reply-To: <1292642451-892-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I know this has already been applied, but one thing to think about:
Linux announces a small initial window to prevent overflowing the
receive buffer when receiving segments smaller than the link MTU.
Increasing this even to 10 segments might have some negative
consequences.  I recall, for instance, some drivers when configured
with a 9000 byte MTU, have a single pool of receive buffers all 16k
(the next highest power of 2).  So each received segment will get 16k
of allocated memory accounted to it, even if the incoming segments are
<=3D1460 bytes long.  The default initial rcvbuf of 87380 bytes is less
than the 160k of memory that the initial window might consume, so
we're going to start hitting the very slow path of coalescing segments
to get back under memory bounds.

Some drivers are smarter about having multiple pools of receive
buffers with different sizes, so it might not be so easy to hit this
condition.  I haven't looked at any of them for a while.  Is this
still a real concern?

Thanks,
  -John


On Fri, Dec 17, 2010 at 10:20 PM, Nandita Dukkipati <nanditad@google.co=
m> wrote:
> This patch changes the default initial receive window to 10 mss
> (defined constant). The default window is limited to the maximum
> of 10*1460 and 2*mss (when mss > 1460).
>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
> =A0include/net/tcp.h =A0 =A0 | =A0 =A03 +++
> =A0net/ipv4/tcp_output.c | =A0 11 ++++++++---
> =A02 files changed, 11 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 2ab6c9c..6c25ba8 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -60,6 +60,9 @@ extern void tcp_time_wait(struct sock *sk, int stat=
e, int timeo);
> =A0*/
> =A0#define MAX_TCP_WINDOW =A0 =A0 =A0 =A0 32767U
>
> +/* Offer an initial receive window of 10 mss. */
> +#define TCP_DEFAULT_INIT_RCVWND =A0 =A0 =A0 =A010
> +
> =A0/* Minimal accepted MSS. It is (60+60+8) - (20+20). */
> =A0#define TCP_MIN_MSS =A0 =A0 =A0 =A0 =A0 =A088U
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 2d39066..dc7c096 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -228,10 +228,15 @@ void tcp_select_initial_window(int __space, __u=
32 mss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Set initial window to value enough for senders, foll=
owing RFC5681. */
> + =A0 =A0 =A0 /* Set initial window to a value enough for senders sta=
rting with
> + =A0 =A0 =A0 =A0* initial congestion window of TCP_DEFAULT_INIT_RCVW=
ND. Place
> + =A0 =A0 =A0 =A0* a limit on the initial window when mss is larger t=
han 1460.
> + =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0if (mss > (1 << *rcv_wscale)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int init_cwnd =3D rfc3390_bytes_to_pack=
ets(mss);
> -
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int init_cwnd =3D TCP_DEFAULT_INIT_RCVW=
ND;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mss > 1460)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_cwnd =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_t(u32, (1460 * TCP_=
DEFAULT_INIT_RCVWND) / mss, 2);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* when initializing use the value fro=
m init_rcv_wnd
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * rather than the default from above
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> --
> 1.7.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
