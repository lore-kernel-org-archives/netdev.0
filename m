From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/4] Revert "inet: limit length of fragment
 queue hash table bucket lists"
Date: Thu, 25 Apr 2013 15:10:38 +0200
Message-ID: <1366895438.26911.572.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154800.16883.4797.stgit@dragon>
	 <1366848030.8964.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629Ab3DYNKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 09:10:45 -0400
In-Reply-To: <1366848030.8964.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:00 -0700, Eric Dumazet wrote:
> On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> > This reverts commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055.
> > 
> > The problem with commit 5a3da1fe (inet: limit length of fragment queue
> > hash table bucket lists) is that, once we hit the hash depth limit (of
> > 128), the we *keep* the existing frag queues, not allowing new frag
> > queues to be created.  Thus, an attacker can effectivly block handling
> > of fragments for 30 sec (as each frag queue have a timeout of 30 sec)
> > 
> 
> I do not think its good to revert this patch. It was a step in right
> direction.

But in its current state I consider this patch dangerous.

> Limiting chain length to 128 is good.

Yes, its good to have a limit on the hash depth, but with current mem
limit per netns this creates an unfortunate side-effect.  There is a
disconnect between the netns mem limits and the global hash table.

Even with hash size of 1024, this just postpones the problem.
We now need 35 netns instances to reach the point where we block all
fragments for 30 sec.

Given a min frag size of 1108 bytes:
  1024*128*1108 = 145227776 
  145227776/(4*1024*1024) = 34.62500000000000000000

The reason this is inevitable, is the attackers invalid fragments will
never finish (timeout 30 sec), while valid fragments will complete and
"exit" the queue, thus the end result is hash bucket is filled with
attackers invalid/incomplete fragments.  IMHO this is a very dangerous
"feature" to support.

--Jesper
