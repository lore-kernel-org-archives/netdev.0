From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 4/9] netconsole: Introduce netconsole_netdev_notifier
Date: Sun, 8 Jul 2007 01:58:31 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707080116220.3789@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110759.28520.37301.sendpatchset@cselinux1.cse.iitk.ac.in>
 <468FDC87.6050702@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: KII Keiichi <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:58382 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547AbXGGUGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 16:06:41 -0400
In-Reply-To: <468FDC87.6050702@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, 8 Jul 2007, KII Keiichi wrote:
> [...]
> Should we avoid the automatic update of netconsole_target until we can notice all 
> necessary members of netconsole_target updated automatically?
> 
> I had thought about automatic updating of the netconsole_target(i.e. local IP address 
> and network device).
> But I thought that the netconsole(netpoll) can only be related to a network device
> because the user of netconsole is free to be able to set local IP address and 
> MAC address of netconsole and it is difficult to monitor change of local IP address.
[...]
> But, in the case, we must think of the case of changing IP address 
> because we can change IP address without disabling the network device and 
> can't hook the event of changing IP address.

Well, updating the local _IP_ address (for a particular interface) as
and when it changes would also be good ... it is another piece of info
exposed (read-write) to userspace through configfs, so makes sense to
keep it uptodate. But note that the two event notifications that we
care about currently are simply to keep up with changes in local _MAC_
address and interface name.

Regarding local_ip, the present behaviour is:

(1) If the user did not specify any local IP address (that is left that
field empty or zero), netpoll_setup() automatically fills it up with the
IP of the local network interface device that it is attached to: from
net_device->ip_ptr->ifa_list->ifa_local

(2) If user specified some local IP address, netpoll_setup() blindly
copies that into np->local_ip and that would later get used when
constructing the eth/ip/udp packet to be sent (containing the logging
data), as can be seen in netpoll_send_udp(). If the local IP changes
at some point after netpoll_setup(), nothing updates np->local_ip
accordingly.

So this patch just continues preserving the current behaviour, but yes,
it could make sense to trap protocol address changes and update the
local_ip field too when that happens (as long as it doesn't break
anything, as Matt warned earlier). I'm not aware of any existing
netdevice notifier that'll do this, so I'll look around (or trace
an ifconfig(8) / ip(8) to see what actually happens).

> Or I propose updating netconsole_taget informations when the network device up/down.
> The MAC address and network interface name can be changed when 
> the network device is disabled.

Actually, what happens is that if you: (1) disable / down the interface,
(2) change name / MAC address while it was down, and then (3) bring it
back up, then on coming back up, *both* the NETDEV_CHANGE{NAME,ADDR} and
the NETDEV_UP notifier chains are called out. If you just brought it
down and back up without setting any params, the other chains would not
be called out, but NETDEV_UP would. In this case, it's unnecessary to
update the params, because nothing got changed. And if something did
get changed, the corresponding chain would get called anyway, so it's
clearly best to update only the appropriate params, only when the
corresponding event notification comes along.

Satyam
