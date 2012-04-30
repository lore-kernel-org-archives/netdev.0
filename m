From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix infinite cwnd in tcp_complete_cwr()
Date: Sun, 29 Apr 2012 23:49:01 -0400
Message-ID: <CADVnQymtZq7BwKkidYWbNK-Yq0OgzcAWP0RodYeLup-foOKtdw@mail.gmail.com>
References: <1335639894-18569-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33918 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082Ab2D3DtB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 23:49:01 -0400
Received: by iadi9 with SMTP id i9so3596951iad.19
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2012 20:49:01 -0700 (PDT)
In-Reply-To: <1335639894-18569-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 3:04 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> When the cwnd reduction is done, ssthresh may be infinite
> if TCP enters CWR via ECN or F-RTO. If cwnd is not undone, i.e.,
> undo_marker is set, tcp_complete_cwr() falsely set cwnd to the
> infinite ssthresh value. The correct operation is to keep cwnd
> intact because it has been updated in ECN or F-RTO.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> =A0net/ipv4/tcp_input.c | =A0 =A08 +++++---
> =A01 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index c93b0cb..ac417de 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2868,11 +2868,13 @@ static inline void tcp_complete_cwr(struct so=
ck *sk)
>
> =A0 =A0 =A0 =A0/* Do not moderate cwnd if it's already undone in cwr =
or recovery. */
> =A0 =A0 =A0 =A0if (tp->undo_marker) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_ca_state =3D=3D =
TCP_CA_CWR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_ca_state =3D=3D =
TCP_CA_CWR) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->snd_cwnd =3D min(t=
p->snd_cwnd, tp->snd_ssthresh);

In this TCP_CA_CWR case the patch needs to add the assignment:

     tp->snd_cwnd_stamp =3D tcp_time_stamp;

I know that was in earlier versions of your patch; looks like it just
got accidentally dropped on this latest version.

Otherwise, looks good to me.

neal
