From: jamal <hadi@cyberus.ca>
Subject: [DOC] Net batching driver howto
Date: Mon, 24 Sep 2007 18:54:19 -0400
Message-ID: <1190674459.4264.28.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>
	 <46F6AE18.7080708@garzik.org>  <1190574713.5030.4.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-L9ekskkCxVFlmXlKWjqO"
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:42879 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960AbXIXWy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 18:54:26 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1340508wxd
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2007 15:54:25 -0700 (PDT)
In-Reply-To: <1190574713.5030.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-L9ekskkCxVFlmXlKWjqO
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I have updated the driver howto to match the patches i posted yesterday.
attached. 

cheers,
jamal

--=-L9ekskkCxVFlmXlKWjqO
Content-Disposition: attachment; filename=batch-driver-howto.txt
Content-Type: text/plain; name=batch-driver-howto.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit

Heres the begining of a howto for driver authors.

The intended audience for this howto is people already
familiar with netdevices.

1.0  Netdevice Pre-requisites
------------------------------

For hardware based netdevices, you must have at least hardware that 
is capable of doing DMA with many descriptors; i.e having hardware 
with a queue length of 3 (as in some fscked ethernet hardware) is 
not very useful in this case.

2.0  What is new in the driver API
-----------------------------------

There are 3 new methods and one new variable introduced. These are:
1)dev->hard_prep_xmit()
2)dev->hard_end_xmit()
3)dev->hard_batch_xmit()
4)dev->xmit_win

2.1 Using Core driver changes
-----------------------------

To provide context, lets look at a typical driver abstraction
for dev->hard_start_xmit(). It has 4 parts:
a) packet formating (example vlan, mss, descriptor counting etc)
b) chip specific formatting
c) enqueueing the packet on a DMA ring
d) IO operations to complete packet transmit, tell DMA engine to chew 
on, tx completion interupts etc

[For code cleanliness/readability sake, regardless of this work,
one should break the dev->hard_start_xmit() into those 4 functions
anyways].
A driver which has all 4 parts and needing to support batching is 
advised to split its dev->hard_start_xmit() in the following manner:
1)use its dev->hard_prep_xmit() method to achieve #a
2)use its dev->hard_end_xmit() method to achieve #d
3)#b and #c can stay in ->hard_start_xmit() (or whichever way you 
want to do this)
Note: There are drivers which may need not support any of the two
methods (example the tun driver i patched) so the two methods are
essentially optional.

2.1.1 Theory of operation
--------------------------

The core will first do the packet formatting by invoking your 
supplied dev->hard_prep_xmit() method. It will then pass you the packet 
via your dev->hard_start_xmit() method for as many as packets you
have advertised (via dev->xmit_win) you can consume. Lastly it will 
invoke your dev->hard_end_xmit() when it completes passing you all the 
packets queued for you. 


2.1.1.1 Locking rules
---------------------

dev->hard_prep_xmit() is invoked without holding any
tx lock but the rest are under TX_LOCK(). So you have to ensure that
whatever you put it dev->hard_prep_xmit() doesnt require locking.

2.1.1.2 The slippery LLTX
-------------------------

LLTX drivers present a challenge in that we have to introduce a deviation
from the norm and require the ->hard_batch_xmit() method. An LLTX
driver presents us with ->hard_batch_xmit() to which we pass it a list
of packets in a dev->blist skb queue. It is then the responsibility
of the ->hard_batch_xmit() to exercise steps #b and #c for all packets
passed in the dev->blist.
Step #a and #d are done by the core should you register presence of
dev->hard_prep_xmit() and dev->hard_end_xmit() in your setup.

2.1.1.3 xmit_win
----------------

dev->xmit_win variable is set by the driver to tell us how
much space it has in its rings/queues. dev->xmit_win is introduced to 
ensure that when we pass the driver a list of packets it will swallow 
all of them - which is useful because we dont requeue to the qdisc (and 
avoids burning unnecessary cpu cycles or introducing any strange 
re-ordering). The driver tells us, whenever it invokes netif_wake_queue,
how much space it has for descriptors by setting this variable.

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

3.1  Driver pre-requisite
--------------------------

This is _a very important_ requirement in making batching useful.
The pre-requisite for batching changes is that the driver should 
provide a low threshold to open up the tx path.
Drivers such as tg3 and e1000 already do this.
Before you invoke netif_wake_queue(dev) you check if there is a
threshold of space reached to insert new packets.

Heres an example of how i added it to tun driver. Observe the
setting of dev->xmit_win

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

a) On initialization (before netdev registration)
 i) set NETIF_F_BTX in dev->features 
  i.e dev->features |= NETIF_F_BTX
  This makes the core do proper initialization.

ii) set dev->xmit_win to something reasonable like
  maybe half the tx DMA ring size etc.

b) create proper pointer to the new methods desribed above if
you need them.

3.3 Annotation on the different methods 
----------------------------------------
This section shows examples and offers suggestions on how the different 
methods and variable could be used.

3.3.1 The dev->hard_prep_xmit() method
---------------------------------------

Use this method to only do pre-processing of the skb passed.
If in the current dev->hard_start_xmit() you are pre-processing
packets before holding any locks (eg formating them to be put in
any descriptor etc).
Look at e1000_prep_queue_frame() for an example.
You may use the skb->cb to store any state that you need to know
of later when batching.
PS: I have found when discussing with Michael Chan and Matt Carlson
that skb->cb[0] (8bytes of it) is used by the VLAN code to pass VLAN 
info to the driver.
I think this is a violation of the usage of the cb scratch pad. 
To work around this, you could use skb->cb[8] or do what the broadcom
tg3 bacthing driver does which is to glean the vlan info first then
re-use the skb->cb.

3.3.2 dev->hard_start_xmit()
----------------------------
  
Heres an example of tx routine that is similar to the one i added 
to the current tun driver. bxmit suffix is kept so that you can turn
off batching if needed via and call already existing interface.

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

All return codes like NETDEV_TX_OK etc still apply.

3.3.3 The LLTX batching method, dev->batch_xmit()
-------------------------------------------------
  
Heres an example of a batch tx routine that is similar
to the one i added to the older tun driver. Essentially
this is what youd do if you wanted to support LLTX.

----
  static int xxx_net_bxmit(struct net_device *dev)
  {
  ....
  ....
        while (skb_queue_len(dev->blist)) {
	        dequeue from dev->blist
		enqueue onto hardware ring
		if hardware ring full break
        }
				           
	if (hardware ring full) {
		  netif_stop_queue(dev);
		  dev->xmit_win = 1;
	}

       .......
       ..
       .
  }
------

All return codes like NETDEV_TX_OK etc still apply.

3.3.4 The tx complete, dev->hard_end_xmit()
-------------------------------------------------
  
In this method, if there are any IO operations that apply to a 
set of packets such as kicking DMA, setting of interupt thresholds etc,
leave them to the end and apply them once if you have successfully enqueued. 
This provides a mechanism for saving a lot of cpu cycles since IO
is cycle expensive.
For an example of this look e1000 driver e1000_kick_DMA() function.

3.3.5 setting the dev->xmit_win 
-----------------------------

As mentioned earlier this variable provides hints on how much
data to send from the core to the driver. Here are the obvious ways:
a)on doing a netif_stop, set it to 1. By default all drivers have 
this value set to 1 to emulate old behavior where a driver only
receives one packet at a time.
b)on netif_wake_queue set it to the max available space. You have
to be careful if your hardware does scatter-gather since the core
will pass you scatter-gatherable skbs and so you want to at least
leave enough space for the maximum allowed. Look at the tg3 and
e1000 to see how this is implemented.

The variable is important because it avoids the core sending
any more than what the driver can handle therefore avoiding 
any need to muck with packet scheduling mechanisms.

Appendix 1: History
-------------------
June 11/2007: Initial revision
June 11/2007: Fixed typo on e1000 netif_wake description ..
Aug  08/2007: Added info on VLAN and the skb->cb[] danger ..
Sep  24/2007: Revised and cleaned up

--=-L9ekskkCxVFlmXlKWjqO--

