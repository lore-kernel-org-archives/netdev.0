From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Sun, 12 Jun 2011 19:17:10 +0100
Message-ID: <20110612181709.GF11521@ZenIV.linux.org.uk>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
 <m1k4cy6auf.fsf@fess.ebiederm.org>
 <20110607215834.GR11521@ZenIV.linux.org.uk>
 <20110607225902.GS11521@ZenIV.linux.org.uk>
 <20110609012646.GV11521@ZenIV.linux.org.uk>
 <m1y617wmeb.fsf@fess.ebiederm.org>
 <BANLkTi=AfYH1eg_O1N2M9BfcF=UmBFPy6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47220 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab1FLSRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 14:17:15 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=AfYH1eg_O1N2M9BfcF=UmBFPy6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2011 at 10:59:42AM -0700, Linus Torvalds wrote:
> On Sun, Jun 12, 2011 at 12:15 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> >
> > I honestly hate the pattern that is being used here. ?Holding a
> > reference count because we can't be bothered to free things reliably
> > when we actually stop using them.
> 
> WHAT?
> 
> That's what a reference count *is*. It's all about "free things
> reliably when we actually stop using them".
> 
> Your comment makes zero sense.
> 
> EVERY SINGLE kernel data structure should be reference counted. Read
> Documentation/CodingStyle, or look at any of the good code in the
> kernel (ie core process or VFS code). A non-refcounted data structure
> that is used by more than one entity IS A BUG!
> 
> Quite frankly, your objection sounds moronic. If there is more than
> one user, then a reference count is _always_ the right thing. Nothing
> else ever works, and trust me, people have tried. They've tried
> locking, they've tried luck, they've tried crazy things. Nothing but
> refcounts works.

No, what the current code is trying to do is to have two kinds of references -
contributing to refcount (they do have one, all right) and non-contributing.
*AND* it attempts to hunt non-contributing ones down and replace them with
NULL when refcount hits zero.  And fscks up in dealing with the results.

What this patch does is pretty much the same thing we do for mm_struct and
superblocks - two refcounts, one controlling the shutdown of object and another
controlling the actual freeing of memory.  The second kind of references
contributes to the "memory" refcount and so does having non-zero "active"
refcount.  No games with replacing references with NULL, no races around those,
etc.

Eric's objection is that sysfs superblock would pin the memory occupied by
struct net down until it's unmounted.  Frankly, I think it's a BS -
aforementioned 2.5K are trivial to pin down *anyway*.  Just chdir deep
enough into that instance of sysfs tree and inodes/dentries you've pinned
down by that will easily eat this much.
