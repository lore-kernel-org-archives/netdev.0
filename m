From: jamal <hadi@cyberus.ca>
Subject: [DOC] Net tx batching core evolution
Date: Wed, 08 Aug 2007 09:03:54 -0400
Message-ID: <1186578234.5171.31.camel@localhost>
References: <1181569965.4043.260.camel@localhost>
	 <1181603345.4071.67.camel@localhost>  <1186574575.5171.17.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-x18V7GHMrQKTmJ/B2djr"
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
Received: from py-out-1112.google.com ([64.233.166.180]:36642 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758408AbXHHNED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 09:04:03 -0400
Received: by py-out-1112.google.com with SMTP id d32so255429pye
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2007 06:04:02 -0700 (PDT)
In-Reply-To: <1186574575.5171.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-x18V7GHMrQKTmJ/B2djr
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


The attached doc describes the evolution of batching work that leads
towards the dev->hard_prep_xmit() api being introduced.

As usual the updated working tree can be found at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git

cheers,
jamal

--=-x18V7GHMrQKTmJ/B2djr
Content-Disposition: attachment; filename=evolution-of-batch.txt
Content-Type: text/plain; name=evolution-of-batch.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit


The code for this work can be found at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git

The purpose of this doc is not to describe the batching work although
benefits of that approach could be gleaned from this doc (example
section 1.x should give the implicit value proposition).
There are more details on the rest of the batching work described in
the driver howto posted on netdev as well as a couple of presentations 
i have given in the past (refer to the last few slides of my netconf 2006 
slides for example).

The purpose of this doc is to describe the evolution of the work
work which leads to two important apis to the driver writer.
The first one is introduction of a method called 
dev->hard_prep_xmit() and the second api is the introduction
of variable dev->xmit_win

For the sake of clarity i will be using non-LLTX because it is easier 
to explain.
Note: The e1000, although non-LLTX has shown considerable improvement
with this approach as well as verified by experiments. (For a lot of
other reasons e1000 needs to be converted to be non-LLTX).

1.0 Classical approach 
------------------------

Lets start with classical approach of what a random driver will do

loop:
  1--core spin for qlock
  1a---dequeu packet
  1b---release qlock

  2--core spins for xmit_lock

    3--enter hardware xmit routine
    3a----format packet:
    --------e.g vlan, mss, shinfo, csum, descriptor count, etc
    -----------if there is something wrong free skb and return OK
    3b----do per chip specific checks
    -----------if there is something wrong free skb and return OK
    3c----all is good, now stash a packet into DMA ring.

  4-- release tx lock
  5-- if all ok (there are still packets, netif not stopped etc)
      continue, else break
end_loop:

In between #1 and #1b, another CPU contends for qlock
In between #3 and #4, another CPU contends for txlock

1.1 Challenge to classical approach:
-------------------------------------

The cost of grabbing/setting up a lock is not cheap.
Observation also: spinning CPUs is expensive because the utilization
of the compute cycles goes down. 
We assume the cost of dequeueing from the qdisc is not as expensive
as the enqueueing to DMA-ring.

1.2 Addressing the challenge to classical approach:
---------------------------------------------------

So we start with a simple premise to resolve the challenge above.
We try to amortize the cost by:
a) grabbing "as many" packets as we can between #1 and #1b with very 
little processing so we dont hold that lock for long.
b) then send "as many" as we can in between #3 and #4.

Lets start with a simple approach (which is what the batch code did 
in its earlier versions):

loop:
  1--core spin for qlock
    loop1: // "as many packets"
       1a---dequeu and enqueue on dev->blist
    end loop1:
  1b---release qlock

  2--core spins for xmit_lock

    3--enter hardware xmit routine
    loop2 ("for as many packets" or "no more ring space"):
       3a----format packet
       --------e.g vlan, mss, shinfo, csum, descriptor count, etc
       -----------if there is something wrong free skb and return OK (**)
       3b----do per chip specific checks
       -----------if there is something wrong free skb and return OK
       3c----all is good, now stash a packet into DMA ring.
    end_loop2:
       3d -- if you enqueued packets tell tx DMA to chew on them ...

  4-- release tx lock
  5-- if all ok (there are still packets, netif not stopped etc)
      continue;
end_loop

loop2 has the added side-benefit of improving the instruction cache 
warmness.
i.e If we can do things in a loop we would keep the instruction cache
warm for more packets (hence improve the hit rate/CPU-utilization).
However, the length of this loop may affect the hit-rate (very clear
to see as you use machines with bigger caches and qdisc_restart showing
in profiles). 
Note also: We have also amortized the cost of bus IO in step 3d 
because we make only one call after exiting the loop. 

2.0 New challenge
-----------------

A new challenge is introduced.
We could hold the tx lock for "long period" depending on how unclean
the driver path is. i.e imagine holding this lock for 100 packets.
So we need to find a balance.

We observe that within loop2, #3a doesnt need to be held within the
xmit lock. All it does is muck with an skb and may end up infact 
dropping it.

2.1 Addressing new challenge
-----------------------------

To address the new challenge, i introduced the dev->hard_prep_xmit() api. 
Essentially, dev->hard_prep_xmit() moves the packet formatting into #1
So now we change the code to be something along the lines of:

loop:
  1--core spin for qlock
    loop1: // "as many packets"
       1a---dequeu and enqueue on dev->blist
       1b--if driver has hard_prep_xmit, then format packet.
    end loop1:
  1c---release qlock

  2--core spins for xmit_lock

    3--enter hardware xmit routine
    loop2: ("for as many packets" or "no more ring space"):
       3a----do per chip specific checks
       -----------if there is something wrong free skb and return OK
       3b----all is good, now stash a packet into DMA ring.
    end_loop2:
       3c -- if you enqueued packets tell tx DMA to chew on them ...

  4-- release tx lock
  5-- if all ok (there are still packets, netif not stopped etc)
      continue;
end_loop

3.0 TBA:
--------
talk here about further optimizations added starting with xmit_win..

Appendix 1: HISTORY
---------------------
Aug 08/2007 - initial revision


--=-x18V7GHMrQKTmJ/B2djr--

