From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 16:30:53 +0100
Message-ID: <20160324153053.GA7569@1wt.eu>
References: <20151218185812.GD4448@1wt.eu>
 <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151219070009.GA4634@1wt.eu>
 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
 <20151221204127.GC8018@1wt.eu>
 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
 <20160324061222.GA6807@1wt.eu>
 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324142222.GB7237@1wt.eu>
 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32102 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbcCXPbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 11:31:07 -0400
Content-Disposition: inline
In-Reply-To: <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Eric,

(just lost my e-mail, trying not to forget some points)

On Thu, Mar 24, 2016 at 07:45:44AM -0700, Eric Dumazet wrote:
> On Thu, 2016-03-24 at 15:22 +0100, Willy Tarreau wrote:
> > Hi Eric,
> 
> > But that means that any software making use of SO_REUSEPORT needs to
> > also implement BPF on Linux to achieve the same as what it does on
> > other OSes ? Also I found a case where a dying process would still
> > cause trouble in the accept queue, maybe it's not redistributed, I
> > don't remember, all I remember is that my traffic stopped after a
> > segfault of only one of them :-/ I'll have to dig a bit regarding
> > this.
> 
> Hi Willy
> 
> Problem is : If we add a SO_REUSEPORT_LISTEN_OFF, this wont work with
> BPF. 

I wasn't for adding SO_REUSEPORT_LISTEN_OFF either. Instead the idea was
just to modify the score in compute_score() so that a socket which disables
SO_REUSEPORT scores less than one which still has it. The application
wishing to terminate just has to clear the SO_REUSEPORT flag and wait for
accept() reporting EAGAIN. The patch simply looked like this (copy-pasted
hence space-mangled) :

--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -189,6 +189,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
                                return -1;
                        score += 4;
                }
+               if (sk->sk_reuseport)
+                       score++;
                if (sk->sk_incoming_cpu == raw_smp_processor_id())
                        score++;
        }

> BPF makes a decision without knowing individual listeners states.

But is the decision taken without considering compute_score() ? The point
really was to be the least possibly intrusive and quite logical for the
application : "disable SO_REUSEPORT when you don't want to participate to
incoming load balancing anymore".

> Or we would need to extend BPF to access these kind of states.
> Doable certainly, but we need to be convinced it is necessary.

You know that I don't like complex designs to address simple issues if
possible :-)

> And yes, if a listener is closed while children are still in accept
> queue, we drop all the children, we do not care of redistributing them
> to another listeners. Really too complex to be worth it.

Forget this, I mixed two issues here. Yes I know that redistributing is
almost impossible, I've read that code a year ago or so and realized how
complex this would be, without providing even 100% success rate. I wasn't
speaking about redistribution of incoming queue but about an issue I've
met where when I have 4 processes bound to the same port, if one dies,
its share of incoming traffic is definitely lost. The only fix was to
restart the processes to create new listeners. But I don't remember the
conditions where I met this case, I don't even remember if it was on an
-rc kernel or a final one, so I'd prefer to discuss this only once I have
more elements.

Cheers,
Willy

--qMm9M+Fa2AknHoGS
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


--qMm9M+Fa2AknHoGS--
