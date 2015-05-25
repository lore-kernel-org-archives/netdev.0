From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 19:35:53 -0400
Message-ID: <1432596953.32671.116.camel@jasiiieee.pacifera.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432579766.32671.66.camel@jasiiieee.pacifera.com>
	 <1432580733.4060.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432581685.32671.80.camel@jasiiieee.pacifera.com>
	 <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432589642.32671.108.camel@jasiiieee.pacifera.com>
	 <1432592520.32671.110.camel@jasiiieee.pacifera.com>
	 <1432593501.4060.193.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432593884.32671.113.camel@jasiiieee.pacifera.com>
	 <1432595995.4060.207.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:56661 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbbEYXgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 19:36:08 -0400
In-Reply-To: <1432595995.4060.207.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 16:19 -0700, Eric Dumazet wrote:
> On Mon, 2015-05-25 at 18:44 -0400, John A. Sullivan III wrote:
> > On Mon, 2015-05-25 at 15:38 -0700, Eric Dumazet wrote:
> > > On Mon, 2015-05-25 at 18:22 -0400, John A. Sullivan III wrote:
> > > 
> > > > 2) Why do we still not negotiate the 16MB buffer that we get when we are
> > > > not using GRE?
> > > 
> > > What exact NIC handles receive side ?
> > > 
> > > If drivers allocate a full 4KB page to hold each frame,
> > > plus sk_buff overhead,
> > > then 32MB of kernel memory translates to 8MB of TCP window space.
> > > 
> > > 
> > > 
> > > 
> > Hi, Eric.  I'm not sure I understand the question or how to obtain the
> > information you've requested.  The receive side system has 48GB of RAM
> > but that does not sound like what you are requesting.
> > 
> > I suspect the behavior is a "protection mechanism", i.e., it is being
> > calculated for good reason.  When I set the buffer to 16MB manually in
> > nuttcp, performance degraded so I assume I was overrunning something.  I
> > am still downloading the traces.
> > 
> > But I'm still mystified by why this only affects GRE traffic.  Thanks -
> 
> GRE is quite expensive, some extra cpu load is needed.
> 
> On receiver, can you please check what exact driver is loaded ?
> 
> Is it igb, ixgbe, e1000e, i40e ?
> 
> ethtool -i eth0
> 
> GRE has extra 28 bytes of encapsulation, this definitely can make skb a
> little bit fat. TCP has very simple heuristics (using power of two
> steps) and a 50% factor can be explained by this extra 28 bytes for some
> particular driver.
> 
> You could emulate this at the sender (without GRE) by reducing the mtu
> for the route to your target.
> 
> ip route add 192.x.y.z via <gateway> mtu 1450
> 
> 

The receiver as well as the gateway is using igb:
root@vserveringestst-01:~# ethtool -i eth0
driver: igb
version: 3.2.10-k
firmware-version: 1.4-3
bus-info: 0000:01:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes

Changing the MTU does not show the same degradation as GRE:
root@gwhq-1:~# ip route add 192.168.224.2 via 192.168.128.1 mtu 1476
root@gwhq-1:~# nuttcp -T 60 -i 10 192.168.224.2
connect failed: Connection timed out
interval option only supported for client/server mode
root@gwhq-1:~# nuttcp -T 60 -i 10 192.168.224.2
  644.6875 MB /  10.00 sec =  540.7944 Mbps     0 retrans
 1121.1875 MB /  10.00 sec =  940.5201 Mbps     0 retrans
 1121.2500 MB /  10.00 sec =  940.5744 Mbps     0 retrans
 1121.1250 MB /  10.00 sec =  940.4777 Mbps     0 retrans
 1121.2500 MB /  10.00 sec =  940.5757 Mbps     0 retrans
 1028.8750 MB /  10.00 sec =  863.0736 Mbps     0 retrans

 6171.9375 MB /  60.70 sec =  852.9101 Mbps 5 %TX 12 %RX 0 retrans 80.27 msRTT

CPU does not seem to be an issue from what I can see.  The systems are
all sitting at 98% idle and even checking individual CPUs shows no
overload.  Thanks - John
