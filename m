From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 13:56:58 +0100
Message-ID: <20090916125658.GF29359@shareable.org>
References: <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain> <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com> <20090916075219.GA22024@shareable.org> <20090916114111.2228f0fc@linux.intel.com> <20090916114107.GB29359@shareable.org> <20090916130127.439c9222@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@linux.intel.com>, Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:32784 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbZIPM5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 08:57:08 -0400
Content-Disposition: inline
In-Reply-To: <20090916130127.439c9222@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
> > You can't rely on the name being non-racy, but you _can_ reliably
> > invalidate application-level caches from the sequence of events
> > including file writes, creates, renames, links, unlinks, mounts.  And
> > revalidate such caches by the absence of pending events.
> 
> You can't however create the caches reliably because you've no idea if
> you are referencing the right object in the first place - which is why
> you want a handle in these cases. I see fanotify as a handle producing
> addition to inotify, not as a replacement (plus some other bits around
> open blocking for HSM etc)

There are two sets of events getting mixed up here.  Inode events -
reads, writes, truncates, chmods; and directory events - renames,
links, creates, unlinks.

Inode events alone _not enough_ to maintain caches, and here's why.

With a file descriptor for an _inode_ event, that's fine.  If you have
{ int fd1 = open("/foo/bar"), fd2 = open("/foo/baz"); } early in your
program, and later cached_file_read(fd1) and cached_file_read(fd2),
you have to recognise the inode number and invalidate both.

You have to call fstat() on the event's descriptor and then look up a
device+inode number in your own table.  (The inotify way doesn't need
the fstat() but is otherwise the same).

That's fine for files you're keeping open and only want to know if the
content changes _of an open file_.

But that's not so useful.

More often, you want to validate cached_file_read("/foo/bar").  That
is, validate what you'd get if you opened that path _now_ and read it.
Same for cached_stat("/foo/bar") to cache permissions, and other
things like that.

That needs to validate the path lookup _and_ the inode state.

For that, we need directory events, and they must include the name in
the directory that's affected.  If you receive a directory event
involving name "bar" in directory (identified by inode) "/foo", you
invalidate cached_file_read("/foo/bar") and cached_stat("/foo/bar").

Oh, but wait, how do we know the inode for the directory in our event
still refers to "/foo"?  Answer: We're also watching it's parent
directory "/".  Assuming no reordering of certain events, that's ok.

That way, by watching "/", "/foo" and "/foo/bar", when you receive no
events you validate the results of cached_file_read("/foo/bar") and
cached_stat("/foo/bar").  A lot to set up, but fast to check.  Worth
it if you're checking a lot of things that rarely change.

If you receive inode events while watching the parent directory of the
path used to access the inode, then you can avoid watching "/foo/bar",
and just watch the path of parent directories.  That saves an order of
magnitude of watches typically.  fanotify offers something similar,
and in this case the event is probably more useful than inotify's.

(The above is even hard-link-safe, if you do it right.  I won't
complicate the explanation with details).

-- Jamie
