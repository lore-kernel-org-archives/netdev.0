From: Patrick McHardy <kaber@trash.net>
Subject: Re: Qdisc requeue should be void?
Date: Tue, 17 May 2005 22:47:48 +0200
Message-ID: <428A5874.8020806@trash.net>
References: <20050513105754.2e7cc243@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jamal Hadi Salim <hadi@znyx.com>,
	lartc <lartc@mailman.ds9a.nl>
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050513105754.2e7cc243@dxpl.pdx.osdl.net>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> There is an design problem with the qdisc interface that causes qlen related bugs
> in netem, tbf, and other qdisc's that peek at the top of the queue. The problem is
> that requeue needs to be called from the dequeue function but requeue can fail.
> If requeue fails, then the calling qdisc can not properly handle the error.  If it
> returns NULL, then the parent's expectation about qlen gets messed up.
> 
> Example:
> 
> 	prio (qlen = 1)
> 		skb = netem dequeue 
> 			skb = htb dequeue 
> 			... decides not to send this skb now
> 			htp requeue(skb) fails
> 				?? what now 
> 				--netem.qlen // := 0
> 				return NULL
> 		 skb is NULL
> 
> at this point prio qlen is 1 but underlying queue's are empty.
> 
> My proposal is to require requeue to always succeed and change it to be
> void instead of returning int.

Perhaps we should add a ->peek() operation which guarantees that the
next dequeued packet is the one peeked at. This would also help with
a second problem resulting from requeueing in at least TBF and HFSC.
TBF looks at a packet and if it can't be sent immediately calculates
the delay from the packet's length. HFSC does the same to calculate
the deadline for a class. Both assume the next packet dequeued from
the underlying qdisc is the one requeued, which is only true with
non-reordering qdiscs. Adding a peek-operation increases the worst-case
delay by one maximum sized packet transmission time, but otherwise
these qdiscs can't make proper use of reordering qdiscs like SFQ
at all.

Regards
Patrick
