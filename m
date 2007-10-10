From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 17:50:25 -0700 (PDT)
Message-ID: <20071009.175025.59469417.davem@davemloft.net>
References: <1191967006.5324.14.camel@localhost>
	<20071009.170435.43504422.davem@davemloft.net>
	<20071010003716.GB552@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, jagana@us.ibm.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: andi@firstfloor.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071010003716.GB552@one.firstfloor.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 10 Oct 2007 02:37:16 +0200

> On Tue, Oct 09, 2007 at 05:04:35PM -0700, David Miller wrote:
> > We have to keep in mind, however, that the sw queue right now is 1000
> > packets.  I heavily discourage any driver author to try and use any
> > single TX queue of that size.  
> 
> Why would you discourage them? 
> 
> If 1000 is ok for a software queue why would it not be ok
> for a hardware queue?

Because with the software queue, you aren't accessing 1000 slots
shared with the hardware device which does shared-ownership
transactions on those L2 cache lines with the cpu.

Long ago I did a test on gigabit on a cpu with only 256K of
L2 cache.  Using a smaller TX queue make things go faster,
and it's exactly because of these L2 cache effects.

> 1000 packets is a lot. I don't have hard data, but gut feeling 
> is less would also do.

I'll try to see how backlogged my 10Gb tests get when a strong
sender is sending to a weak receiver.

> And if the hw queues are not enough a better scheme might be to
> just manage this in the sockets in sendmsg. e.g. provide a wait queue that
> drivers can wake up and let them block on more queue.

TCP does this already, but it operates in a lossy manner.

> I don't really see the advantage over the qdisc in that scheme.
> It's certainly not simpler and probably more code and would likely
> also not require less locks (e.g. a currently lockless driver
> would need a new lock for its sw queue). Also it is unclear to me
> it would be really any faster.

You still need a lock to guard hw TX enqueue from hw TX reclaim.

A 256 entry TX hw queue fills up trivially on 1GB and 10GB, but if you
increase the size much more performance starts to go down due to L2
cache thrashing.
