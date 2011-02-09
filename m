From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Linux 2.6.38-rc4 (hysdn: BUG)
Date: Wed, 9 Feb 2011 13:25:29 -0800
Message-ID: <20110209132529.76927f5f.randy.dunlap@oracle.com>
References: <AANLkTimmb26UiBSukdNnVdxLJpCGd=QqpCw8vQoHALh-@mail.gmail.com>
	<20110209092419.2b335697.randy.dunlap@oracle.com>
	<AANLkTimUg8Dm9mZotubcgPHz8_at=_hnbeWUo-LfSALp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimUg8Dm9mZotubcgPHz8_at=_hnbeWUo-LfSALp@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Feb 2011 11:44:00 -0800 Linus Torvalds wrote:

> On Wed, Feb 9, 2011 at 9:24 AM, Randy Dunlap <randy.dunlap@oracle.com=
> wrote:
> >
> > on x86_64. =A0no HYSDN hardware found (correct).
> > Nearly allmodconfig.
> >
> >
> > [ =A0 65.397577] HYSDN: module Rev: 1.6.6.6 loaded
> > [ =A0 65.397584] HYSDN: network interface Rev: 1.8.6.4
> > [ =A0 65.398057] HYSDN: 0 card(s) found.
> > [ =A0 65.398121] BUG: unable to handle kernel paging request at fff=
fffffa06c99f0
> > [ =A0 65.398269] IP: [<ffffffffa06c68ba>] hysdn_getrev+0x2e/0x50 [h=
ysdn]
> > [ =A0 65.398379] PGD 1a14067 PUD 1a18063 PMD 6f6c1067 PTE 800000006=
ce8c161
> > [ =A0 65.398613] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
> > [ =A0 65.400030]
> > [ =A0 65.400030] Pid: 2497, comm: modprobe Not tainted 2.6.38-rc4 #=
1 0TY565/OptiPlex 745
> > [ =A0 65.400030] RIP: 0010:[<ffffffffa06c68ba>] =A0[<ffffffffa06c68=
ba>] hysdn_getrev+0x2e/0x50 [hysdn]
> > [ =A0 65.400030] RSP: 0018:ffff88006eec1e68 =A0EFLAGS: 00010206
> > [ =A0 65.400030] RAX: ffffffffa06c99f1 RBX: ffffffffa06c99e9 RCX: f=
fff88007c4159a0
>=20
> The instruction sequence decodes to
>=20
>   1e:	be 24 00 00 00       	mov    $0x24,%esi
>   23:	48 89 df             	mov    %rbx,%rdi
>   26:	e8 5b 39 c0 e0       	callq  0xffffffffe0c03986
>   2b:*	c6 40 ff 00          	movb   $0x0,-0x1(%rax)     <-- trapping =
instruction
>=20
> which seems to be this
>=20
>                 p =3D strchr(rev, '$');
>                 *--p =3D 0;
>=20
> code. And yes, it's total crap, because while "p" and "rev" are "char
> *", the string that is passed in is actually of type "const char *",
> so that function is seriously broken. It's also seriously broken to
> not test that "p" is non-NULL - the function would just break if ther=
e
> is a colon in the string but not a '$'.
>=20
> And hysdn_procconf_init() passes in a constant string to the thing:
>=20
>     static char *hysdn_procconf_revision =3D "$Revision: 1.8.6.4 $";
>=20
> What happens is that it breaks when we mark the constant section as
> read-only, because you have CONFIG_DEBUG_RODATA enabled.
>=20
> So the fix seems to be to
>  - fix the prototype for hysdn_getrev() to not have "const".
>  - fix hysdn_procconf_init() to not pass in a constant string to it
>=20
> The minimal patch would appear to be something like the appended. UNT=
ESTED!

for your patch:

Tested-and-acked-by: Randy Dunlap <randy.dunlap@oracle.com>

> Btw, all of this code seems to go back to before the git history even
> started, so it doesn't seem to be new. I assume you haven't tried
> booting these all-module kernels before? Or is it just the
> DEBUG_RODATA thing that is new for you?

Neither is new.  I tested and reported many-modules on 2.6.37-rc1 and
reported these 2 bugs:

https://bugzilla.kernel.org/show_bug.cgi?id=3D22912
https://bugzilla.kernel.org/show_bug.cgi?id=3D22882

and that was with CONFIG_DEBUG_RODATA=3Dy.
I don't know how hysdn was missed at that time.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
