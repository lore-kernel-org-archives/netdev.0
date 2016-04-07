From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2 2/2] sctp: delay calls to sk_data_ready() as much as
 possible
Date: Thu, 7 Apr 2016 10:35:25 -0300
Message-ID: <20160407133525.GD15005@localhost.localdomain>
References: <cover.1459952558.git.marcelo.leitner@gmail.com>
 <703257ed516669b180fcce57e6745b1853da9a95.1459952558.git.marcelo.leitner@gmail.com>
 <87egah3ktv.fsf@beetle.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbcDGNf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 09:35:29 -0400
Content-Disposition: inline
In-Reply-To: <87egah3ktv.fsf@beetle.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 10:05:32AM +0200, Jakub Sitnicki wrote:
> On Wed, Apr 06, 2016 at 07:53 PM CEST, Marcelo Ricardo Leitner <marce=
lo.leitner@gmail.com> wrote:
> > Currently, the processing of multiple chunks in a single SCTP packe=
t
> > leads to multiple calls to sk_data_ready, causing multiple wake up
> > signals which are costly and doesn't make it wake up any faster.
> >
> > With this patch it will notice that the wake up is pending and will=
 do it
> > before leaving the state machine interpreter, latest place possible=
 to
> > do it realiably and cleanly.
> >
> > Note that sk_data_ready events are not dependent on asocs, unlike w=
aking
> > up writers.
> >
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > ---
>=20
> [...]
>=20
> > diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> > index 7fe56d0acabf66cfd8fe29dfdb45f7620b470ac7..e7042f9ce63b0cfca50=
cae252f51b60b68cb5731 100644
> > --- a/net/sctp/sm_sideeffect.c
> > +++ b/net/sctp/sm_sideeffect.c
> > @@ -1742,6 +1742,11 @@ out:
> >  			error =3D sctp_outq_uncork(&asoc->outqueue, gfp);
> >  	} else if (local_cork)
> >  		error =3D sctp_outq_uncork(&asoc->outqueue, gfp);
> > +
> > +	if (sctp_sk(ep->base.sk)->pending_data_ready) {
> > +		ep->base.sk->sk_data_ready(ep->base.sk);
> > +		sctp_sk(ep->base.sk)->pending_data_ready =3D 0;
> > +	}
> >  	return error;
> >  nomem:
> >  	error =3D -ENOMEM;
>=20
> Would it make sense to introduce a local variable for ep->base.sk (an=
d
> make this function 535+1 lines long ;-)
>=20
>       struct sock *sk =3D ep->base.sk;
>=20
> ... like sctp_ulpq_tail_event() does?

I guess so, yes. Same for sctp_sk() cast then. I=B4ll post a new versio=
n
later, thanks.

  Marcelo
