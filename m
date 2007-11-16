From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [NET]: rt_check_expire() can take a long time, add a
 cond_resched()
Date: Thu, 15 Nov 2007 21:59:38 -0800
Message-ID: <20071115215938.44233733@laptopd505.fenrus.org>
References: <200711150401.lAF41mSs021898@hera.kernel.org>
	<20071115193802.4ec64eef@laptopd505.fenrus.org>
	<473D131A.5000200@cosmosbay.com>
	<473D18A5.2090309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, netdev@vget.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752827AbXKPGBN@vger.kernel.org>
In-Reply-To: <473D18A5.2090309@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2007 05:12:21 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > Arjan van de Ven a =C3=A9crit :
> >> On Thu, 15 Nov 2007 04:01:48 GMT
> >> Linux Kernel Mailing List <linux-kernel@vger.kernel.org> wrote:
> >>
> >>> Gitweb:
> >>> http://git.kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.=
6.git;a=3Dcommit;h=3Dd90bf5a976793edfa88d3bb2393f0231eb8ce1e5=20
> >>>
> >>> Commit:     d90bf5a976793edfa88d3bb2393f0231eb8ce1e5 Parent:
> >>> 66ba886254edbbd9442d30f1eef6f6fb0145027d Author:     Eric Dumazet
> >>> <dada1@cosmosbay.com> AuthorDate: Wed Nov 14 16:14:05 2007 -0800
> >>> Committer:  David S. Miller <davem@davemloft.net>
> >>> CommitDate: Wed Nov 14 16:14:05 2007 -0800
> >>>
> >>>     [NET]: rt_check_expire() can take a long time, add a
> >>> cond_resched()     On commit
> >>> 39c90ece7565f5c47110c2fa77409d7a9478bd5b:
> >>
> >>>     When the IP route cache is big, rt_check_expire() can take a
> >>> long time to run.  (default settings : 20% of the hash table is
> >>> scanned at each invocation)
> >>>         Adding cond_resched() helps giving cpu to higher priority=
=20
> >>> tasks if
> >>>     necessary.
> >>>         Using a "if (need_resched())" test before calling
> >>> "cond_resched();" is necessary to avoid spending too much time
> >>> doing the resched check.=20
> >>
> >> int __sched cond_resched(void)
> >> {
> >>         if (need_resched() &&  .....
> >>
> >> somehow I wonder why the second if() is useful at all; it's anothe=
r
> >> spot for a branch predictor to miss... and a void function call is
> >> really really cheap...=20
> >=20
> > Its not that cheap. The ChangeLog included my own numbers, on a
> > Pentium M machine. (i686, 1.6 GHz, 1.5 GB ram)
> >=20
> > Without "if (need_resched())" (so calling need_resched() X.XXX.XXX=20
> > times), each run takes 88ms
> >=20
> > With the extra check (and *much* less function calls), each run
> > takes 25ms
> >=20
>=20
> Looking at cond_resched(), I think the extra cost comes from
> "mov %esp,%edx ; and $0xffffe000,%edx" (current_thread_info())
>=20
> I dont have oprofile numbers yet, but I suspect CPU may have some
> delays to compute this pointer value, since %esp is probably 'busy'
> because of the preceding "call"

yeah the explicit reference makes the stack pointer tracking engine do =
a
commit I suspect which then also creates a data dependency in the code
flow.

however... this is likely a good argument for making cond_resched() as =
a
whole a #define (or inline) that does this test and then calls the out
of line code (which then doesn't need to retest, so it avoids the
double test)...




--=20
If you want to reach me at my work email, use arjan@linux.intel.com
=46or development, discussion and tips for power savings,=20
visit http://www.lesswatts.org
