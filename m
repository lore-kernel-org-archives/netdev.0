From: Sage Weil <sage@newdream.net>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sun, 15 Jun 2008 09:41:44 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806150918460.3341@cobra.newdream.net>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru>
 <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru>
 <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net> <20080615055722.GA2643@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cobra.newdream.net ([66.33.216.30]:56943 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758396AbYFOQlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 12:41:45 -0400
In-Reply-To: <20080615055722.GA2643@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Jun 2008, Evgeniy Polyakov wrote:
> Yes, not only writepage, but any request - if it sends sequest and then
> receives reply (i.e. doing send/recv sequence without ability to do
> something else in between or allow other users to do sends or receives
> into the same socket), then it is synchronous. If it only sends, and
> someone else receives, it is possible to send multiple requests from
> different users who do reads or writes or lookups or whatever and
> asynchronously in different thread receive replies not in particular
> order, so this approach I call asynchronous.

Oh, so you just mean that the caller doesn't, say, hold a mutex for the 
socket for the duration of the send _and_ recv?  I'm kind of shocked that 
anyone does that, although I suppose in some cases the protocol 
effectively demands it.

> Yes, POHMELFS does writing that way.

Nice.  I will definitely be taking a look at that.

> Not exactly. Transaction in a nutshell is a wrapper on top of command
> (or multiple commands if needed like in writing), which contains all
> information needed to perform appropriate action. When user calls read()
> or 'ls' or write() or whatever, POHMELFS creates transaction for that
> operation and tries to perform it (if operation is not cached, in that
> case nothing actually happens). When transaction is submitted, it
> becomes part of the failover state machine which will check if data has
> to be read from different server or written to new one or dropped.
> original caller may not even know from which server its data will be
> received. If request sending failed in the middle, the whole transaction
> will be redirected to new one. It is also possible to redo transaction
> against different server, if server sent us error (like I'm busy), but
> this functionality was dropped in previous release iirc, this can be
> resurrected though. Having generic transaction tree callers do not
> bother about how to store theirs requests, how to wait for results and
> how to complete them - transactions do it for them. It is not rocket
> science, but extrmely effective and simple way to help rule out
> asynchronous machinery.

Got it.  Tracking pending requests in some generic way is definitely key 
to making failure handling sane with multiple servers.

> That was somewhat old approach, currently inode numbers and things like
> open-by-inode or NFS style open-by-cookie are not used. I tried to
> describe caching bits in docuementation I ent, although its a bit rough
> and likely incomplete :) Feel free to ask if there are some white areas
> there.

So what happens if the user creates a new file, and then does a stat() to 
expose i_ino.  Does that value change later?  It's not just 
open-by-inode/cookie that make ino important.  

It looks like the client/server protocol is primarily path-based. What 
happens if you do something like

hosta$ cd foo
hosta$ touch foo.txt
hostb$ mv foo bar
hosta$ rm foo.txt

Will hosta realize it really needs to do "unlink /bar/foo.txt"?

sage
