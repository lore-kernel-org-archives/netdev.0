From: Stephen Hemminger <shemminger@osdl.org>
Subject: Qdisc requeue should be void?
Date: Fri, 13 May 2005 10:57:54 -0700
Message-ID: <20050513105754.2e7cc243@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc <lartc@mailman.ds9a.nl>
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Jamal Hadi Salim <hadi@znyx.com>,
	Patrick McHardy <kaber@trash.net>
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

There is an design problem with the qdisc interface that causes qlen related bugs
in netem, tbf, and other qdisc's that peek at the top of the queue. The problem is
that requeue needs to be called from the dequeue function but requeue can fail.
If requeue fails, then the calling qdisc can not properly handle the error.  If it
returns NULL, then the parent's expectation about qlen gets messed up.

Example:

	prio (qlen = 1)
		skb = netem dequeue 
			skb = htb dequeue 
			... decides not to send this skb now
			htp requeue(skb) fails
				?? what now 
				--netem.qlen // := 0
				return NULL
		 skb is NULL

at this point prio qlen is 1 but underlying queue's are empty.

My proposal is to require requeue to always succeed and change it to be
void instead of returning int.
			
			
