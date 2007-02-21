From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 14:19:30 +0100
Message-ID: <200702211419.30856.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <200702201209.52388.dada1@cosmosbay.com> <p73y7mrd6o9.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:56364 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161212AbXBUNTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 08:19:41 -0500
In-Reply-To: <p73y7mrd6o9.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 21 February 2007 13:41, Andi Kleen wrote:
> Eric Dumazet <dada1@cosmosbay.com> writes:
> > For example, sock_wfree() uses 1.6612 % of cpu because of false sharing
> > of sk_flags (dirtied each time SOCK_QUEUE_SHRUNK is set :(
>
> Might be easily fixable by moving the fields around a bit?

For this one, it seems sk_flags is mostly read, but SOCK_QUEUE_SHRUNK is 
mostly writen. It would make sense to move it to another point, to keep 
sk_flags shared by different cpus.

Maybe using one low order bit in a related pointer ? (like the rb_color() 
trick). Maybe this is time for a new include/linux/bap.h (bits and pointer) 
include :)

>
> > If we want to optimize tcp, we should reorder fields to reduce number of
> > cache lines, not change algos. struct sock fields are currently placed to
> > reduce holes, while they should be grouped by related fields sharing
> > cache lines.
>
> Regrouping is definitely a good thing; but I'm not sure why you are so
> deadset against exploring other data structures. The promise of RCUing
> and avoiding the big hash tables seems alluding to me, even if it
> only breaks even in the end in terms of cycles.

RCU is definitely wanted, and IP routing demonstrated the wins.

rbtree was successfully plugged into epoll instead of initial hash table 
implementation. 

Now, when the rate of lookups/inserts/delete is high, with totally random 
endpoints and cache *always* cold , 'tree structures' are not welcome (not 
cache friendly)

