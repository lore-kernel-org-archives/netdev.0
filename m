From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 10:54:41 -0700
Message-ID: <BANLkTinVT=9+-HhwXcyLBwrnhX9F9Qz3ww@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
 <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com>
 <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com> <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com>
 <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 10:24 AM, Andrew Lutomirski <luto@mit.edu> wrot=
e:
> On Fri, May 13, 2011 at 12:11 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Ehh. That's the "non-fancy" way of testing, I'm afraid: if you canno=
t
>> make assumption about the relationship between good and bad commits,
>> then you have to test _every_ commit.
>
> Actually, I disagree. =A0I suspect, although I haven't convinced myse=
lf
> very well yet, that if you assume that the bug was caused one or more
> times by some commit C that works but where all of C's parents don't
> work (or vice versa), then there exists an algorithm that, at least
> for most histories, will find such a commit in polylog tries given a
> starting commit that works and another one that fails. =A0But I have =
to
> do real work before I think too much more about that.

So I do think we could probably add a few more concepts to git-bisect
that could be quite useful.

=46or example, in your case, since you had certain requirements of
support that simply didn't exist earlier, something like

   git bisect requires v2.6.38

would have been really useful - telling git bisect that any commit
that cannot reach that required commit is not even worth testing.

That would still have been rather dangerous thing to say (it's not
actually a _true_ requirement: there may well be points in the i915
development tree that still had all the required sandybridge support,
but hadn't been merged into 38 yet), but it would have limited your
bisection space to a degree that would have been useful.

So if that "requirement" wasn't actually true (and the bug was
introduced by a commit that was based on something before v2.6.38),
the bisect would have pinpointed the particular merge that brought the
commit in. So "pinpointed" might in this case mean "thousands of
commits", but it would still likely be a very useful end result.

And no, git-bisect doesn't have that kind of concept. And it could
potentially be quite useful.

Another thing that would be useful for git bisect would be the notion
of "git bisect cherry-pick", which is useful for applying particular
commits that fix unrelated problems _while_ you bisect the one you're
interested in. You can currently do it manually, or by playing around
with 'git bisect run' and making hacky stuff, but it's a pain. You
didn't hit that case, but it's actually the most common problem there
is with git bisect - having multiple _different_ bugs, rather than
having the same bug show up twice.

Yet another issue - related to the "multiple different bugs" thing -
is exactly the fact that 'git bisect' only has a concept of a "single
bug". You cannot say "this revision is good, that revision has bug A,
that revision has bug B", where bug A might hide bug B and vice versa.
If you have multiple bugs and they change symptoms, it can be _really_
painful to bisect things, because you have to basically always pick
one of them, and then re-do the whole thing after you've found the
first one.

So there's no question that there might not be things we would want to
do with "git bisect".

Of course, one of the real advantages of "git bisect" is that for many
cases it's pretty simple. You can (and we absolutely rely on this)
have normal users that have _no_ idea about kernel development do a
bisect - the only thing they need to be able to do is to compile and
install their own kernel, and reliably recognize the problematic
symptoms.

And that's really the biggest advantage of bisecting - it doesn't
_always_ work, but it works often enough, and it's totally mindless.
So clever features and extra complexity and smart things that can be
done with it is often not all that useful - because a major user base
is very much the "I don't know kernel development, but I want to help
and my machine shows badness" kind of situation.

                          Linus
