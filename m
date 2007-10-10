From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 17:04:35 -0700 (PDT)
Message-ID: <20071009.170435.43504422.davem@davemloft.net>
References: <20071009135340.33e5922c@freepuppy.rosehill>
	<20071009.142235.74385364.davem@davemloft.net>
	<1191967006.5324.14.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, jeff@garzik.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	andi@firstfloor.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	mchan@broadcom.com, jagana@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191967006.5324.14.camel@localhost>
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

From: jamal <hadi@cyberus.ca>
Date: Tue, 09 Oct 2007 17:56:46 -0400

> if the h/ware queues are full because of link pressure etc, you drop. We
> drop today when the s/ware queues are full. The driver txmit lock takes
> place of the qdisc queue lock etc. I am assuming there is still need for
> that locking. The filter/classification scheme still works as is and
> select classes which map to rings. tc still works as is etc.

I understand your suggestion.

We have to keep in mind, however, that the sw queue right now is 1000
packets.  I heavily discourage any driver author to try and use any
single TX queue of that size.  Which means that just dropping on back
pressure might not work so well.

Or it might be perfect and signal TCP to backoff, who knows! :-)

While working out this issue in my mind, it occured to me that we
can put the sw queue into the driver as well.

The idea is that the network stack, as in the pure hw queue scheme,
unconditionally always submits new packets to the driver.  Therefore
even if the hw TX queue is full, the driver can still queue to an
internal sw queue with some limit (say 1000 for ethernet, as is used
now).

When the hw TX queue gains space, the driver self-batches packets
from the sw queue to the hw queue.

It sort of obviates the need for mid-level queue batching in the
generic networking.  Compared to letting the driver self-batch,
the mid-level batching approach is pure overhead.

We seem to be sort of all mentioning similar ideas.  For example, you
can get the above kind of scheme today by using a mid-level queue
length of zero, and I believe this idea was mentioned by Stephen
Hemminger earlier.

I may experiment with this in the NIU driver.
