From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: Re: [PATCH 3/3] tcp_cubic: fix low utilization of CUBIC with HyStart
Date: Sun, 13 Mar 2011 19:07:07 -0500
Message-ID: <AANLkTi=bO+7d7W0O-m4=62xcM5P2qao9pzOyPJ1-jtox@mail.gmail.com>
References: <1300061073-24209-1-git-send-email-sangtae.ha@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Injong Rhee <rhee@ncsu.edu>,
	Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40828 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab1CNAHI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 20:07:08 -0400
Received: by fxm17 with SMTP id 17so2438645fxm.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 17:07:07 -0700 (PDT)
In-Reply-To: <1300061073-24209-1-git-send-email-sangtae.ha@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lucas,

Thank you for reporting this problem and the results below show what
happened with low resolution clocks.
The detailed testing setup and results at
http://netsrv.csc.ncsu.edu/wiki/index.php/HyStart_testing_between_Princ=
eton_and_NCSU
I will add the results in long rtt paths soon.

Sangtae

On Sun, Mar 13, 2011 at 7:04 PM, Sangtae Ha <sangtae.ha@gmail.com> wrot=
e:
> HyStart sets the initial exit point of slow start.
> Suppose that HyStart exits at 0.5BDP in a BDP network and no history =
exists.
> If the BDP of a network is large, CUBIC's initial cwnd growth may be
> too conservative to utilize the link.
> CUBIC increases the cwnd 20% per RTT in this case.
>
> Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
> ---
> =A0net/ipv4/tcp_cubic.c | =A0 =A09 +++++++++
> =A01 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
> index b758db1..a170778 100644
> --- a/net/ipv4/tcp_cubic.c
> +++ b/net/ipv4/tcp_cubic.c
> @@ -270,6 +270,15 @@ static inline void bictcp_update(struct bictcp *=
ca, u32 cwnd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ca->cnt =3D 100 * cwnd; =A0 =A0 =A0 =A0=
 =A0 =A0 =A0/* very small increment*/
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The initial growth of cubic function may be too co=
nservative
> + =A0 =A0 =A0 =A0* when the available bandwidth is still unknown.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (ca->loss_cwnd =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ca->cnt > 20) =A0 =A0 =A0 /* increa=
se cwnd 5% per RTT */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca->cnt =3D 20;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* TCP Friendly */
> =A0 =A0 =A0 =A0if (tcp_friendliness) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 scale =3D beta_scale;
> --
> 1.7.0.4
>
>
