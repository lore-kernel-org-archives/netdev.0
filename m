From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 13:24:02 -0400
Message-ID: <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
 <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com>
 <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com> <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 12:11 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, May 13, 2011 at 7:56 AM, Andrew Lutomirski <luto@mit.edu> wrote:
>>
>> So what I really want is a fancy version of git bisect that makes no
>> assumptions about the relationship of good and bad commits in the
>> graph and just finds me a commit that is bad but for which all parents
>> are good or vice versa.
>
> Ehh. That's the "non-fancy" way of testing, I'm afraid: if you cannot
> make assumption about the relationship between good and bad commits,
> then you have to test _every_ commit.

Actually, I disagree.  I suspect, although I haven't convinced myself
very well yet, that if you assume that the bug was caused one or more
times by some commit C that works but where all of C's parents don't
work (or vice versa), then there exists an algorithm that, at least
for most histories, will find such a commit in polylog tries given a
starting commit that works and another one that fails.  But I have to
do real work before I think too much more about that.

That being said, even the fairly weak requirement I wanted wasn't really true...

[I said in a different email:]
>
> In conclusion, I found the problem.  It's a clusterfuck and I think
> there's no way that any bisection tool under any sane assumptions
> could have found it.  Patch coming in a couple seconds b/c I think it
> needs to go in to 2.6.39.

I should clarify what the problem was for people who don't want to dig
around the archives:

I have a Sandy Bridge box, which means that I need to run a recent
kernel for things to work decently.  The bug was introduced once way
back in the depths of time (i.e. before any kernel that I ever tried
since I got the machine).  It was fixed shortly before 2.6.38 by
commit A.  It was reintroduced in a merge B that was a little past A.
B went in to 2.6.39-something via airlied's tree.  B's other parent
was bad because it didn't contain A.  It looks like this:

-------------------------------.
                                \
(bad pre-2.6.38-rc2)--.          \ (etc)
                       \          \
          .--(good)-----B--(bad)-. \
         /                        \ \
(bad)---A--(good)--v2.6.38---------x-x-v2.6.39-rc7


(A is a1656b9090f7008d2941c314f5a64724bea2ae37 and B is
47ae63e0c2e5fdb582d471dc906eb29be94c732f)


The offending commit is B, but the bisection is screwed, because the
series of nonworking commits dangling off B looks just like any other
series of nonworking commits like the top line that have nothing to do
with the problem.  Sure enough, my bisection ended up wandering into
dark corners (like the networking tree), which were innocent.

I found the problem by manually bisecting the --first-parent chain
from v2.6.39-rc7 to v2.6.38 to figure out that the problem came from a
drm merge and then noticing that something was screwed up when the
bisection pointed to a commit (in the right driver, even) that wasn't
the problem.  (I even tried reverting it to no avail.)  Bisection was
*sure* it was the problem, though, because its parent was in v2.6.38.

I thought that maybe the problem had been introduced more than once,
so I tried v2.6.38-rc5, and it *failed*.  (That's what caused a lot of
my confusion the first time around -- lots of commits that were "good"
(in the sense that they would work if merged correctly into the
v2.6.39 branch before B got there) failed instead.

So I bisected between v2.6.38 and v2.6.38-rc5 to find the commit that
fixed the problem, since there had to be something.  Once I found it,
a bunch of confused calls to git blame found the merge that undid the
fix.

> Think of it as a compression method: it generates the smallest
> possible set of test points for you. But it's a "lossy" compression -
> you don't test everything. And it's extreme: it boils down 10k commit
> events to about 13 bisection events. If anything goes wrong (like the
> bug not being entirely repeatable, or the bug comes and goes), it will
> give the wrong answer.

As I just learned :)

--Andy
