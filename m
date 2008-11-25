From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 21:00:38 -0800 (PST)
Message-ID: <20081124.210038.90767194.davem@davemloft.net>
References: <492A7E85.3060502@cosmosbay.com>
	<20081124.153954.215777060.davem@davemloft.net>
	<492B8274.6080609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750724AbYKYFAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 00:00:39 -0500
In-Reply-To: <492B8274.6080609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 25 Nov 2008 05:43:32 +0100

> Very interesting. So we could try the following path :
> 
> 1) First try to release dst when queueing skb to various queues
> (UDP, TCP, ...) while its hot. Reader wont have to release it
> while its cold.
> 
> 2) Check if we can handle the input path without any refcount
>    dirtying ?
> 
> To make the transition easy, we could use a bit on skb to mark
> dst being not refcounted (ie no dst_release() should be done on it)

It is possible to make this self-auditing.  For example, by
using the usual trick where we encode a pointer in an
unsigned long and use the low bits for states.

In the first step, make each skb->dst access go through some
accessor inline function.

Next, audit the paths where skb->dst's can "escape" the pure
packet input path.  Add annotations, in the form of a
inline function call, for these locations.

Also, audit the other locations where we enqueue into a socket
queue and no longer care about the skb->dst, and annotate
those with another inline function.

Finally, the initial skb->dst assignment in the input path doesn't
grab a reference, but sets the low bit ("refcount pending") in
the encoded skb->dst pointer.  The skb->dst "escape" inline
function performs the deferred refcount grab.  And kfree_skb()
is taught to not dst_release() on skb->dst's which have the
low bit set.

Anyways, something like that.
