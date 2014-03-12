From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [tcp] The ssthresh reduce during 3WHS
Date: Wed, 12 Mar 2014 08:44:25 -0700
Message-ID: <CAK6E8=cHqFNe8xTcG=PnOOLWDoX2wh0TKDSeFsbtTnUSZWSvjA@mail.gmail.com>
References: <CAH4NVoT4ofCNKAmcnO1AgEbs+ywbXom=E28k2VU4dB+yK79S_A@mail.gmail.com>
 <1394634390.21721.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yong Zhang <fell198904@gmail.com>, netdev <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:43246 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbaCLPpG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:45:06 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so10711187iec.18
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 08:45:05 -0700 (PDT)
In-Reply-To: <1394634390.21721.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 7:26 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> On Wed, 2014-03-12 at 21:46 +0800, Yong Zhang wrote:
> > hi=EF=BC=8C
> >
> > I am trying to to apply patch 9ad7c049f0f79c418e293b1b68cf10d68f54f=
cdb
> > to my old version kernel, but I am not understanding the following
> > changes.
> >
> > The comments int the patch say ssthresh may reduce unnecessarily
> > druing 3WHS,  but i can not find the reduce operation of ssthresh
> > during 3WHS.
> >
> > Can you please explain when dose this may hanppen?
I can think of two cases:

1. active open: syn -> (timeout) -> tcp_retransmit_timer ->
tcp_enter_loss -> reduce ssthresh

2. passive fast open: data sent during 3whs after syn-ack -> timeout
-> tcp_enter_loss -> reduce ssthresh

It's arguable the resetting is necessary or not. but resetting
ssthresh seems better b/c it is unlikely to be the BDP, especially in
case 1.

btw, it'll be easy to test this using https://code.google.com/p/packetd=
rill/

> >
>
> You might CC patch author when asking such questions...
>
>
> >
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index bef9f04..ea0d218 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -880,6 +880,11 @@ static void tcp_init_metrics(struct sock *sk)
> >
> >         tp->snd_ssthresh =3D dst_metric(dst, RTAX_SSTHRESH);
> >                  if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
> >                          tp->snd_ssthresh =3D tp->snd_cwnd_clamp;
> > +       } else {
> > +                /* ssthresh may have been reduced unnecessarily du=
ring.
> > +                * 3WHS. Restore it back to its initial default.
> > +                */
> > +                tp->snd_ssthresh =3D TCP_INFINITE_SSTHRESH;
> >          }
> >
> >
> > Thanks,
> > Fel
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
