From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Wed, 19 Nov 2014 21:17:13 +0000
Message-ID: <20141119211712.GD7996@ZenIV.linux.org.uk>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
 <CA+55aFxK0wj2LLp0WmhRsBZch8XfoYbzmbEeJaMpt=SDh5GBvw@mail.gmail.com>
 <20141118212307.GU7996@ZenIV.linux.org.uk>
 <20141119.153136.867017618826698045.davem@davemloft.net>
 <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2014 at 12:40:53PM -0800, Linus Torvalds wrote:
> On Wed, Nov 19, 2014 at 12:31 PM, David Miller <davem@davemloft.net> wrote:
> >
> > But that is just my opinion, and yes I do acknowledge that we've had
> > serious holes in this area in the past.
> 
> The serious holes have generally been exactly in the "upper layers
> already check" camp, and then it turns out that some odd ioctl or
> other thing ends up doing something odd and interesting.
> 
> If Al has actual performance profiles showing that the access_ok() is
> a real problem, then fine. As a low-level optimization, I agree with
> it. But not as a "let's just drop them, and make the security rules be
> non-local and subtle, and require people to know the details of the
> whole call-chain".
> 
> Seeing a "__get_user()" and just being able to glance up in the same
> function and seeing the "access_ok()" is just a good safety net. And
> means that people don't have to waste time thinking about or looking
> for where the hell the security net really is.

Umm...  It's not quite that bad - the thing is, for iov_iter-net series
we'll need copy_and_csum_{to,from}_iter() anyway and for iovec-backed
iov_iter instances we already ask the iovec to be validated wrt access_ok().
And this validation (already done by rw_copy_check_uvector()) is going to
be next to iov_iter_init() setting the iov_iter up.

Moreover, I'm planning to take iov_iter_init() into rw_copy_check_uvector().
That way setting ->iov is done from the same function that has just checked
all ranges.  If you look at the callers, you'll see that almost all of them
are directly followed by iov_iter_init() and folding it in is a fairly
obvious cleanup.

The thing is, with ..._iter() variants added we are left with no other
in-tree callers of csum_and_copy_{to,from}_user().  I agree that dropping
those access_ok() is too early at this point - the analysis of paths
by which a range can reach them is scary right now.  Moreover, it mostly
parallels the changes later in the series - ones that propagate a pointer
to iov_iter put into msdghdr in place of ->msg_iov/->msg_iovlen down to
the new primitives.  _After_ those steps the analysis (see the horrors in
commit message of 3/5) becomes trivial.

So whether we end up removing those access_ok() or not, this is not the
time to do so.  It still might make sense in the end, but not right now.

Frankly, my preference would be to provide __csum_and_copy_...() that do
not bother with access_ok() (and do so consistently between the architectures),
and do not bother with zeroing or trying to do an accurate csum in case of
error.  With uniform implementation of csum_and_copy_...() that does
access_ok(), tries to call __csum_... variant and, in case of failure,
does __copy_..._user(), zeroes the tail in the "from" one and calculates
the csum by source of destination - whichever's kernel-side.  I.e. do what
ppc64 is doing.  That way we get obviously safe csum_and_copy_.._user(),
and consistent __ counterparts directly used by ..._iter() primitives.
Quite a bit of complexity becomes possible to remove from asm code,
while we are at it - zeroing isn't the worst of it, contortions needed to
calculate the csum accurately in error case are often nastier.  So much
that e.g. arm doesn't even bother trying.

Again, this is a separate work - I agree with you regarding the overhead
being a non-issue for existing callers, and if somebody tries e.g. to send
64K from 32K-element vector of 2-byte ranges they'll have a _lot_ of other
overhead that will drown that of those access_ok().  In normal cases the
price of copying the data itself is going to swamp that of access_ok(),
of course.

IOW, consider the access_ok() changes withdrawn for now.  It's too early
in the series for them and the only reason to pull them that high in
ordering had been the fear of overhead.  Which is very unlikely to be
an issue.  They won't come back (if they come back at all) until the
proof of correctness becomes absolutely trivial.
