From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Thu, 29 Nov 2012 12:44:27 -0500 (EST)
Message-ID: <20121129.124427.1093031685966728935.davem@davemloft.net>
References: <20121129161019.17754.29670.stgit@dragon>
	<20121129161052.17754.85017.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749Ab2K2Roa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:44:30 -0500
In-Reply-To: <20121129161052.17754.85017.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 29 Nov 2012 17:11:09 +0100

> The fragmentation evictor system have a very unfortunate eviction
> system for killing fragment, when the system is put under pressure.
> If packets are coming in too fast, the evictor code kills "warm"
> fragments too quickly.  Resulting in a massive performance drop,
> because we drop frag lists where we have already queue up a lot of
> fragments/work, which gets killed before they have a chance to
> complete.

I think this is a trade-off where the decision is somewhat
arbitrary.

If you kill warm entries, the sending of all of the fragments is
wasted.  If you retain warm entries and drop incoming new fragments,
well then the sending of all of those newer fragments is wasted too.

The only way I could see this making sense is if some "probability
of fulfillment" was taken into account.  For example, if you have
more than half of the fragments already, then yes it may be
advisable to retain the warm entry.

Otherwise, as I said, the decision seems arbitrary.

Let's take a step back and think about why this is happening at all.

I wonder how reasonable the high and low thresholds really are.  Even
once you move them to per-cpu, I think the limits are far too small.

I'm under the impression that it's common for skb->truesize for 1500
MTU frames to be something rounded up to the next power of 2, so
2048 bytes, or something like that.  Then add in the sk_buff control
overhead, as well as the inet_frag head.

So a 64K fragmented frame probably consumes close to 100K.

So once we have three 64K frames in flight, we're already over the
high threshold and will start dropping things.

That's beyond stupid.
