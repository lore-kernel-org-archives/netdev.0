From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 21:00:37 +0000
Message-ID: <20150223210037.GA806@casper.infradead.org>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	kaber@trash.net, davem@davemloft.net, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	josh@joshtriplett.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150223184904.GA24955@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/23/15 at 10:49am, Paul E. McKenney wrote:
> Hello!
> 
> Alexei mentioned that there was some excitement a couple of weeks ago in
> Ottawa, something about the resizing taking forever when there were large
> numbers of concurrent additions.  One approach comes to mind:
> 
> o	Currently, the hash table does not allow additions concurrently
> 	with resize operations.  One way to allow this would be to
> 	have the addition operations add to the new hash table at the
> 	head of the lists.  This would clearly require also updating the
> 	pointers used to control the unzip operation.

I've already added this. Additions and removals can occur in
parallel to the resize and will go to the head of the new chain.

> o	Count the number of entries added during the resize operation.
> 	Then, at the end of the resize operation, if enough entries have
> 	been added, do a resize, but by multiple factors of two if
> 	need be.
> 
> This should allow the table to take arbitrarily large numbers of updates
> during a resize operation.  There are some other possibilities if this
> approach does not work out.

The main problem is rapid growth of the table on small tables,
e.g. shift 4-6. Going through multiple grow cycles while
thousands of entries are being added will lead to long chains
which will require multiple RCU grace periods per growth and
thus slowing things down.

The bucket locking is designed to ignore the highest order bit
of the hash to make sure that a single bucket lock in the new
double sized table protectes both buckets which map to the 
same bucket in the old table. This simplifies locking a lot and
does not require nested locking. Growing by more than a factor
of two would require to manually lock all buckets to which
entries in the old bucket may map to.

However, we do not want to grow the bucket lock mask
indefinitely so we could for example growth quicker if the
lock mask allows. Needs some more thought but it's definitely
doable and we need to provide users of the hash table with
ways to find a balance according to their needs.
