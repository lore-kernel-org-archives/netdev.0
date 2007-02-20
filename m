From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 19:59:07 +0300
Message-ID: <20070220165907.GB24930@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201708.12858.dada1@cosmosbay.com> <20070220162040.GA8194@2ka.mipt.ru> <200702201738.19590.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49119 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030291AbXBTRB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 12:01:58 -0500
Content-Disposition: inline
In-Reply-To: <200702201738.19590.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 05:38:19PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > It is secrecy, not security - attacker will check the source and find
> > where constant per-boot value is added and recalculate attack vector -
> > we all were college students, it would be even more fun to crack.
> >
> > In that regard Jenkins ahsh and XOR one have _exactly_ the same attack
> > vector, only Jenkins is a bit more sophisticated. I even think that
> > example in rt_hash_code() will endup with heavy problems when one of the
> > addresses is constant - my tests show problem exactly in the case of
> > jhash_2words() with random third parameter and constant one of the first
> > like in rt_hash_code().
> 
> Please define heavy problem.
> 
> On most hosts, with one NIC, one IP address, most entries in cache have the 
> same address (IP address of eth0 or localhost). It just works.
> 
> Last time I checked, the 2^21 route cache I am using was correctly filled, 
> thanks to jhash.
> 
> Again, the random value is 32bits. If jhash happens to be cracked by your 
> students, we just put md5 or whatever in...
>
> You can call it secrecy or whatever, fact is : it's just working, far better 
> than XOR previous hash function.

Hmm, I've just ran following test:
1. created 2^20 hash table.
2. ran in loop (100*(2^20) iterations) following hashes:
 a. xor hash (const_ip, const_ip, random_word)
 b. jhash_3words(const_ip, const_ip, random_word, 123123) - it is
	 exactly as jhash_2words(const_ip, const_ip, wandom_word)
3. hash &= hash_size - 1;
4. table[hash].counter++;
5. 	for (i=0; i<hash_size; ++i)
		results[table[i].counter]++;

And got pretty artefact for jenkins hash attached in the picture
artefact.png. Distribution.png file contains distribution of the 2^10
hash table for 100*(2^10) for the above scenario.

I've attached source code and running script.
$ ./run.sh

will produce gnuplot window with shown artefact.

If one change comments at the end of the file, run.sh will produce
distribution graphs.

P.S. jenkins hash is about two times slower.

-- 
	Evgeniy Polyakov
