From: andrei radulescu-banu <iubica2@yahoo.com>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 08:47:01 -0700 (PDT)
Message-ID: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S939090AbXGSPrV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The consensus seems to be that skb's need to carry vlan accelerated tags in their cb's, on rx as well as tx. VLAN_TX_SKB_CB() is perfect for that.

> [Patrick] On the TX path, it could simply use the CB, but this is actually
also wrong (for both macvlan and real devices) since qdiscs have
ownership of the skb in between, and at least netem *does* modify
the CB, breaking VLAN.

Thanks for pointing that out... It appears to me that qdisc/netem already breaks the vlan implementation, in the path 

vlan_dev_hwaccel_hard_start_xmit(): sets accelerated vlan tag in skb->cb, calls
dev_queue_xmit(): may pass skb to qdisc/netem, which may mangle skb->cb before calling
dev->hard_start_xmit(), resulting in a tx frame without its vlan tag.

So netem needs to look for hw accelerated vlan metadata and insert it in the skb... Don't see any other way around this. 

> [Patrick] Your suggestion of disabling VLAN acceleration in promiscuous
mode sounds like a reasonable solution until then ..

I was rather thinking of keeping hw vlan acceleration in promiscuous mode. Upon becoming promisc, the driver will be changed to disable vlan filters - it will reenable them when leaving promisc mode.

My 2 cents on vlan hw acceleration: it does not save much in computing cycles, if software is written carefully. It is vlan filtering that saves computing time.

> [Ben] I think a better method would be to allow disabling VLAN HW accel for a NIC with ethtool.

This requires changes to ethtool and e1000 driver, +other drivers. It is a handy thing to have. I don't view it as a solution to tcpdump - or to the vlan bridging problem. One concern: if we're switching hw accel mode on the fly, we need to carefully protect tx frames that are just about going out and have already been set up for the opposite mode.

Any comments on what is the expected behavior of 'tcpdump -i eth0.2' vs. 'tcpdump -i eth0'?

Andrei Radulescu-Banu
Brix Networks





       
____________________________________________________________________________________
Need a vacation? Get great deals
to amazing places on Yahoo! Travel.
http://travel.yahoo.com/
