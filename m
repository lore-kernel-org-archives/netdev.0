From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 13:56:39 -0700
Message-ID: <20070423135639.26ca125a.akpm@linux-foundation.org>
References: <20070423130734.d3d90b20.akpm@linux-foundation.org>
	<20070423.131810.78710074.davem@davemloft.net>
	<20070423132719.b7cf1c9e.akpm@linux-foundation.org>
	<20070423.133730.115642229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:47479 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753558AbXDWU4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 16:56:54 -0400
In-Reply-To: <20070423.133730.115642229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 13:37:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 23 Apr 2007 13:27:19 -0700
> 
> > On Mon, 23 Apr 2007 13:18:10 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Date: Mon, 23 Apr 2007 13:07:34 -0700
> > > 
> > > > The interesting bit is:
> > >  ...
> > > > I think I saw the same problem maybe 1.5 weeks ago on this machine, but I
> > > > didn't have time to investigate further.  So it's not some recent thing.
> > > 
> > > My initial reaction is that DNS responses are being lost or dropped
> > > for some reason.
> > 
> > Plausible.   I'll try booting it with the ethernet unplugged.
> 
> That won't test the same scenerio.
> 
> If the network cable is unplugged, ARP responses won't arrive and
> therefore sendmsg() calls will return with a host unreachable error.
> 
> The situation you need to recreate is specifically UDP packets getting
> dropped.
> 
> The reason I wanted the tcpdump trace is so that we can see whether
> the problem is UDP packets going out or going in which are being
> mangled/dropped.
> 
> You don't need a hub to get a dump.  Instead you can run a caching
> named on some other system, configure your FC6 box to use that system
> for DNS via /etc/resolv.conf, then run tcpdump on the caching named
> machine.

hm, fancy.



I unplugged the cable and the machine booted normally.  Lots of commands
were hanging when I plugged it back in.

I plugged the cable back in and on one console ran

	tcpdump -l -i eth0

but of course tcpdump didn't do anything because it wants to do reverse
lookups.  But interestingly, tcpdump was taking maybe 15 seconds to respond
to ^c and to killall.  tcpdump was stuck in udp_poll(), like statd was. 
But I think it's significant that we're not taking signals while in that
interruptible sleep.

I am able to ping the test machine from another host on the same network.

On the test machine I used `tcpdump -l -n -i eth0' and on another vt, ran
`ping www.google.com'.  The test machine is 172.18.116.155

13:40:51.120004 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
13:40:51.489171 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
13:40:52.567615 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
13:40:53.489201 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
13:40:53.755655 arp who-has 172.18.119.254 tell 172.18.116.155
13:40:53.755991 arp reply 172.18.119.254 is-at 00:00:0c:07:ac:01
13:40:53.755997 IP 172.18.116.155.32806 > 172.24.0.7.domain:  42807+ A? www.google.com. (32)
13:40:53.991979 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
13:40:55.435664 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
13:40:55.514942 IP 172.18.116.45.netbios-dgm > 172.18.119.255.netbios-dgm: NBT UDP PACKET(138)
13:40:55.710092 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
13:40:56.463086 arp who-has 172.18.119.254 tell 172.18.116.45
13:40:56.856033 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
13:40:57.709673 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
13:40:58.331717 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
13:40:58.751949 IP 172.18.116.155.32807 > 172.25.146.107.domain:  42807+ A? www.google.com. (32)
13:40:59.276068 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-unknown (3) 16: state=initial group=2 [|hsrp]
13:40:59.709703 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
13:40:59.716492 IP 172.18.119.178.netbios-dgm > 172.18.119.255.netbios-dgm: NBT UDP PACKET(138)
13:40:59.814742 arp who-has 172.18.119.254 tell 172.18.116.206
13:40:59.844096 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
13:41:01.215791 IP 172.18.119.253.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=active group=1 addr=172.18.119.254
13:41:01.709583 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 
13:41:01.751918 IP 172.18.116.199.ipp > 172.18.119.255.ipp: UDP, length 124
13:41:02.776596 arp who-has 172.18.119.254 tell 172.18.117.227
13:41:02.836204 IP 172.18.119.252.hsrp > 224.0.0.2.hsrp: HSRPv0-hello 20: state=standby group=1 addr=172.18.119.254
13:41:03.709613 802.1d config 8000.00:18:74:5d:04:66.80ae root 0066.00:15:c7:20:57:c0 pathcost 4 age 1 max 20 hello 2 fdelay 15 

so it looks like we tried to send the query but we didn't see anything come back.



Which means I need to do the caching named thing.  I tried (using RH's fc6
kernel), but it doesn't work.  Help?

On 172.18.116.160 I'm running

root      7375  0.0  0.0  75496   500 ?        Ssl  Jan22   0:00 /usr/sbin/nscd-2.3.2 -f /etc/nscd-2.3.2.conf

and on the test machine I put

nameserver 172.18.116.160

into /etc/resolv.conf.

Is nscd the caching named which you're referring to?
