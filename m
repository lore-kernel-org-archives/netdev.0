From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 03:11:27 -0700
Message-ID: <1366366287.3205.98.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:53413 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804Ab3DSKLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 06:11:31 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so2137536pdi.7
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 03:11:30 -0700 (PDT)
In-Reply-To: <20130418213732.14296.36026.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 23:38 +0200, Jesper Dangaard Brouer wrote:
> I have found an issues with commit:
> 
>  commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
>  Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
>  Date:   Fri Mar 15 11:32:30 2013 +0000
> 
>     inet: limit length of fragment queue hash table bucket lists
> 
> There is a connection between the fixed 128 hash depth limit and the
> frag mem limit/thresh settings, which limits how high the thresh can
> be set.
> 
> The 128 elems hash depth limit, results in bad behaviour if mem limit
> thresh holds are increased, via /proc/sys/net ::
> 
>  /proc/sys/net/ipv4/ipfrag_high_thresh
>  /proc/sys/net/ipv4/ipfrag_low_thresh
> 
> If we increase the thresh, to something allowing 128 elements in each
> bucket, which is not that high given the hash array size of 64
> (64*128=8192), e.g.
>   big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
>   small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968
> 
> The problem with commit 5a3da1fe (inet: limit length of fragment queue
> hash table bucket lists) is that, once we hit the limit, the we *keep*
> the existing frag queues, not allowing new frag queues to be created.
> Thus, an attacker can effectivly block handling of fragments for 30
> sec (as each frag queue have a timeout of 30 sec).
> 
> Even without increasing the limit, as Hannes showed, an attacker on
> IPv6 can "attack" a specific hash bucket, and via that change, can
> block/drop new fragments also (trying to) utilize this bucket.
> 
> Summary:
>  With the default mem limit/thresh settings, this is not general
> problem, but adjusting the thresh limits result in some-what
> unexpected behavior.
> 
> Proposed solution:
>  IMHO instead of keeping existing frag queues, we should kill one of
> the frag queues in the hash instead.


This strategy wont really help DDOS attacks. No frag will ever complete.

I am not sure its worth adding extra complexity.

> 
> Implementation complications:
>  Killing of frag queues while only holding the hash bucket lock, and
> not the frag queue lock, complicates the implementation, as we race
> and can end up (trying to) remove the hash element twice (resulting in
> an oops). This have been addressed by using hlist_del_init() and a
> hlist_unhashed() check in fq_unlink_hash().
> 
> Extra:
> * Added new sysctl "max_hash_depth" option, to allow users to adjust the hash
>   depth along with adjusting the thresh limits.
> * Change max hash depth to 32, thus limit handling to approx 2048 frag queues.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  include/net/inet_frag.h                 |    9 +---
>  net/ipv4/inet_fragment.c                |   64 ++++++++++++++++++++-----------
>  net/ipv4/ip_fragment.c                  |   13 +++++-
>  net/ipv6/netfilter/nf_conntrack_reasm.c |    5 +-
>  net/ipv6/reassembly.c                   |   15 ++++++-
>  5 files changed, 68 insertions(+), 38 deletions(-)

Hmm... adding a new sysctl without documentation is a clear sign you'll
be the only user of it.

You are also setting a default limit of 32, more likely to hit the
problem than current 128 value.

We know the real solution is to have a correctly sized hash table, so
why adding a temporary sysctl ?

As soon as /proc/sys/net/ipv4/ipfrag_high_thresh is changed, a resize
should be attempted.

But the max depth itself should be a reasonable value, and doesn't need
to be tuned IMHO.

The 64 slots hash table was chosen years ago, when machines had 3 order
of magnitude less ram than today.

Before hash resizing, I would just bump hash size to something more
reasonable like 1024.

That would allow some admin to set /proc/sys/net/ipv4/ipfrag_high_thresh
to a quite large value.
