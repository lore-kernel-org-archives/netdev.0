From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Fri, 4 Dec 2015 10:55:43 -0200
Message-ID: <20151204125543.GG4164@mrl.redhat.com>
References: <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
 <f7twpsvgyar.fsf@aconole.bos.csb>
 <566098BD.6010803@akamai.com>
 <1449172984.12092.0.camel@perches.com>
 <5660A1A7.3080301@akamai.com>
 <1449174246.12092.8.camel@perches.com>
 <5660A951.4000808@akamai.com>
 <1449175884.17296.2.camel@perches.com>
 <CACT4Y+Z68wnWjFZ6e2AmePBNu1U+V9N_4szdyNrrf710Er2zyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, Jason Baron <jbaron@akamai.com>,
	Aaron Conole <aconole@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z68wnWjFZ6e2AmePBNu1U+V9N_4szdyNrrf710Er2zyg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 11:40:02AM +0100, Dmitry Vyukov wrote:
> On Thu, Dec 3, 2015 at 9:51 PM, Joe Perches <joe@perches.com> wrote:
> > (adding lkml as this is likely better discussed there)
> >
> > On Thu, 2015-12-03 at 15:42 -0500, Jason Baron wrote:
> >> On 12/03/2015 03:24 PM, Joe Perches wrote:
> >> > On Thu, 2015-12-03 at 15:10 -0500, Jason Baron wrote:
> >> > > On 12/03/2015 03:03 PM, Joe Perches wrote:
> >> > > > On Thu, 2015-12-03 at 14:32 -0500, Jason Baron wrote:
> >> > > > > On 12/03/2015 01:52 PM, Aaron Conole wrote:
> >> > > > > > I think that as a minimum, the following patch should be evaluted,
> >> > > > > > but am unsure to whom I should submit it (after I test):
> >> > > > []
> >> > > > > Agreed - the intention here is certainly to have no side effects. It
> >> > > > > looks like 'no_printk()' is used in quite a few other places that would
> >> > > > > benefit from this change. So we probably want a generic
> >> > > > > 'really_no_printk()' macro.
> >> > > >
> >> > > > https://lkml.org/lkml/2012/6/17/231
> >> > >
> >> > > I don't see this in the tree.
> >> >
> >> > It never got applied.
> >> >
> >> > > Also maybe we should just convert
> >> > > no_printk() to do what your 'eliminated_printk()'.
> >> >
> >> > Some of them at least.
> >> >
> >> > > So we can convert all users with this change?
> >> >
> >> > I don't think so, I think there are some
> >> > function evaluation/side effects that are
> >> > required.  I believe some do hardware I/O.
> >> >
> >> > It'd be good to at least isolate them.
> >> >
> >> > I'm not sure how to find them via some
> >> > automated tool/mechanism though.
> >> >
> >> > I asked Julia Lawall about it once in this
> >> > thread:  https://lkml.org/lkml/2014/12/3/696
> >> >
> >>
> >> Seems rather fragile to have side effects that we rely
> >> upon hidden in a printk().
> >
> > Yup.
> >
> >> Just convert them and see what breaks :)
> >
> > I appreciate your optimism.  It's very 1995.
> > Try it and see what happens.
> 
> 
> Whatever is the resolution for pr_debug, we still need to fix this
> particular use-after-free. It affects stability of debug builds, gives
> invalid debug output, prevents us from finding more bugs in SCTP. And
> maybe somebody uses CONFIG_DYNAMIC_DEBUG in production.

Agreed. I'm already working on a fix for this particular use-after-free.

Another interesting thing about this is that sctp_do_sm() is called for
nearly every movement that happens on a sctp socket. Said that, that
always-running IDR search hidden on that debug statement do have some
nasty performance impact, specially because it's serialized on a
spinlock. This wouldn't be happening if it was fully ellided and would
be ok if that pr_debug() was really being printed, but not as it is.
Kudos to this report that I could notice this. I'm trying to fix this on
SCTP-side as well.

  Marcelo
