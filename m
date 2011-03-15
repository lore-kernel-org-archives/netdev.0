From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 15 Mar 2011 08:43:10 -0700
Message-ID: <AANLkTimbaHZtKGRmg16dy--nwsVzbZpHEuXAnBQ1RWYX@mail.gmail.com>
References: <20110310.155556.48513201.davem@davemloft.net> <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
 <20110311204823.GB7906@fieldses.org> <20110311.130128.71121155.davem@davemloft.net>
 <1299878274.2814.8.camel@bwh-desktop> <20110311214209.GB9404@fieldses.org>
 <20110312040941.GA15526@home.goodmis.org> <alpine.DEB.2.00.1103150019060.5340@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steven Rostedt <rostedt@goodmis.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: david@lang.hm
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1103150019060.5340@asgard.lang.hm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2011 at 12:20 AM,  <david@lang.hm> wrote:
>
> what effect would this have on bisecting? if this helped people avoid
> bisecting in between the bad commit and the fix for it, it may be worth it.

The biggest impact on bisecting would be to just make it slower due to
extra merge commits. It's probably not a hugely noticeable thing,
though - we have merges for lots of other reasons.

Merges make bisecting a bit less efficient not only because they are
an extra commit, but because merges - by not being linear - end up
making it harder to find the "perfect" half-way point. IOW, the
bisection algorithm may not be able to pick a commit exactly midway,
because if it picks a merge it will obviously include both branches
(which may be "too much"), but if it picks the last commit of either
branch it may be too little.

And not picking a good half-way point makes bisection less efficient
(it's no longer "log2()", but maybe "log1.7()").

In practice, though, I suspect it's not really a big issue.

The other issue with bisecting merges is obviously that it can be
really nasty to figure out a bug that is introduced by the merge
itself (which is usually due to some interaction between the things
being merged, rather than any real mis-merge itself, although
mis-merges can obviously happen).

Again, that's pretty rare, although it does happen (and is often quite
"interesting" when it happens).

But in practice, I think the biggest argument against trying to fix
things as patches on top of the original bug and then merging it in is
that it's just extra work for fairly small gain. In particular:

 - not all bugs get bisected. In fact, it's the minority - most
bug-fixes are "obvious", and no-one even bothers bisecting them

 - not all bugs are as clearly the result of a single commit. Many are
a commit series. Sure, you'd just make it the last one in the series,
but it would kind of defeat the "parent introduced the bug" point of
it all.

 - putting the "commit xyz caused this problem" in the changelog (and
then just follow the chain that way) isn't really all that much worse.
The reason I talked about doing this for _merges_ is that I think
developers should think a lot more about merging, but I don't think
people need to think a lot about "let's fix this obvious bug".

 - bugfixes are often sent out as emails etc. Just applying the
bug-fix would be a _lot_ more work if it involved "create new branch
at original bug, apply, merge" than just "apply". That's especially
true for series of patches, like the ones I get from Andrew and Al.

In particular, that last thing is a killer for me personally. It
(together with the first point) would mean that it would be done only
for a very small subset of bugs, which really defeats the whole
purpose, and then makes that "merge it on top of its parent" thing be
the unusual case rather than some general rule.

And merges do end up being more complicated than plain patches. Not
just in the "extra commit" sense, but also simply in the sense of
making the history more complex.

They do have advantages too. We could just merge the same branch into
multiple branches, for example (-stable comes to mind). That said,
once more, it would really complicate things for everybody (no longer
can the stable people just apply a series of patches), so...

So on the whole, I don't think it would be worth it. I don't think
it's _wrong_, mind you, I just think that the way we work, it's more
pain than gain.

For doing a backwards merge, I think the "more pain" is a _good_ thing
(it really shouldn't _ever_ be a mindless "let's merge whatever
upstream is today" and I definitely made that mindless action too easy
to do in git). For most bug-fixes, more pain is just that - more pain.

                            Linus
