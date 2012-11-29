From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 9/9] net: increase frag queue hash size and
 cache-line
Date: Thu, 29 Nov 2012 21:53:51 +0100
Message-ID: <1354222431.11754.302.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161552.17754.86087.stgit@dragon>
	 <1354208113.14302.1855.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	David Laight <David.Laight@ACULAB.COM>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107Ab2K2Uza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 15:55:30 -0500
In-Reply-To: <1354208113.14302.1855.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 08:55 -0800, Eric Dumazet wrote:
> On Thu, 2012-11-29 at 17:16 +0100, Jesper Dangaard Brouer wrote:
> > Increase frag queue hash size and assure cache-line alignment to
> > avoid false sharing.  Hash size is set to 256, because I have
> > observed 206 frag queues in use at 4x10G with packet size 4416 bytes
> > (three fragments).
> > 
[...]
> >  struct inet_frag_bucket {
> >  	struct hlist_head	chain;
> >  	spinlock_t		chain_lock;
> > -};
> > +} ____cacheline_aligned_in_smp;
> >  
> 
> This is a waste of memory.

Do keep in mind this is only 16 Kbytes (256 * 64 bytes = 16384 bytes).


> Most linux powered devices dont care at all about fragments.
> 
> Just increase hashsz if you really want, and rely on hash dispersion
> to avoid false sharing.

I must agree, that it is perhaps better usage of the memory to just
increase the hashsz (and drop ____cacheline_aligned_in_smp), especially
with the measured performance gain.

> You gave no performance results for this patch anyway.

Yes, I did! -- See cover-mail patch 08 vs 09.
But the gain is really too small, to argue for this cache alignment.


Patch-08:
  2x10G size(4416)  result:(5024+4925)= 9949 Mbit/s
                 V2 result:(5140+5206)=10346 Mbit/s

  4x10G size(4416)  result:(4156+4714+4300+3985)=17155 Mbit/s
                 V2 result:(4341+4607+3963+4450)=17361 Mbit/s
                       (gen:6614+5330+7745+5366 =25055 Mbit/s)

Patch-09:
  2x10G size(4416)  result:(5421+5268)=10689 Mbit/s
                 V2 result:(5377+5336)=10713 Mbit/s

  4x10G size(4416) result:(4890+4364+4139+4530)=17923 Mbit/s
                V2 result:(3860+4533+4936+4519)=17848 Mbit/s
                      (gen:5170+6873+5215+7632 =24890 Mbit/s)
  
Improvements Patch 08 -> 09:

 2x10G size(4416):
   RunV1 (10689-9949) =740 Mbit/s
   RunV2 (10713-10346)=367 Mbit/s

 4x10G size(4416):
   RunV1 (17923-17155)=768 Mbit/s
   RunV2 (17848-17361)=487 Mbit/s

Its consistently better performance, but given magnitude the other
improvements, I don't want to argue over "wasting" 16Kbytes kernel
memory.

I have some debug patches for dumping the content of the hash, which
shows that at 4x10G size(4416) three frags, 206 frag queues, cross CPU
collisions occur anyhow.

Lets focus on the other patches instead.

--Jesper
