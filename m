From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 11:13:50 -0800
Message-ID: <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <200702201738.19590.dada1@cosmosbay.com>
	 <20070220165907.GB24930@2ka.mipt.ru>
	 <200702201820.27095.dada1@cosmosbay.com>
	 <20070220175550.GB26961@2ka.mipt.ru>
	 <20070220181217.GA3401@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:10661 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbXBTTNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 14:13:52 -0500
Received: by an-out-0708.google.com with SMTP id b33so431469ana
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 11:13:51 -0800 (PST)
In-Reply-To: <20070220181217.GA3401@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> And here are another ones which produce the same hash value.
> Of course searching for pair for jhash('jhash is broken')
> will require more steps, but it is doable.
>
> That means that if attacker has a full control over one host, it can
> create a chain of maximum 4 entries in socket table (if jhash is used).
> If it is udp, that means that attacker control addresses too without
> syn cookies, which in turn means that below list can be increased to
> infinite.

Evgeniy, you're not gettin' it.  Have you ever heard of a Poisson
distribution?  That's what you have to aim for in a (bog-standard)
hash table -- a hash function that scrambles the key space until you
have a Poisson distribution in the hash buckets no matter whan pile of
keys the attacker throws at you.  That's a "perfect" hash function in
the statistician's sense (not a "perfect hash" function in the
compiler designer's sense).  Yes there will be collisions, and they
will start happening much earlier than you will think, if you have
never heard of Poisson distributions before; that's called the
"birthday problem" and it is a chestnut of a mathematical puzzle
generally encountered by bright twelve-year-olds in extra-curricular
math classes.  The only sensible way to deal with them is to use a
better data structure -- like a 2-left hash (Google it) or something
tree-ish.

That is not, however, what you're not getting.  What you're not
getting is the use of a "salt" or "secret" or whatever you want to
call it to turn a weak hash into an impenetrable defense against
chosen-plaintext collision attacks.  You can run your PRNG until you
slag your poor botnet's little CPUs searching for a set of tuples that
collide in the same bucket on your test system-under-attack.  But they
won't collide on mine, and they won't collide on Eric's, and they
won't collide on yours the next time it's rebooted.  Because even a
weak hash (in the cryptographer's sense) is good enough to scramble
the key space radically differently with two different salts.  XOR
doesn't cut it -- the salt will permute the buckets but not toss each
one's contents up into the air to land in a bunch of different
buckets.  But Jenkins does cut it, as discussed in the source code
Eric pointed out to you.

Of course you don't change the salt except when resizing the hash
(which is a dumb thing to do anyway, and a sure sign that a hash table
is not the right data structure).  That would kinda defeat the purpose
of having a hash table in the first place.

If you can't assimilate this and articulate it back to us in your own
words instead of repeating "any hash that doesn't totally, utterly
suck slows my meaningless artificial benchmark by 50%", you may not be
the right person to design and implement a new RCU data structure in a
kernel that thousands of us trust to withstand exposure to the open
Internet to the best of a commodity processor's ability.

Cheers,
- Michael
