From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Wed, 16 Dec 2015 17:15:14 +0100
Message-ID: <20151216161514.GA3476@1wt.eu>
References: <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com> <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com> <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com> <20151215161456.GA3182@1wt.eu> <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com> <20151215174346.GA3187@1wt.eu> <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com> <20151215194410.GB3187@1wt.eu> <1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com> <20151216073814.GA3373@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:50243 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbbLPQPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 11:15:30 -0500
Content-Disposition: inline
In-Reply-To: <20151216073814.GA3373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Eric,

On Wed, Dec 16, 2015 at 08:38:14AM +0100, Willy Tarreau wrote:
> On Tue, Dec 15, 2015 at 01:21:15PM -0800, Eric Dumazet wrote:
> > On Tue, 2015-12-15 at 20:44 +0100, Willy Tarreau wrote:
> > 
> > > Thus do you think it's worth adding a new option as Tolga proposed ?
> > 
> > 
> > I thought we tried hard to avoid adding the option but determined
> > we could not avoid it ;)
> 
> Not yet, your other proposal of disabling SO_REUSEPORT makes sense if
> we combine it with the proposal to change the score in my patch. If
> we say that a socket which has SO_REUSEPORT scores higher, then the
> connections which don't want to accept new connections anymore will
> simply have to drop it an not be elected. I find this even cleaner
> since the sole purpose of the loop is to find the best socket in case
> of SO_REUSEPORT.

So I tried this and am pretty satisfied with the results, as I couldn't
see any single reset on 4.4-rc5 with it. On 4.1 I got a few very rare
resets at the exact moment the new process binds to the socket, because
I suspect some ACKs end up in the wrong queue exactly there. But
apparently the changes you did in 4.4 totally got rid of this, which is
great!

I suspected that I could enter a situation where a new process could
fail to bind if generations n-1 and n-2 were still present, because
n-2 would be running without SO_REUSEPORT and that should make this
test fail in inet_csk_bind_conflict(), but it never failed for me :

                        if ((!reuse || !sk2->sk_reuse ||
                            sk2->sk_state == TCP_LISTEN) &&
                            (!reuseport || !sk2->sk_reuseport ||
                            (sk2->sk_state != TCP_TIME_WAIT &&
                             !uid_eq(uid, sock_i_uid(sk2))))) {
...

So I'm clearly missing something and can't spot what. I mean, I'd
prefer to see my patch occasionally fail than not understanding why
it always works! If anyone has an suggestion I'm interested.

Here's the updated patch.

Best regards,
Willy


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-net-make-lingering-sockets-score-less-in-compute_sco.patch"

>From c060a5db92274402a0178d7c777a1e37c15eadb9 Mon Sep 17 00:00:00 2001
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

This patch provides a simple approach by which the old process can
simply decrease its score by disabling SO_REUSEPORT on its listening
sockets. Thus, the sockets from the new process always score higher
and are always preferred.

The old process can then safely drain incoming connections and stop
after meeting the -1 EAGAIN condition, as shown in the example below :

         process A (old one)          |  process B (new one)
                                      |
          setsockopt(SO_REUSEPORT, 1) |
          listen() >= 0               |
          ...                         |
          accept()                    |
          ...                         |  setsockopt(SO_REUSEPORT, 1)
          ...                         |  listen()

       From now on, both processes receive incoming connections

          ...                         |  kill(process A, go_away)
          setsockopt(SO_REUSEPORT, 0) |  accept() >= 0

       Here process A stops receiving new connections

          accept() >= 0               |  accept() >= 0
          ...                         |
          accept() = -1 EAGAIN        |  accept() >= 0
          close()                     |
          exit()                      |

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 net/ipv4/inet_hashtables.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980..1c950ba 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -189,6 +189,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
+		if (sk->sk_reuseport)
+			score++;
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
-- 
1.7.12.1


--pf9I7BMVVzbSWLtt--
