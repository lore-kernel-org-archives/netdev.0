From: Peter Kundrat <kundrat@kundrat.sk>
Subject: cbq parent doesnt limit child
Date: Mon, 7 Oct 2002 00:22:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021006222231.GA7763@napri.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I experienced following unexpected behavior wrt. cbq - 
if child_rate > parent_rate .. child gets its full bandwidth,
so apparently parent_rate is not respected.

In http://lartc.org/howto/lartc.qdisc.classful.html is following
comment (section 9.5.2.2):

  In short, nested classes ONLY talk to their parent qdiscs, never to an
  interface. Only the root qdisc gets dequeued by the kernel!

  The upshot of this is that classes never get dequeued faster than their
  parents allow. And this is exactly what we want: this way we can have
  SFQ in an inner class, which doesn't do any shaping, only scheduling,
  and have a shaping outer qdisc, which does the shaping.

Observed behavior doesnt correspond to that description though.

I understand that configuring child_rate > parent_rate doesnt make much
sense (except for correctness test), so that behavivor could be considered 
a feature, not a bug.  In that case, maybe only documentation/howto should 
be corrected, correct?

Thanks,

Peter

PS: For the record, its kernel 2.4.19pre7 and this setup:
  tc qdisc add dev eth0  root  handle 2: cbq bandwidth 10mbit avpkt 1000 mpu 64
  # root class
  tc class add dev eth0 parent 2:0 classid 2:1 est 1sec 8sec cbq \
   bandwidth 10mbit rate 10mbit maxburst 1 weight 10mbit prio 1 \
   allot 1514 avpkt 1000
 
  tc class add dev eth0 parent 2:1 classid 2:10 est 1sec 8sec cbq \
    bandwidth 10mbit rate 8000 maxburst 1 weight 8000 prio 1 \
    allot 1514 avpkt 1000 bounded
  tc class add dev eth0 parent 2:10 classid 2:20 est 1sec 8sec cbq \
    bandwidth 10mbit rate 16000 maxburst 1 weight 16000 prio 1 \
    allot 1514 avpkt 1000 bounded

  tc filter add dev eth0 parent 2:0 prio 59900 protocol ip u32 \
    match ip dst 10.10.10.111/32 flowid 2:20


-- 
Peter Kundrat
peter@kundrat.sk
