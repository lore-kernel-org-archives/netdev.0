From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 22:14:30 -0400
Message-ID: <1191896071.4373.156.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
	<1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, jeff@garzik.org,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, gaagaan@gmail.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071008.184126.124062865.davem@davemloft.net>
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

On Mon, 2007-08-10 at 18:41 -0700, David Miller wrote:

> I also want to point out another issue.  Any argument wrt. reordering
> is specious at best because right now reordering from qdisc to device
> happens anyways.
>
> And that's because we drop the qdisc lock first, then we grab the
> transmit lock on the device and submit the packet.  So, after we
> drop the qdisc lock, another cpu can get the qdisc lock, get the
> next packet (perhaps a lower priority one) and then sneak in to
> get the device transmit lock before the first thread can, and
> thus the packets will be submitted out of order.
> 

You forgot QDISC_RUNNING Dave;-> the above cant happen. 
Essentially at any one point in time, we are guaranteed that we can have
multiple cpus enqueueing but only can be dequeueing (the one that
managed to grab QDISC_RUNNING) i.e multiple producers to the qdisc queue
but only one consumer. Only the dequeuer has access to the txlock.
 
> This, along with other things, makes me believe that ordering really
> doesn't matter in practice.  And therefore, in practice, we can treat
> everything from the qdisc to the real hardware as a FIFO even if
> something else is going on inside the black box which might reorder
> packets on the wire.

I think it is important to get the scheduling right - estimations can be
a last resort. For example, If i have voip competing for the wire with
ftp on two different rings/cpus and i specified that voip should be more
important i may consider equipment faulty if it works "most of the
time" (when ftp is not clogging the wire) and at times i am asked to
repeat what i just said. 

cheers,
jamal
