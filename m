From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Fri, 11 Sep 2009 22:42:54 +0100
Message-ID: <20090911214254.GB19901@shareable.org>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <1252704102.25158.36.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org, balbir@in.ibm.com
To: jamal <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756957AbZIKVnN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1252704102.25158.36.camel@dogo.mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> 1) Netlink messages wont get lost unless the listener is not keeping up
> and the kernel sending it messages ends up filling its queues. In such a
> case your event message will be delivered to the 49 other users but
> not the overloaded one. You can add sequence numbers to the event
> messages you send to the listeners and any gaps in sequences on received
> events imply lost events. You can add a mechanism to query your user
> space kernel when something like that gets lost.

One of the uses of fanotify is as a security or auditing mechanism.
That can't tolerate gaps.

It's fundemantally different from inotify in one important respect:
inotify apps can recover from losing events by checking what they are
watching.

The fanotify application will know that it missed events, but what
happens to the other application which _caused_ those events?  Does it
get to do things it shouldn't, or hide them from the fanotify app, by
simply overloading the system?  Or the opposite, does it get access
denied - spurious file errors when the system is overloaded?

There's no way to handle that by dropping events.  A transport
mechanism can be dropped (say skbs), but the event itself has to be
kept, and then retried.

Since you have to keep an event object around until it's handled,
there's no point tying it to an unreliable delivery mechanism which
you'd have to wrap a retry mechanism around.

In other words, that part of netlink is a poor match.  It would match
inotify much better.

> 2) Your architecture has to take care of maintaining the state of what
> you want to deliver. So your editing has nothing to do with skbs.
> i.e an event happens, you update your state. If you need to send the
> event to the listeners, you alloc an skb - populate it with the info;
> multicast it to all the listeners. If something else happens, i would
> suggest for sake of simplicity you rinse and repeat. Sure, the listener
> may get contradicting events - but they should be able to handle it.

Speaking of skbs, how fast and compact are they for this?

Eric's explained that it would be normal for _every_ file operation on
some systems to trigger a fanotify event and possibly wait on the
response, or at least in major directory trees on the filesystem.
Even if it's just for the fanotify app to say "oh I don't care about
that file, carry on".

File performance is one of those things which really needs to be fast
for a good user experience - and it's not unusual to grep the odd
10,000 files here or there (just think of what a kernel developer
does), or to replace a few thousand quickly (rpm/dpkg) and things like
that.

While skbs and netlink aren't that slow, I suspect they're an order of
magnitude or two slower than, say, epoll or inotify at passing events
around.

-- Jamie
