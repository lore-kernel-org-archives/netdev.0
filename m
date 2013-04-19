From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 14:19:10 +0200
Message-ID: <1366373950.26911.134.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968309Ab3DSMTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 08:19:17 -0400
In-Reply-To: <1366366287.3205.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 03:11 -0700, Eric Dumazet wrote:
> On Thu, 2013-04-18 at 23:38 +0200, Jesper Dangaard Brouer wrote:
> > I have found an issues with commit:
> > 
> >  commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
> >  Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >  Date:   Fri Mar 15 11:32:30 2013 +0000
> > 
> >     inet: limit length of fragment queue hash table bucket lists
> > 
> > There is a connection between the fixed 128 hash depth limit and the
> > frag mem limit/thresh settings, which limits how high the thresh can
> > be set.
> > 
> > The 128 elems hash depth limit, results in bad behaviour if mem limit
> > thresh holds are increased, via /proc/sys/net ::
> > 
> >  /proc/sys/net/ipv4/ipfrag_high_thresh
> >  /proc/sys/net/ipv4/ipfrag_low_thresh
> > 
> > If we increase the thresh, to something allowing 128 elements in each
> > bucket, which is not that high given the hash array size of 64
> > (64*128=8192), e.g.
> >   big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
> >   small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968
> > 
> > The problem with commit 5a3da1fe (inet: limit length of fragment queue
> > hash table bucket lists) is that, once we hit the limit, the we *keep*
> > the existing frag queues, not allowing new frag queues to be created.
> > Thus, an attacker can effectivly block handling of fragments for 30
> > sec (as each frag queue have a timeout of 30 sec).
> > 
> > Even without increasing the limit, as Hannes showed, an attacker on
> > IPv6 can "attack" a specific hash bucket, and via that change, can
> > block/drop new fragments also (trying to) utilize this bucket.
> > 
> > Summary:
> >  With the default mem limit/thresh settings, this is not general
> > problem, but adjusting the thresh limits result in some-what
> > unexpected behavior.
> > 
> > Proposed solution:
> >  IMHO instead of keeping existing frag queues, we should kill one of
> > the frag queues in the hash instead.
> 
> 
> This strategy wont really help DDOS attacks. No frag will ever complete.

I beg to differ.

First if all, I also though keeping fragments were the right choice, BUT
then I realized that we cannot tell god-from-bad frags apart, and an
attacker will obviously generate more fragments than the real traffic,
thus we end up keeping the attackers fragment for 30 sec. Because the
attacker will never "finish/complete" his fragment queues.
Thus, the real "help" for a DoS attack is to keep fragments.


Second, I have clearly shown, with my performance tests, that frags will
complete under DoS.  

Consider argument for frags will be able to complete:

 For an attacker to "push-out" the real-fragments she will have to
generate enough packets to fill the entire hash queue (to be sure) which
is 64 * 32 = 2048 elements, thus generate (some were below) 2048
packets, in the same period the real-fragment sender only needs to send
3 packets (my DNSSEC use case).
That is the reason it works, do you buy that explanation?


> I am not sure its worth adding extra complexity.

It's not that complex, and we simply need it, else an attacker can DoS
us very easily by sending a burst every 30 sec.  We do need this change,
else we must revert Hannes patch, and find a complete other approach of
removing the LRU list system.



> > Implementation complications:
> >  Killing of frag queues while only holding the hash bucket lock, and
> > not the frag queue lock, complicates the implementation, as we race
> > and can end up (trying to) remove the hash element twice (resulting in
> > an oops). This have been addressed by using hlist_del_init() and a
> > hlist_unhashed() check in fq_unlink_hash().
> > 
> > Extra:
> > * Added new sysctl "max_hash_depth" option, to allow users to adjust the hash
> >   depth along with adjusting the thresh limits.
> > * Change max hash depth to 32, thus limit handling to approx 2048 frag queues.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> > 
> >  include/net/inet_frag.h                 |    9 +---
> >  net/ipv4/inet_fragment.c                |   64 ++++++++++++++++++++-----------
> >  net/ipv4/ip_fragment.c                  |   13 +++++-
> >  net/ipv6/netfilter/nf_conntrack_reasm.c |    5 +-
> >  net/ipv6/reassembly.c                   |   15 ++++++-
> >  5 files changed, 68 insertions(+), 38 deletions(-)
> 
> Hmm... adding a new sysctl without documentation is a clear sign you'll
> be the only user of it.

LOL - I know, my next patch contains a note that I need to update the
docs too...


> You are also setting a default limit of 32, more likely to hit the
> problem than current 128 value.
> 
> We know the real solution is to have a correctly sized hash table, so
> why adding a temporary sysctl ?

No, the real solution is to remove LRU list system (that is the real
bottleneck).  But this patch (and the next) is a step needed before we
can remove the LRU list cleanup system.


> As soon as /proc/sys/net/ipv4/ipfrag_high_thresh is changed, a resize
> should be attempted.

Perhaps, but the ipfrag_high_thresh memory size does not translate
easily to number of needed frag queues (hash_size * max_depth).  Because
the size of a frag queue can range from 1108 bytes to approx 130.000
bytes.


> But the max depth itself should be a reasonable value, and doesn't need
> to be tuned IMHO.

What is a reasonable max depth value for you?



> The 64 slots hash table was chosen years ago, when machines had 3 order
> of magnitude less ram than today.
> 
> Before hash resizing, I would just bump hash size to something more
> reasonable like 1024.
> 
> That would allow some admin to set /proc/sys/net/ipv4/ipfrag_high_thresh
> to a quite large value.

When removing the LRU system (which is the real bottleneck, see perf
tests in cover mail), and doing direct hash cleaning we are trading-in
accuracy.

The reason I don't want a too big hash table is the following.

With direct has cleaning, and even using the mem limit
(ipfrag_high_thresh) in the cleaning loop/selection (see patch-02) we
should at least allow one frag queue to survive (in a hash bucket).
This means that we can violate/exceed the ipfrag_high_thresh a lot (due
to size of a frag queue can range from 1108 bytes to approx 130.000
bytes).
Worst case 1024 buckets * 130K bytes = 133 MBytes, which on smaller
embedded systems is a lot of kernel memory we are permitting a remote
host to "lock-down".


--Jesper
