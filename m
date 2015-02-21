From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Sat, 21 Feb 2015 08:42:23 +0100 (CET)
Message-ID: <970522031.62268.1424504543731.open-xchange@webmail.nmp.proximus.be>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be> <1424455977-21903-6-git-send-email-fabf@skynet.be> <54E77E34.6050909@cogentembedded.com> <20150220185800.GR2896@worktop.programming.kicks-ass.net>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>
To: Peter Zijlstra <peterz@infradead.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsec108.isp.belgacom.be ([195.238.20.104]:38650 "EHLO
	mailsec108.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbbBUHmg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2015 02:42:36 -0500
In-Reply-To: <20150220185800.GR2896@worktop.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 20 February 2015 at 19:58 Peter Zijlstra <peterz@infradead.org> wr=
ote:
>
>
> On Fri, Feb 20, 2015 at 09:34:28PM +0300, Sergei Shtylyov wrote:
> > Hello.
> >
> > On 02/20/2015 09:12 PM, Fabian Frederick wrote:
> >
> > >Use helper functions to access current->state.
> > >Direct assignments are prone to races and therefore buggy.
> >
> > >current->state =3D TASK_RUNNING is replaced by __set_current_state=
()
> >
> >=C2=A0 =C2=A0 You sometimes use __set_current_state() and sometimes
> >set_current_state().
>
> It depends on which state; setting yourself TASK_RUNNING is free of
> wakeup races -- you're already running after all, so it can safely us=
e
> __set_current_state().
>
> Setting a blocking state otoh needs set_current_state() which issues =
a
> full memory barriers with the store (critically in this case,
> effectively after the store) such that it orders the state store with=
 a
> subsequent load in the condition check if it really needs to go to
> sleep.
>
>
> In full:
>
>=C2=A0 =C2=A0 =C2=A0 =C2=A0current->state =3D TASK_UNINTERRUPTIBLE;=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wait =3D false;
>=C2=A0 =C2=A0 =C2=A0 =C2=A0smp_mb();=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0smp_wmb();
>=C2=A0 =C2=A0 =C2=A0 =C2=A0if (wait)=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0p->state =3D TASK_RUNNING;
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0schedule();
>
> Without that smp_mb(); the following order is possible:
>
>=C2=A0 =C2=A0 =C2=A0 =C2=A0if (wait)
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wait =3D false;
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0smp_wmb();
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0p->state =3D TASK_R=
UNNING;
>=C2=A0 =C2=A0 =C2=A0 =C2=A0current->state =3D TASK_UNINTERRUPTIBLE;
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0schedule();
>
> And we'll wait forever more..
Do I have to add more comments in changelogs or is it OK for you ?
Maybe something like:
"
current->state =3D TASK_RUNNING can safely be converted to __set_curren=
t_state()
as we're already in that state. Other assignments are converted to
set_current_state() (which uses set_mb()).

"
Regards,
=46abian
>
