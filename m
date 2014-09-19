From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: cannot ARP macvlan on top of bonding device
Date: Fri, 19 Sep 2014 14:17:31 -0700
Message-ID: <1411161451.26859.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140919210040.E09BA481010@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fruggeri@arista.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:56910 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205AbaISVRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:17:34 -0400
Received: by mail-pd0-f172.google.com with SMTP id y10so672166pdj.31
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:17:33 -0700 (PDT)
In-Reply-To: <20140919210040.E09BA481010@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 14:00 -0700, Francesco Ruggeri wrote:
> [Resending with correct date]
> 
> Ping in the following test fails:
> 
> # Create veth pair v1 v2
> ip link add v1 type veth peer name v2
> 
> # Stack macvlan on top of bonding device on top of v1
> ip link set v1 up
> ip link add bond1 type bond
> ip link set bond1 up
> ifenslave bond1 v1
> ip link add link bond1 name mac1 type macvlan mode bridge
> ip link set mac1 up
> ifconfig mac1 1.2.3.1/24
> 
> # Move v2 to namespace dummy2 and ping v1
> ip netns add dummy2
> ip link set v2 netns dummy2
> ip netns exec dummy2 bash
> ip link set lo up
> ip link set v2 up
> ifconfig v2 1.2.3.2/24
> ping 1.2.3.1 -c 5
> 
> # Clean up
> exit
> ip netns del dummy2
> ip link del bond
> 
> It passes on older releases.
> The problem is that txqueuelen in bond1 is 0, and ARP requests are dropped in macvlan_broadcast_enqueue at:
> 
>         if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
>                 __skb_queue_tail(&port->bc_queue, nskb);
>                 err = 0;
>         }
> 
> where
> port->dev = skb->dev = "bond1"
> skb_queue_len(&port->bc_queue) = skb->dev->tx_queue_len = 0
> 
> macvlan_broadcast_enqueue was introduced in 412ca1550 (macvlan: Move broadcasts into a work queue).
> 
> Why are we using tx_queue_len to limit an rx queue?

You're right, we probably should use netdev_max_backlog instead.

Please send a formal patch ?
