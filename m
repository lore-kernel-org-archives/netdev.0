From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: cannot ARP macvlan on top of bonding device
Date: Fri, 19 Sep 2014 14:00:40 -0700
Message-ID: <20140919210040.E09BA481010@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@arista.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.aristanetworks.com ([162.210.130.12]:40708 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757765AbaISVAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:00:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[Resending with correct date]

Ping in the following test fails:

# Create veth pair v1 v2
ip link add v1 type veth peer name v2

# Stack macvlan on top of bonding device on top of v1
ip link set v1 up
ip link add bond1 type bond
ip link set bond1 up
ifenslave bond1 v1
ip link add link bond1 name mac1 type macvlan mode bridge
ip link set mac1 up
ifconfig mac1 1.2.3.1/24

# Move v2 to namespace dummy2 and ping v1
ip netns add dummy2
ip link set v2 netns dummy2
ip netns exec dummy2 bash
ip link set lo up
ip link set v2 up
ifconfig v2 1.2.3.2/24
ping 1.2.3.1 -c 5

# Clean up
exit
ip netns del dummy2
ip link del bond

It passes on older releases.
The problem is that txqueuelen in bond1 is 0, and ARP requests are dropped in macvlan_broadcast_enqueue at:

        if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
                __skb_queue_tail(&port->bc_queue, nskb);
                err = 0;
        }

where
port->dev = skb->dev = "bond1"
skb_queue_len(&port->bc_queue) = skb->dev->tx_queue_len = 0

macvlan_broadcast_enqueue was introduced in 412ca1550 (macvlan: Move broadcasts into a work queue).

Why are we using tx_queue_len to limit an rx queue?

Thanks,
Francesco Ruggeri
