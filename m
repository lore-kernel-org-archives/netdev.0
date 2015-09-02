From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Wed, 2 Sep 2015 09:07:24 +0200
Message-ID: <20150902070724.GD11564@pox.localdomain>
References: <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
 <20150901140341.GA13757@gondor.apana.org.au>
 <20150901141305.GA11564@pox.localdomain>
 <20150901141639.GA13856@gondor.apana.org.au>
 <20150901145124.GC11564@pox.localdomain>
 <20150902020025.GA18184@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150902020025.GA18184@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/15 at 10:00am, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 04:51:24PM +0200, Thomas Graf wrote:
> >
> > 1. The current in-kernel self-test
> > 2. bind_netlink.c: https://github.com/tgraf/rhashtable
> 
> Thanks, I will try to reproduce this.

The path in question is:

int rhashtable_insert_rehash(struct rhashtable *ht)
{
	[...]

        old_tbl = rht_dereference_rcu(ht->tbl, ht);
        tbl = rhashtable_last_table(ht, old_tbl);

        size = tbl->size;

        if (rht_grow_above_75(ht, tbl))
                size *= 2;
        /* Do not schedule more than one rehash */
        else if (old_tbl != tbl)
                return -EBUSY;

The behaviour in question is the immediate rehash during
insertion which we want to fail.

Commits:
        ccd57b1bd32460d27bbb9c599e795628a3c66983
        a87b9ebf1709687ff213091d0fdb4254b1564803
