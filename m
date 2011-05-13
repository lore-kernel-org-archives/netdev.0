From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 12:18:03 -0700
Message-ID: <BANLkTinGOHX-fNuQqZr50nvUC4BTymwBNg@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
 <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com>
 <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com> <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com>
 <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com> <BANLkTinVT=9+-HhwXcyLBwrnhX9F9Qz3ww@mail.gmail.com>
 <4DCD79A0.7000500@kdbg.org> <BANLkTi=smoaARKyzWxFjid-E7qehmyAX8w@mail.gmail.com>
 <7vliya77xl.fsf@alter.siamese.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Sixt <j6t@kdbg.org>, Andrew Lutomirski <luto@mit.edu>,
	Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Junio C Hamano <gitster@pobox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7vliya77xl.fsf@alter.siamese.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 11:48 AM, Junio C Hamano <gitster@pobox.com> wr=
ote:
>
> Could you please clarify "off-limits"?
>
> Do you mean "anything before v2.6.38 did not even have this feature, =
so
> the result of testing a version in that range does not give us any
> information"?

Well, I think it's useful in two cases.

It's useful for the "before this version, the test we're doing doesn't
even make sense and cannot succeed" sense.

That doesn't have to be about hardware support, it could be any
feature. For example, in git, say that you noticed that
--dirstat-by-file stopped working at some point. You know it was good
when you merged it, so you'd do

  git bisect start
  git bisect good ac9666f84a59

but you'd also go "that's also when I introduced the *test* for it, so
I'll need to require that":

  git bisect requires ac9666f84a59

and then you can start it all off:

  git bisect bad
  git bisect run sh -c "make test"

or whatever.

Because you don't want to go into the merges that were based on code
that didn't even _have_ that feature.

Ok, so that's a made-up and contrieved example (it would make more
sense for when you add a whole new flag, and your test-script is
testign that new functionality), but it kind of explains the notion:
it will not bother to run bisect on code that simply isn't _relevant_
for the issue you are bisecting.

>=A0Upon seeing "bad" result from a version before v2.6.38, what can we=
 conclude?

The point would be that such versions aren't even _testable_. So the
whole "seeing 'bad'" concept is a NULL concept. It's like the above
"new command line flag to 'git'" example: it's not that those commits
might not have broken something, but those commits are crazy to test.

If it turns out that a merge brought in the breakage, we'd have to do
a totally new kind of test thing. But from a bisect standpoint, it's
already very interesting if the end result is "hey, you merged that
code that didn't even _support_ the feature we're testing, and that
broke it". That gives quite a bit of information, and opens up new
avenues for testing.

=46or example, at that point, we might decide that "Oh, ok, now I will
need to re-run the bisect for everthing that came in in that merge,
but I will do a new merge at that point to see which commit it is that
doesn't play nice with the new feature".

>=A0The breakage cannot possibly come from the feature
> that is being checked, so the procedure to check itself is busted?

Right.

HOWEVER.

There's another reason to say "require version XYZ", and that's
essentially a "I want to do a (quicker) high-level bisect". Especially
the way the kernel merge window is done, it might be that versions
prior to v2.6.38 work perfectly _fine_, but what you want to do is to
quickly bisect down to which subsystem caused breakage.

A good way to do that would be to just say "requires v2.6.38", and
suddenly the actual set of commits that we're going to bisect is going
to be *much* smaller. We're basically throwing away all the individual
commits that were merged in the merge window, and saying something
that approximates to "we are only interested in the merge points".

Why would we do that? Just to get a quicker "this is the problematic
subsystem". So the "requires xyz" might be quite useful for that
reason too.

                 Linus
