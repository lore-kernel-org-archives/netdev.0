From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] rhashtable: Lower/upper bucket may map to same
 lock while shrinking
Date: Tue, 13 Jan 2015 15:06:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC6969@AcuExch.aculab.com>
References: <20150112232217.GA5277@wfg-t540p.sh.intel.com>
 <20150112235821.GB16617@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC6593@AcuExch.aculab.com>
 <20150113112507.GH20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>, LKP <lkp@01.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Thomas Graf' <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150113112507.GH20387@casper.infradead.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf
...
> > >  		spin_lock_bh(old_bucket_lock1);
> > > -		spin_lock_bh_nested(old_bucket_lock2, RHT_LOCK_NESTED);
> > > -		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED2);
> > > +
> > > +		/* Depending on the lock per buckets mapping, the bucket in
> > > +		 * the lower and upper region may map to the same lock.
> > > +		 */
> > > +		if (old_bucket_lock1 != old_bucket_lock2) {
> > > +			spin_lock_bh_nested(old_bucket_lock2, RHT_LOCK_NESTED);
> > > +			spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED2);
> > > +		} else {
> > > +			spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
> > > +		}
> >
> > Acquiring 3 locks of much the same type looks like a locking hierarchy
> > violation just waiting to happen.
> 
> I'm not claiming it's extremely pretty, lockless lookup with deferred
> resizing doesn't come for free ;-) If you have a suggestion on how to
> implement this differently I'm all ears.

runs away....

> That said, it's well isolated
> and the user of rhashtable does not have to deal with it. All code paths
> which take multiple locks are mutually exclusive to each other (ht->mutex).

OK, ht->mutes saves the day.
Might be worth a comment to save people looking at the code in isolation
from worrying and doing a bit search.
OTOH it might be obvious from a slightly larger fragment than the diff.

	David
