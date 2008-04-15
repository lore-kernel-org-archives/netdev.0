From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Tue, 15 Apr 2008 17:04:07 -0300
Message-ID: <20080415200407.GD5025@ghostprotocols.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804150145.05571.tomasz@grobelny.oswiecenia.net> <20080415151403.GA20735@gerrit.erg.abdn.ac.uk> <200804152138.41077.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbYDOUsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 16:48:37 -0400
Content-Disposition: inline
In-Reply-To: <200804152138.41077.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Apr 15, 2008 at 09:38:40PM +0200, Tomasz Grobelny escreveu:
> Dnia Tuesday 15 of April 2008, Gerrit Renker napisa=C5=82:
> > | > @@ -501,6 +519,8 @@ struct dccp_sock {
> > | >  	struct ccid			*dccps_hc_rx_ccid;
> > | >  	struct ccid			*dccps_hc_tx_ccid;
> > | >  	struct dccp_options_received	dccps_options_received;
> > | > +	__u8				dccps_qpolicy;
> > | > +	__u32				dccps_tx_qlen;
> > | >  	enum dccp_role			dccps_role:2;
> > | >  	__u8				dccps_hc_rx_insert_options:1;
> > | >  	__u8				dccps_hc_tx_insert_options:1;
> > |
> > | I know that currently none of the policies has any per-socket dat=
a. But
> > | if it had were should it go?
> >
> > I can't see anything wrong with putting everything into dccp_sock. =
To do it
> > well, we could consider inserting documentation such as "this secti=
on is
> > only for queueing policies" (as is done very well for struct tcp_so=
ck).
> >
> Let me remind you your comment made on 18/03/2008 on dccp ml to my fi=
rst=20
> patch:
>  --- START ---=20
> @@ -545,6 +549,8 @@ struct dccp_sock {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 __u8 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dccps_hc_tx_=
insert_options:1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 __u8 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dccps_server=
_timewait:1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct timer_list =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 dccps_xmit_timer;
> + =C2=A0 =C2=A0 =C2=A0 struct queuing_policy =C2=A0 =C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0*dccps_policy;
> + =C2=A0 =C2=A0 =C2=A0 void =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*dccps_policy_d=
ata;
> =C2=A0};
>=20
> I think this should be just one field for the policy, and the
> policy_data can be an internal field of `struct queueing_policy'
> (compare with struct ackvec or struct ccid).
>  --- END ---=20
>=20
> > I see several advantages of this:
> >  * by just storing the u8 of the policy ID, the socket as a whole g=
ets
> > smaller,
> >  * the internals of the function pointer table can be hidden,
> >=20
> That's ok with me.=20
>=20
> > * when not using nested structs, the elements can be optimised for=20
> > minimal space,
> I have nothing against it. In fact that's what I did in the first try=
=2E
>=20
> > | > +	case DCCP_SOCKOPT_QPOLICY_ID:
> > | > +		if (sk->sk_state !=3D DCCP_CLOSED)
> > | > +			err =3D -EISCONN;
> > |
> > | What about DCCP_LISTENING state?
> >
> > There is a problem with allowing this, considering for example:
> > (...)
> Ok, you are right. If before DCCP_LISTENING there is always DCCP_CLOS=
ED then=20
> there is no need to allow changing qpolicy in DCCP_LISTENING state.
>=20
> > Please take your time and check through the other parts of the patc=
h as
> > well. I would like to accumulate the issues and then address each o=
f the
> If I didn't mention some parts of the patch you can assume that I'm o=
k with=20
> them.
>=20
> > points. And also, do some testing.I haven't had time to write test =
code for
> > prio policy -- is there something in your SVN repository?
> >
> Have a look at http://dccp.one.pl/svn/userspace/test/ And I'll also d=
o some=20
> testing of your patch.
>=20
> One more question (probably more for Arnaldo): is there any timeframe=
 to push=20
> changes from test tree upstream?

Not at this moment, I'm not managing to dedicate time for another round
of reviewing of what is in Gerrit's tree :-(

- Arnaldo
