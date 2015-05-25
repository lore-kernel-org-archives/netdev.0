From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 16:53:43 -0700
Message-ID: <1432598023.4060.210.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <1432596953.32671.116.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33942 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbEYXxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 19:53:45 -0400
Received: by ieczm2 with SMTP id zm2so80723070iec.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 16:53:45 -0700 (PDT)
In-Reply-To: <1432596953.32671.116.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 19:35 -0400, John A. Sullivan III wrote:
> On Mon, 2015-05-25 at 16:19 -0700, Eric Dumazet wrote:
> > On Mon, 2015-05-25 at 18:44 -0400, John A. Sullivan III wrote:
> > > On Mon, 2015-05-25 at 15:38 -0700, Eric Dumazet wrote:
> > > > On Mon, 2015-05-25 at 18:22 -0400, John A. Sullivan III wrote:
> > > > 
> > > > > 2) Why do we still not negotiate the 16MB buffer that we get when we are
> > > > > not using GRE?
> > > > 
> > > > What exact NIC handles receive side ?
> > > > 
> > > > If drivers allocate a full 4KB page to hold each frame,
> > > > plus sk_buff overhead,
> > > > then 32MB of kernel memory translates to 8MB of TCP window space.
> > > > 
> > > > 
> > > > 
> > > > 
> > > Hi, Eric.  I'm not sure I understand the question or how to obtain the
> > > information you've requested.  The receive side system has 48GB of RAM
> > > but that does not sound like what you are requesting.
> > > 
> > > I suspect the behavior is a "protection mechanism", i.e., it is being
> > > calculated for good reason.  When I set the buffer to 16MB manually in
> > > nuttcp, performance degraded so I assume I was overrunning something.  I
> > > am still downloading the traces.
> > > 
> > > But I'm still mystified by why this only affects GRE traffic.  Thanks -
> > 
> > GRE is quite expensive, some extra cpu load is needed.
> > 
> > On receiver, can you please check what exact driver is loaded ?
> > 
> > Is it igb, ixgbe, e1000e, i40e ?
> > 
> > ethtool -i eth0
> > 
> > GRE has extra 28 bytes of encapsulation, this definitely can make skb a
> > little bit fat. TCP has very simple heuristics (using power of two
> > steps) and a 50% factor can be explained by this extra 28 bytes for some
> > particular driver.
> > 
> > You could emulate this at the sender (without GRE) by reducing the mtu
> > for the route to your target.
> > 
> > ip route add 192.x.y.z via <gateway> mtu 1450
> > 
> > 
> 
> The receiver as well as the gateway is using igb:
> root@vserveringestst-01:~# ethtool -i eth0
> driver: igb
> version: 3.2.10-k
> firmware-version: 1.4-3
> bus-info: 0000:01:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> 
> Changing the MTU does not show the same degradation as GRE:

Then it is very possible igb was not able to dissect GRE packets,
and driver skb allocation enters a 'slow path'

You might try a more recent version of linux kernel at receiver.

igb current version is 5.2.15-k
