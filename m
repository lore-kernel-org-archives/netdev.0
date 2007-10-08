From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [DOC][NET_BATCH] Driver howto
Date: Mon, 08 Oct 2007 14:10:09 -0400
Message-ID: <1191867009.4335.21.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ym7rQkIx6PiSA3T5VZAx"
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
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


--=-Ym7rQkIx6PiSA3T5VZAx
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is an updated driver howto for batching that works with patches
from yesterday and the revised ones i am going to post.

cheers,
jamal

--=-Ym7rQkIx6PiSA3T5VZAx
Content-Disposition: attachment; filename=batch-driver-howto.txt
Content-Type: text/plain; name=batch-driver-howto.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit

Here's the beginning of a howto for driver authors.

The intended audience for this howto is people already
familiar with netdevices.

1.0  Netdevice Prerequisites
------------------------------

For hardware-based netdevices, you must have at least hardware that 
is capable of doing DMA with many descriptors; i.e., having hardware 
with a queue length of 3 (as in some fscked ethernet hardware) is 
not very useful in this case.

2.0  What is new in the driver API
-----------------------------------

There is 1 new method and one new variable introduced that the
driver author needs to be aware of. These are:
1) dev->hard_end_xmit()
2) dev->xmit_win

2.1 Using Core driver changes
-----------------------------

To provide context, let's look at a typical driver abstraction
for dev->hard_start_xmit(). It has 4 parts:
a) packet formatting (example: vlan, mss, descriptor counting, etc.)
b) chip-specific formatting
c) enqueueing the packet on a DMA ring
d) IO operations to complete packet transmit, tell DMA engine to chew 
on, tx completion interrupts, etc.

[For code cleanliness/readability sake, regardless of this work,
one should break the dev->hard_start_xmit() into those 4 functional
blocks anyways].

A driver which has all 4 parts and needing to support batching is 
advised to split its dev->hard_start_xmit() in the following manner:

1) use its dev->hard_end_xmit() method to achieve #d
2) use dev->xmit_win to tell the core how much space you have.

#b and #c can stay in ->hard_start_xmit() (or whichever way you 
want to do this)
Section 3. shows more details on the suggested usage.

2.1.1 Theory of operation
--------------------------

1. Core dequeues from qdiscs upto dev->xmit_win packets. Fragmented
and GSO packets are accounted for as well.
2. Core grabs device's TX_LOCK
3. Core loop for all skbs:
             ->invokes driver dev->hard_start_xmit()
4. Core invokes driver dev->hard_end_xmit() if packets xmitted

2.1.1.1 The slippery LLTX
-------------------------

Since these type of drivers are being phased out and they require extra
code they will not be supported anymore. So as oct07 the code that 
supports them has been removed.

2.1.1.2 xmit_win
----------------

dev->xmit_win variable is set by the driver to tell us how
much space it has in its rings/queues. This detail is then 
used to figure out how many packets are retrieved from the qdisc 
queues (in order to send to the driver). 
dev->xmit_win is introduced to ensure that when we pass the driver 
a list of packets it will swallow all of them -- which is useful 
because we don't requeue to the qdisc (and avoids burning unnecessary 
CPU cycles or introducing any strange re-ordering). 
Essentially the driver signals us how much space it has for descriptors 
by setting this variable. 

2.1.1.2.1 Setting xmit_win
--------------------------

This variable should be set during xmit path shutdown(netif_stop), 
wakeup(netif_wake) and ->hard_end_xmit(). In the case of the first
one the value is set to 1 and in the other two it is set to whatever
the driver deems to be available space on the ring.

3.0 Driver Essentials
---------------------

The typical driver tx state machine is:

----
-1-> +Core sends packets
     +--> Driver puts packet onto hardware queue
     +    if hardware queue is full, netif_stop_queue(dev)
     +
-2-> +core stops sending because of netif_stop_queue(dev)
..
.. time passes ...
..
-3-> +---> driver has transmitted packets, opens up tx path by
          invoking netif_wake_queue(dev)
-1-> +Cycle repeats and core sends more packets (step 1).
----

3.1  Driver prerequisite
--------------------------

This is _a very important_ requirement in making batching useful.
The prerequisite for batching changes is that the driver should 
provide a low threshold to open up the tx path.
Drivers such as tg3 and e1000 already do this.
Before you invoke netif_wake_queue(dev) you check if there is a
threshold of space reached to insert new packets.

Here's an example of how I added it to tun driver. Observe the
setting of dev->xmit_win.

---
+#define NETDEV_LTT 4 /* the low threshold to open up the tx path */
..
..
	u32 t = skb_queue_len(&tun->readq);
	if (netif_queue_stopped(tun->dev) && t < NETDEV_LTT) {
		tun->dev->xmit_win = tun->dev->tx_queue_len;
		netif_wake_queue(tun->dev);
	}
---

Heres how the batching e1000 driver does it:

--
if (unlikely(cleaned && netif_carrier_ok(netdev) &&
     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {

	if (netif_queue_stopped(netdev)) {
	       int rspace =  E1000_DESC_UNUSED(tx_ring) - (MAX_SKB_FRAGS +  2);
	       netdev->xmit_win = rspace;
	       netif_wake_queue(netdev);
       }
---

in tg3 code (with no batching changes) looks like:

-----
	if (netif_queue_stopped(tp->dev) &&
		(tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
			netif_wake_queue(tp->dev);
---

3.2 Driver Setup
-----------------

*) On initialization (before netdev registration)
 1) set NETIF_F_BTX in dev->features 
  i.e., dev->features |= NETIF_F_BTX
  This makes the core do proper initialization.

 2) set dev->xmit_win to something reasonable like
  maybe half the tx DMA ring size etc.

 3) create proper pointer to the ->hard_end_xmit() method.

3.3 Annotation on the different methods 
----------------------------------------
This section shows examples and offers suggestions on how the different 
methods and variable could be used.

3.3.1 dev->hard_start_xmit()
----------------------------
  
Here's an example of tx routine that is similar to the one I added 
to the current tun driver. bxmit suffix is kept so that you can turn
off batching if needed via an ethtool interface 
and call already existing interface.

----
  static int xxx_net_bxmit(struct net_device *dev)
  {
  ....
  ....
	enqueue onto hardware ring
				           
	if (hardware ring full) {
		  netif_stop_queue(dev);
		  dev->xmit_win = 1;
	}

   .......
   ..
   .
  }
------

All return codes like NETDEV_TX_OK etc. still apply.

3.3.2 The tx complete, dev->hard_end_xmit()
-------------------------------------------------
  
In this method, if there are any IO operations that apply to a 
set of packets such as kicking DMA, setting of interrupt thresholds etc.,
leave them to the end and apply them once if you have successfully enqueued. 
This provides a mechanism for saving a lot of CPU cycles since IO
is cycle expensive.
Here is a simplified tg3 dev->hard_end_xmit():

----
void tg3_complete_xmit(struct net_device *dev)
{
        /* Packets are ready, update Tx producer idx local and on card. */
        tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);

        if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
                netif_stop_queue(dev);
                dev->xmit_win = 1;
                if (tg3_tx_avail(tp) >= TG3_TX_WAKEUP_THRESH(tp)) {
                        tg3_set_win(tp);
                        netif_wake_queue(dev);
                }
        } else {
                tg3_set_win(tp);
        }

        mmiowb();
        dev->trans_start = jiffies;
}
-------

3.3.3 setting the dev->xmit_win 
---------------------------------

As mentioned earlier this variable provides hints on how much
data to send from the core to the driver. Here are the obvious ways:

a) on doing a netif_stop, set it to 1. By default all drivers have 
this value set to 1 to emulate old behavior where a driver only
receives one packet at a time.
b) on netif_wake_queue set it to the max available space. You have
to be careful if your hardware does scatter-gather since the core
will pass you scatter-gatherable skbs and so you want to at least
leave enough space for the maximum allowed. Look at the tg3 and
e1000 to see how this is implemented.

The variable is important because it avoids the core sending
any more than what the driver can handle, therefore avoiding 
any need to muck with packet scheduling mechanisms.

Appendix 1: History
-------------------
June 11/2007: Initial revision
June 11/2007: Fixed typo on e1000 netif_wake description ..
Aug  08/2007: Added info on VLAN and the skb->cb[] danger ..
Sep  24/2007: Revised and cleaned up
Sep  25/2007: Cleanups from Randy Dunlap
Oct  08/2007: Removed references to LLTX and packet formatting

--=-Ym7rQkIx6PiSA3T5VZAx
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-Ym7rQkIx6PiSA3T5VZAx--
