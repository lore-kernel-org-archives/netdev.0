From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 19:40:10 +0200
Message-ID: <20050518174010.GC15391@postel.suug.ch>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch> <20050518011632.GA27813@gondor.apana.org.au> <20050518013712.GH13748@postel.suug.ch> <428B6B72.5010407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <428B6B72.5010407@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Rick Jones <428B6B72.5010407@hp.com> 2005-05-18 09:21
> If we ass-u-me that the sender is indeed using a random IP ID assignment 
> mechanism, 30000 is probably too many.  There are only 65536 possible ID's, 
> and if we "choose" 30000 of them there will undoubtedly be many duplicated. 
> Someone who didn't fall asleep too often in ProbStats (unlike myself) can 
> probably tell us just how many.

I can't come up with a specific number but some thoughts, the upper
limit of the number can be described as a probability of the complete
id space := P_id_space * P_visible
...where
  P_id_space := size of effective id space, 1.0 for counters, 0.9-1.0 for
                good random schemes.
  P_visible  := how many fragments do we actually see of the effective id space,
                can be described as P_loss + P_scope
  P_loss     := probability of lost fragment-ids
  P_scope    := probability of complete view over P_visible, 1.0 if we're the
                only receiver, decreases with every additional host we share
		the sender's id space with. Also depends on the ration every
		receiver sees.

P_id_space and P_loss can be disregarded but P_scope is hard to determine,
the value can range from nearly zero to 1.0 so we can be optimistic and
chose 0.5 or be paranoid and define it as a very small value. But what is
small? F.e. 0.1 would give us a value around 6K which is nothing on a gbit
link at 40kpps on average. I think there isn't even a big difference between
3K and 30K, both border cases we're worrying about can happen with both
limits.

In a perfect world without any randomly generated ids we could measure
the absolute distance even without being aware of all ids, it might even
be possible to try and differ between random and serial id sequences
and optimize a bit there but in the end we have to find a good
compromise for the random case anyway. Worth some experimentation I guess.

> Also, I think the count has to be _any_ IP datagram on that src/dst pair, 
> fragmented or not.  Someone else pointed-out the possiblity of sending use 
> one fragmetned datagram, then 64K to someone else - well, those 64K to 
> someone else could just as easily be 64K non-fragmented IP datagrams to us, 
> so it seems for a measure of "out of orderness liklihood" we need to 
> include non-fragmented IP datagrams.

Sure, I took herbert's "fragments" as "fragment ids", i.e. the per
fragment counter being the distance of different ids between the arrival
of the fragment and the current position.
