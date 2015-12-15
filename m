From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Tue, 15 Dec 2015 17:14:56 +0100
Message-ID: <20151215161456.GA3182@1wt.eu>
References: <877fnc7i0i.fsf@bytheb.org> <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com> <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com> <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com> <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com> <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com> <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:45143 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbbLOQPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 11:15:08 -0500
Content-Disposition: inline
In-Reply-To: <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Eric,

On Wed, Nov 11, 2015 at 05:09:01PM -0800, Eric Dumazet wrote:
> On Wed, 2015-11-11 at 10:43 -0800, Eric Dumazet wrote:
> > On Wed, 2015-11-11 at 10:23 -0800, Tom Herbert wrote:
> > 
> > > How about doing this in shutdown called for a listener?
> > 
> > Seems a good idea, I will try it, thanks !
> > 
> 
> Arg, I forgot about this shutdown() discussion we had recently
> with Oracle guys.
> 
> It is currently used in linux to unblock potential threads in accept()
> system call.
> 
> This would prevent syn_recv sockets to be finally accepted.

I had a conversation with an haproxy user who's concerned with the
connection drops during the reload operation and we stumbled upon
this thread. I was considering improving shutdown() as well for this
as haproxy already performs a shutdown(RD) during a "pause" operation
(ie: workaround for kernels missing SO_REUSEPORT).

And I found that the code clearly doesn't make this possible since
shutdown(RD) flushes the queue and stops the listening.

However I found what I consider an elegant solution which works
pretty well : by simply adding a test in compute_score(), we can
ensure that a previous socket ranks lower than the current ones,
and is never considered as long as the new ones are present. Here I
achieved this using setsockopt(SO_LINGER). The old process just has
to do this with a non-zero value on the socket it wants to put into
lingering mode and that's all.

I find this elegant since it keeps the same semantics as for a
connected socket in that it avoids killing the queue, and that it
doesn't change the behaviour for existing applications. It just
turns out that listening sockets are set up without any lingering
by default so we don't need to add any new socket options nor
anything.

Please let me know what you think about it (patch attached), if
it's accepted it's trivial to adapt haproxy to this new behaviour.

Thanks!
Willy


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-net-make-lingering-sockets-score-less-in-compute_sco.patch"

>From 7b79e362479fa7084798e6aa41da2a2045f0d6bb Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Tue, 15 Dec 2015 16:40:00 +0100
Subject: net: make lingering sockets score less in compute_score()

When multiple processes use SO_REUSEPORT for a seamless restart
operation, there's a tiny window during which both the old and the new
process are bound to the same port, and there's no way for the old
process to gracefully stop receiving connections without dropping
the few that are left in the queue between the last poll() and the
shutdown() or close() operation.

Incoming connections are distributed between multiple listening sockets
in inet_lookup_listener() according to multiple criteria. The first
criterion is a score based on a number of attributes for each socket,
then a hash computation ensures that the connections are evenly
distributed between sockets of equal weight.

This patch provides an elegant approach by which the old process can
simply decrease its score by setting the lingering time to non-zero
on its listening socket. Thus, the sockets from the new process
(which start without any lingering) always score higher and are always
preferred.

The old process can then safely drain incoming connections and stop
after meeting the -1 EAGAIN condition, as shown in the example below :

         process A (old one)    |  process B (new one)
                                |
          listen() >= 0         |
          ...                   |
          accept()              |
          ...                   |
          ...                   |  listen()

       From now on, both processes receive incoming connections

          ...                   |  kill(process A, go_away)
          setsockopt(SO_LINGER) |  accept() >= 0

       Here process A stops receiving new connections

          accept() >= 0         |  accept() >= 0
          ...                   |
          accept() = -1 EAGAIN  |  accept() >= 0
          close()               |
          exit()                |

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 net/ipv4/inet_hashtables.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index c6fb80b..473b16f 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -191,6 +191,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			score += 4;
 		}
 	}
+	if (!sock_flag(sk, SOCK_LINGER))
+		score++;
 	return score;
 }
 
-- 
1.7.12.1


--PNTmBPCT7hxwcZjr--
