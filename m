From: Joe Perches <joe@perches.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 03 Dec 2015 11:06:59 -0800
Message-ID: <1449169619.32567.8.camel@perches.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
	 <20151203130525.GB4164@mrl.redhat.com>
	 <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
	 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
	 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
	 <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
	 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
	 <f7twpsvgyar.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Aaron Conole <aconole@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0094.hostedemail.com ([216.40.44.94]:56001 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751898AbbLCTHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:07:07 -0500
In-Reply-To: <f7twpsvgyar.fsf@aconole.bos.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 13:52 -0500, Aaron Conole wrote:
> Dmitry Vyukov <dvyukov@google.com> writes:
> > On Thu, Dec 3, 2015 at 6:02 PM, Eric Dumazet <edumazet@google.com> =
wrote:
> > > On Thu, Dec 3, 2015 at 7:55 AM, Dmitry Vyukov <dvyukov@google.com=
> wrote:
> > > > On Thu, Dec 3, 2015 at 3:48 PM, Eric Dumazet  wrote:
> > > > > >=20
> > > > > > No, I don't. But pr_debug always computes its arguments. Se=
e no_printk
> > > > > > in printk.h. So this use-after-free happens for all users.
> > > > >=20
> > > > > Hmm.
> > > > >=20
> > > > > pr_debug() should be a nop unless either DEBUG or
> > > > > CONFIG_DYNAMIC_DEBUG are set
> > > > >=20
> > > > > On our production kernels, pr_debug() is a nop.
> > > > >=20
> > > > > Can you double check ? Thanks !
> > > >=20
> > > >=20
> > > > Why should it be nop? no_printk thing in printk.h pretty much
> > > > explicitly makes it not a nop...
>=20
> Because it was until commit 5264f2f75d8. It also violates my reading =
of
> the following from printk.h:
>=20
> =A0* All of these will print unconditionally, although note that pr_d=
ebug()
> =A0* and other debug macros are compiled out unless either DEBUG is d=
efined
> =A0* or CONFIG_DYNAMIC_DEBUG is set.
>=20
> > > >=20
> > > > Double-checked: debug_post_sfx leads to some generated code:
> > > >=20
> > > > =A0=A0=A0=A0=A0=A0=A0=A0debug_post_sfx();
> > > > ffffffff8229f256:=A0=A0=A0=A0=A0=A0=A048 8b 85 58 fe ff ff=A0=A0=
=A0=A0mov=A0=A0=A0=A0-0x1a8(%rbp),%rax
> > > > ffffffff8229f25d:=A0=A0=A0=A0=A0=A0=A048 85 c0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0test=A0=A0=A0%rax,%rax
> > > > ffffffff8229f260:=A0=A0=A0=A0=A0=A0=A074 24=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0je
> > > > ffffffff8229f286=20
> > > > ffffffff8229f262:=A0=A0=A0=A0=A0=A0=A08b b0 a8 00 00 00=A0=A0=A0=
=A0=A0=A0=A0mov=A0=A0=A0=A00xa8(%rax),%esi
> > > > ffffffff8229f268:=A0=A0=A0=A0=A0=A0=A048 8b 85 60 fe ff ff=A0=A0=
=A0=A0mov=A0=A0=A0=A0-0x1a0(%rbp),%rax
> > > > ffffffff8229f26f:=A0=A0=A0=A0=A0=A0=A044 89 85 74 fe ff ff=A0=A0=
=A0=A0mov=A0=A0=A0=A0%r8d,-0x18c(%rbp)
> > > > ffffffff8229f276:=A0=A0=A0=A0=A0=A0=A048 8b 78 20=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A00x20(%rax),%rdi
> > > > ffffffff8229f27a:=A0=A0=A0=A0=A0=A0=A0e8 71 28 01 00=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0callq
> > > > ffffffff822b1af0=20
> > > > ffffffff8229f27f:=A0=A0=A0=A0=A0=A0=A044 8b 85 74 fe ff ff=A0=A0=
=A0=A0mov=A0=A0=A0=A0-0x18c(%rbp),%r8d
> > > >=20
> > > > =A0=A0=A0=A0=A0=A0=A0=A0return error;
> > > > }
> > > > ffffffff8229f286:=A0=A0=A0=A0=A0=A0=A048 81 c4 a0 01 00 00=A0=A0=
=A0=A0add=A0=A0=A0=A0$0x1a0,%rsp
> > > > ffffffff8229f28d:=A0=A0=A0=A0=A0=A0=A044 89 c0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%r8d,%eax
> > > > ffffffff8229f290:=A0=A0=A0=A0=A0=A0=A05b=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%rbx
> > > > ffffffff8229f291:=A0=A0=A0=A0=A0=A0=A041 5c=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%r12
> > > > ffffffff8229f293:=A0=A0=A0=A0=A0=A0=A041 5d=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%r13
> > > > ffffffff8229f295:=A0=A0=A0=A0=A0=A0=A041 5e=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%r14
> > > > ffffffff8229f297:=A0=A0=A0=A0=A0=A0=A041 5f=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%r15
> > > > ffffffff8229f299:=A0=A0=A0=A0=A0=A0=A05d=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%rbp
> > > > ffffffff8229f29a:=A0=A0=A0=A0=A0=A0=A0c3=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0retq
> > >=20
> > > This is a serious concern, because we let in the past lot of patc=
hes
> > > converting traditional
>=20
> +1
>=20
> > > #ifdef DEBUG
> > > # define some_hand_coded_ugly_debug()=A0=A0printk( ...._
> > > #else
> > > # define some_hand_coded_ugly_debug()
> > > #endif
> > >=20
> > > On the premise pr_debug() would be a nop.
> > >=20
> > > It seems it is not always the case. This is a very serious proble=
m.
>=20
> +1
>=20
> > > We probably have hundred of potential bugs, because few people
> > > actually make sure all debugging stuff is correct,
> > > like comments can be wrong because they are not updated properly =
as
> > > time flies.
> > >=20
> > > It is definitely a nop for many cases.
> > >=20
> > > +void eric_test_pr_debug(struct sock *sk)
> > > +{
> > > +=A0=A0=A0=A0=A0=A0=A0if (atomic_read(&sk->sk_omem_alloc))
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pr_debug("%s: optme=
m leakage for sock %p\n",
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0__func__, sk);
> > > +}
> > >=20
> > > ->
> > >=20
> > > 0000000000004740 :
> > > =A0=A0=A0=A04740: e8 00 00 00 00=A0=A0=A0=A0=A0=A0=A0callq=A0=A04=
745=20
> > > 4741: R_X86_64_PC32 __fentry__-0x4
> > > =A0=A0=A0=A04745: 55=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0push=A0=A0=A0%rbp
> > > =A0=A0=A0=A04746: 8b 87 24 01 00 00=A0=A0=A0=A0=A0mov=A0=A0=A0=A0=
0x124(%rdi),%eax=A0=A0=A0=A0=A0//
> > > atomic_read()=A0=A0but nothing follows
> > > =A0=A0=A0=A0474c: 48 89 e5=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
mov=A0=A0=A0=A0%rsp,%rbp
> > > =A0=A0=A0=A0474f: 5d=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0pop=A0=A0=A0=A0%rbp
> > > =A0=A0=A0=A04750: c3=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0retq
> >=20
> >=20
> >=20
> > I would expect that it is nop when argument evaluation does not hav=
e
> > side-effects. For example, for a load of a variable compiler will m=
ost
> > likely elide it (though, it does not have to elide it, because the
> > load is spelled in the code, so it can also legally emit the load a=
nd
> > doesn't use the result).
> > But if argument computation has side-effect (or compiler can't prov=
e
> > otherwise), it must emit code. It must emit code for function calls
> > when the function is defined in a different translation unit, and f=
or
> > volatile accesses (most likely including atomic accesses), etc
>=20
> This isn't 100% true. As you state, in order to reach the return 0, a=
ll
> side effects must be evaluated. Load generally does not have side
> effects, so it can be safely elided, but function() must be emitted.
>=20
> However, that is _not_ required to get the desired warning emission o=
n a
> printf argument function, see http://pastebin.com/UHuaydkj for an
> example.
>=20
> I think that as a minimum, the following patch should be evaluted, bu=
t am
> unsure to whom I should submit it (after I test):

Andrew Morton <akpm@linux-foundation.org> (cc'd)

> diff --git a/include/linux/printk.h b/include/linux/printk.h
> index 9729565..cd24d2d 100644
> --- a/include/linux/printk.h
> +++ b/include/linux/printk.h
> @@ -286,7 +286,7 @@ extern asmlinkage void dump_stack(void) __cold;
> =A0=A0=A0=A0=A0=A0=A0=A0printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
> =A0#else
> =A0#define pr_debug(fmt, ...) \
> -=A0=A0=A0=A0=A0=A0=A0no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__=
)
> +=A0=A0=A0=A0=A0=A0=A0({ if(0) printk(KERN_DEBUG pr_fmt(fmt), ##__VA_=
ARGS__); 0;})

More common is to use do {} while (0) instead of a
statement expression.

I think it'd be good to change pr_debug and variants to
	do { if (0) no_printk(...) } while (0)
or some other form that completely eliminates all the
side-effects/function evaluations.

I think the same should be true when CONFIG_PRINTK is
not enabled.

https://lkml.org/lkml/2014/12/3/696
