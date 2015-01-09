From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Fri, 9 Jan 2015 11:43:54 -0800
Message-ID: <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
 <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <54AEA498.5030202@uclouvain.be> <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
 <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33568 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbAITof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:44:35 -0500
Received: by mail-ig0-f176.google.com with SMTP id a13so3308993igq.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:44:35 -0800 (PST)
In-Reply-To: <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 8:25 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
> On Thu, 2015-01-08 at 10:49 -0500, Neal Cardwell wrote:
> > On Thu, Jan 8, 2015 at 10:39 AM, S=C3=A9bastien Barr=C3=A9
> > <sebastien.barre@uclouvain.be> wrote:
> > > What do you and Neal think ?
> >
> > My preference is to have the whole expression detecting the case wh=
ere
> > the receiver got the probe packet encoded in a single expression. I
> > don't have a strong feeling about whether it should be stored in a
> > bool (to reduce the size of the diff) or written directly into the =
if
> > () expression (to reduce the size of the code). I'll defer to Eric =
on
> > which he thinks is better. :-)
>
> There is no shame using helpers with nice names to help understand th=
is
> TCP stack. Even if the helper is used exactly once.
>
> In this case, it seems we test 2 different conditions, so this could =
use
> 2 helpers with self describing names.
>
> When I see :
>
> > +     if (((ack =3D=3D tp->tlp_high_seq) &&
> > +          !(flag & (FLAG_SND_UNA_ADVANCED |
> > +                    FLAG_NOT_DUP | FLAG_DATA_SACKED))) ||
> > +         (!before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_=
ACK))) {
> >               tp->tlp_high_seq =3D 0;
>
> My brain hurts.
Sebastien: I suggest breaking down by ACK types for readability. e.g.,

/* This routine deals with acks during a TLP episode.
 * We mark the end of a TLP episode on receiving TLP dupack or when
 * ack is after tlp_high_seq.
 * Ref: loss detection algorithm in draft-dukkipati-tcpm-tcp-loss-probe=
=2E
 */
static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
{
        struct tcp_sock *tp =3D tcp_sk(sk);

        if (before(ack, tp->tlp_high_seq))
                return;

        if (flag & FLAG_DSACKING_ACK) {
                /* This DSACK means original and TLP probe arrived; no =
loss */
                tp->tlp_high_seq =3D 0;
        } else if (after(ack, tp->tlp_high_seq)) {
                /* ACK advances: there was a loss, so reduce cwnd. Rese=
t
                 * tlp_high_seq in tcp_init_cwnd_reduction()
                 */
                tcp_init_cwnd_reduction(sk);
                tcp_set_ca_state(sk, TCP_CA_CWR);
                tcp_end_cwnd_reduction(sk);
                tcp_try_keep_open(sk);
                NET_INC_STATS_BH(sock_net(sk),
                                 LINUX_MIB_TCPLOSSPROBERECOVERY);
        } else if (!(flag & (FLAG_SND_UNA_ADVANCED |
                             FLAG_NOT_DUP | FLAG_DATA_SACKED))) {
                /* Pure dupack: original and TLP probe arrived; no loss=
 */
                tp->tlp_high_seq =3D 0;
        }
}

>
>
