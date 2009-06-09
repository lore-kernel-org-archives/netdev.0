From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13467] New: Cannot set larger mtu on vlan then
 on underlying untagged device
Date: Tue, 9 Jun 2009 14:34:38 -0700
Message-ID: <20090609143438.87e6bf5d.akpm@linux-foundation.org>
References: <bug-13467-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, tomek@jot23.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57478 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753994AbZFIV6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 17:58:02 -0400
In-Reply-To: <bug-13467-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 6 Jun 2009 17:43:46 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13467
> 
>            Summary: Cannot set larger mtu on vlan then on underlying
>                     untagged device
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.27.24-170.2.68.fc10.i686
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: tomek@jot23.org
>         Regression: No
> 
> 
> I want to create vlan interface which uses jumbo frames while underlying
> network device is still using standerd 1500 bytes frames. So I tried:
> 
> tkepczyx-mobl1:~# ip link show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP
> qlen 100
>     link/ether 00:0d:60:79:e0:9d brd ff:ff:ff:ff:ff:ff
> tkepczyx-mobl1:~# vconfig add eth0 12
> Added VLAN with VID == 12 to IF -:eth0:-
> tkepczyx-mobl1:~# ip link set dev eth0.12 mtu 9000
> RTNETLINK answers: Numerical result out of range
> 
> So I made sure that eth0 supports 9000 bytes mtu:
> 
> tkepczyx-mobl1:~# ip link set dev eth0 mtu 9000
> tkepczyx-mobl1:~# ip link show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast state UP
> qlen 100
>     link/ether 00:0d:60:79:e0:9d brd ff:ff:ff:ff:ff:ff
> 
> It apparently does. So I gave it another try:
> 
> tkepczyx-mobl1:~# ip link set dev eth0.12 mtu 9000
> tkepczyx-mobl1:~# ip link show dev eth0.12
> 4: eth0.12@eth0: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN
>     link/ether 00:0d:60:79:e0:9d brd ff:ff:ff:ff:ff:ff
> 
> Now it worked. So lets decrease mtu on eth0:
> 
> tkepczyx-mobl1:~# ip link set dev eth0 mtu 1500
> tkepczyx-mobl1:~# ip link show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP
> qlen 100
>     link/ether 00:0d:60:79:e0:9d brd ff:ff:ff:ff:ff:ff
> tkepczyx-mobl1:~# ip link show dev eth0.12
> 4: eth0.12@eth0: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN
>     link/ether 00:0d:60:79:e0:9d brd ff:ff:ff:ff:ff:ff
> 
> It also worked.
> Now - if there is a reason which prevents me to increase mtu on vlan over mtu
> on underlyng device, the very same reason should have prevented me from
> decreasing mtu on underlying eth0 below mtu on eth0.12 vlan. This is a fault.
> 
> I started digging a bit in sources and there is one thing which rings a bell:
> vlan_dev_change_mtu function in net/8021q/vlan_dev.c:
> 
> static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
> {
>         /* TODO: gotta make sure the underlying layer can handle it,
>          * maybe an IFF_VLAN_CAPABLE flag for devices?
>          */
>         if (vlan_dev_info(dev)->real_dev->mtu < new_mtu)
>                 return -ERANGE;
> 
>         dev->mtu = new_mtu;
> 
>         return 0;
> }
> 
> My guess is that check in if() statement above is against currently configured
> mtu while it probably should check what physically device can transmit.
> 

