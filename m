From: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Sat, 10 Jan 2015 12:51:49 +0100
Message-ID: <54B11255.7000500@uclouvain.be>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be> <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com> <54AEA498.5030202@uclouvain.be> <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com> <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com> <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:49061 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbAJLwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 06:52:01 -0500
In-Reply-To: <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

Le 09/01/2015 20:43, Yuchung Cheng a =C3=A9crit :
>
> Sebastien: I suggest breaking down by ACK types for readability. e.g.=
,
>
> /* This routine deals with acks during a TLP episode.
>   * We mark the end of a TLP episode on receiving TLP dupack or when
>   * ack is after tlp_high_seq.
>   * Ref: loss detection algorithm in draft-dukkipati-tcpm-tcp-loss-pr=
obe.
>   */
> static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
> {
>          struct tcp_sock *tp =3D tcp_sk(sk);
>
>          if (before(ack, tp->tlp_high_seq))
>                  return;
>
>          if (flag & FLAG_DSACKING_ACK) {
>                  /* This DSACK means original and TLP probe arrived; =
no loss */
>                  tp->tlp_high_seq =3D 0;
>          } else if (after(ack, tp->tlp_high_seq)) {
>                  /* ACK advances: there was a loss, so reduce cwnd. R=
eset
>                   * tlp_high_seq in tcp_init_cwnd_reduction()
Indeed, hadn't seen that.
>                   */
>                  tcp_init_cwnd_reduction(sk);
>                  tcp_set_ca_state(sk, TCP_CA_CWR);
>                  tcp_end_cwnd_reduction(sk);
>                  tcp_try_keep_open(sk);
>                  NET_INC_STATS_BH(sock_net(sk),
>                                   LINUX_MIB_TCPLOSSPROBERECOVERY);
>          } else if (!(flag & (FLAG_SND_UNA_ADVANCED |
>                               FLAG_NOT_DUP | FLAG_DATA_SACKED))) {
>                  /* Pure dupack: original and TLP probe arrived; no l=
oss */
>                  tp->tlp_high_seq =3D 0;
>          }
> }
That looks much more readable compared to my v2.
It is currently passing our tests (These are in fact MPTCP tests appart=
=20
from Neal's packetdrill that I will add, but actually the MPTCP stack=20
happens to reveal this situation quite easily, I think because in MPTCP=
,=20
we store the send queue in the "meta-flow", which currently cannot be=20
used for tail loss probes).

As probably everyone will be happy with this (Eric as well ?), I sugges=
t=20
I prepare a v3 once all our tests are passed as well, with Yuchung's=20
structure and Neal's packetdrill test in the commit text. Will also add=
=20
proper credit as there is now stuff from several people in those few=20
lines now :-).

Looks good ?

Thanks again for your fast and helpful interactions !

S=C3=A9bastien.

>
>>
