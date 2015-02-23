From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 14:35:14 -0800
Message-ID: <20150223223514.GB15405@linux.vnet.ibm.com>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
 <20150223210037.GA806@casper.infradead.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	kaber@trash.net, davem@davemloft.net, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	josh@joshtriplett.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51484 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbbBWWfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 17:35:19 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 23 Feb 2015 15:35:19 -0700
Content-Disposition: inline
In-Reply-To: <20150223210037.GA806@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 09:00:37PM +0000, Thomas Graf wrote:
> On 02/23/15 at 10:49am, Paul E. McKenney wrote:
> > Hello!
> > 
> > Alexei mentioned that there was some excitement a couple of weeks ago in
> > Ottawa, something about the resizing taking forever when there were large
> > numbers of concurrent additions.  One approach comes to mind:
> > 
> > o	Currently, the hash table does not allow additions concurrently
> > 	with resize operations.  One way to allow this would be to
> > 	have the addition operations add to the new hash table at the
> > 	head of the lists.  This would clearly require also updating the
> > 	pointers used to control the unzip operation.
> 
> I've already added this. Additions and removals can occur in
> parallel to the resize and will go to the head of the new chain.

Good!  (I guess I got confused by one of the comments.  Then again,
I was looking at 3.19.)

> > o	Count the number of entries added during the resize operation.
> > 	Then, at the end of the resize operation, if enough entries have
> > 	been added, do a resize, but by multiple factors of two if
> > 	need be.
> > 
> > This should allow the table to take arbitrarily large numbers of updates
> > during a resize operation.  There are some other possibilities if this
> > approach does not work out.
> 
> The main problem is rapid growth of the table on small tables,
> e.g. shift 4-6. Going through multiple grow cycles while
> thousands of entries are being added will lead to long chains
> which will require multiple RCU grace periods per growth and
> thus slowing things down.
> 
> The bucket locking is designed to ignore the highest order bit
> of the hash to make sure that a single bucket lock in the new
> double sized table protectes both buckets which map to the 
> same bucket in the old table. This simplifies locking a lot and
> does not require nested locking. Growing by more than a factor
> of two would require to manually lock all buckets to which
> entries in the old bucket may map to.

Or just ignore the (say) two upper bits if growing by (say) a factor
of four.  (If I understand what you are doing here, anyway.)

> However, we do not want to grow the bucket lock mask
> indefinitely so we could for example growth quicker if the
> lock mask allows. Needs some more thought but it's definitely
> doable and we need to provide users of the hash table with
> ways to find a balance according to their needs.

Indeed, finding the right balance can be tricky!

							Thanx, Paul
