From: jamal <hadi@cyberus.ca>
Subject: [DOC] Net tx batching driver howto
Date: Wed, 08 Aug 2007 08:02:55 -0400
Message-ID: <1186574575.5171.17.camel@localhost>
References: <1181569965.4043.260.camel@localhost>
	 <1181603345.4071.67.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-EYyg4UKjnmB1Mt9BEVkE"
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jeff Garzik <jeff@garzik.org>,
	Gagan Arneja <gaagaan@gmail.com>,
	Leonid Grossman <Leonid.Grossman@neterion.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:46031 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbXHHMDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 08:03:01 -0400
Received: by wx-out-0506.google.com with SMTP id h31so113647wxd
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2007 05:03:00 -0700 (PDT)
In-Reply-To: <1181603345.4071.67.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EYyg4UKjnmB1Mt9BEVkE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This is a small update to the howto.

The current working tree can be found at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git

cheers,
jamal

--=-EYyg4UKjnmB1Mt9BEVkE
Content-Disposition: attachment; filename=batch-driver-howto.txt
Content-Type: text/plain; name=batch-driver-howto.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit


Heres the begining of a howto for driver author.
The current working tree can be found at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git

The intended audience for this howto is people already
familiar with netdevices.

0) Hardware Pre-requisites:
---------------------------

You must have at least hardware that is capable of doing
DMA with many descriptors; i.e having hardware with a queue
length of 3 (as in some fscked ethernet hardware) is not
very useful in this case.

1) What is new in the driver API:
---------------------------------

a) A new method called onto the driver by the net tx core to
batch packets. This method, dev->hard_batch_xmit(dev), 
is no different than dev->hard_start_xmit(dev) in terms of the 
arguements it takes. You just have to handle it differently 
(more below).

b) A new method, dev->hard_prep_xmit(), called onto the driver to 
massage the packet before it gets transmitted. 
This method is optional i.e if you dont specify it, you will
not be invoked(more below)

c) A new variable dev->xmit_win which provides suggestions to the
core calling into the driver a rough estimate of how many
packets can be batched onto the driver. 

2) Driver pre-requisite
------------------------

The typical driver tx state machine is:

----
--> +Core sends packets
    +--> Driver puts packet onto hardware queue
    +    if hardware queue is full, netif_stop_queue(dev)
    +
--> +core stops sending because of netif_stop_queue(dev)
..
.. time passes
..
..
--> +---> driver has transmitted packets, opens up tx path by
          invoking netif_wake_queue(dev)
--> +Core sends packets, and the cycle repeats.
----

The pre-requisite for batching changes is that the driver should 
provide a low threshold to open up the tx path.
This is a very important requirement in making batching useful.
Drivers such as tg3 and e1000 already do this.
So in the above annotation, as a driver author, before you
invoke netif_wake_queue(dev) you check if there are enough
entries left.

Heres an example of how i added it to tun driver
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

Heres how the batching e1000 driver does it (ignore the setting of
netdev->xmit_win, more on this later):

--
if (unlikely(cleaned && netif_carrier_ok(netdev) &&
     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {

	if (netif_queue_stopped(netdev)) {
	       int rspace =  E1000_DESC_UNUSED(tx_ring) - (MAX_SKB_FRAGS +  2);
	       netdev->xmit_win = rspace;
	       netif_wake_queue(netdev);
       }
---

in tg3 code looks like:

-----
	if (netif_queue_stopped(tp->dev) &&
		(tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
			netif_wake_queue(tp->dev);
---

3) Driver Setup:
-------------------

a) On initialization (before netdev registration)
 i) set NETIF_F_BTX in  dev->features 
  i.e dev->features |= NETIF_F_BTX
  This makes the core do proper initialization.

  ii) set dev->xmit_win to something reasonable like
  maybe half the tx DMA ring size etc.
  This is later used by the core to guess how much packets to send
  in one batch. 

  b) create proper pointer to the two new methods desribed above.


4) The new methods
--------------------

  a) The batching method
  
Heres an example of a batch tx routine that is similar
to the one i added to tun driver

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

       if we queued on hardware, tell it to chew
       .......
       ..
       .
  }
------

All return codes like NETDEV_TX_OK etc still apply.
In this method, if there are any IO operations that apply to a 
set of packets (such as kicking DMA) leave them to the end and apply
them once if you have successfully enqueued. For an example of this
look e1000 driver e1000_kick_DMA() function.

b) The dev->hard_prep_xmit() method

The benefits of this method are described in an a separate document.

Use this method to only do pre-processing of the skb passed.
If in the current dev->hard_start_xmit() you are pre-processing
packets before holding any locks (eg formating them to be put in
any descriptor etc).
Look at e1000_prep_queue_frame() for an example.
You may use the skb->cb to store any state that you need to know
of later when batching.
PS: I have found when discussing with Michael Chan and Matt Carlson
that skb->cb[0] is used by the VLAN code to pass VLAN info to the driver.
I think this is a violation of the usage of the cb scratch pad. 
To work around this, you could use skb->cb[8] or do what the broadcom
tg3 bacthing driver does which is to glean the vlan info first then
re-use the skb->cb.

5) setting the dev->xmit_win 
-----------------------------

As mentioned earlier this variable provides hints on how much
data to send from the core to the driver. Some suggestions:
a)on doing a netif_stop, set it to 1
b)on netif_wake_queue set it to the max available space

The variable is important because it avoids the core sending
any more than what the driver can handle therefore avoiding 
any need to muck with packet scheduling mechanisms.

Appendix 1: History
-------------------
June 11: Initial revision
June 11: Fixed typo on e1000 netif_wake description ..
Aug  08: Added info on VLAN and the skb->cb[] danger ..


--=-EYyg4UKjnmB1Mt9BEVkE--

