From: josh@joshtriplett.org
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 11:12:01 -0800
Message-ID: <20150223191201.GA4355@cloud>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	tgraf@suug.ch, kaber@trash.net, davem@davemloft.net,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150223184904.GA24955@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 23, 2015 at 10:49:04AM -0800, Paul E. McKenney wrote:
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

In theory, resizes should only take the locks for the buckets they're
currently unzipping, and adds should take those same locks.  Neither one
should take a whole-table lock, other than resize excluding concurrent
resizes.  Is that still insufficient?

> o	Count the number of entries added during the resize operation.
> 	Then, at the end of the resize operation, if enough entries have
> 	been added, do a resize, but by multiple factors of two if
> 	need be.

Yeah, the add/remove statistics used for tracking would need some
special handling to avoid being a table-wide bottleneck.

- Josh Triplett
