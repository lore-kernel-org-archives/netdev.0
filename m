From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Fri, 15 Sep 2017 07:03:26 +0200
Message-ID: <1760119.uO98D2ft6f@natalenko.name>
References: <10035198.1vE6NFrMDO@natalenko.name> <CADVnQy=dzjROPgrOw3vAZvtb9ETRJgTPVGtau8Q3ChteDKnYow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:58530 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdIOFD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 01:03:29 -0400
In-Reply-To: <CADVnQy=dzjROPgrOw3vAZvtb9ETRJgTPVGtau8Q3ChteDKnYow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I've applied your test patch but it doesn't fix the issue for me since the=
=20
warning is still there.

Were you able to reproduce it?

On pond=C4=9Bl=C3=AD 11. z=C3=A1=C5=99=C3=AD 2017 1:59:02 CEST Neal Cardwel=
l wrote:
> Thanks for the detailed report!
>=20
> I suspect this is due to the following commit, which happened between
> 4.10 and 4.11:
>=20
>   89fe18e44f7e tcp: extend F-RTO to catch more spurious timeouts
> =20
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit=
/?
> id=3D89fe18e44f7e
>=20
> This commit expanded the set of scenarios where we would undo a
> CA_Loss cwnd reduction and return to TCP_CA_Open, but did not include
> a check to see if there were any in-flight retransmissions. I think we
> need a fix like the following:
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 659d1baefb2b..730a2de9d2b0 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2439,7 +2439,7 @@ static bool tcp_try_undo_loss(struct sock *sk,
> bool frto_undo)
>  {
>         struct tcp_sock *tp =3D tcp_sk(sk);
>=20
> -       if (frto_undo || tcp_may_undo(tp)) {
> +       if ((frto_undo || tcp_may_undo(tp)) && !tp->retrans_out) {
>                 tcp_undo_cwnd_reduction(sk, true);
>=20
>                 DBGUNDO(sk, "partial loss");
>=20
> I will try a packetdrill test to see if I can reproduce this issue and
> verify the fix.
>=20
> thanks,
> neal
