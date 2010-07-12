From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: sysfs bug when using tun with network namespaces
Date: Mon, 12 Jul 2010 22:07:27 +0200
Message-ID: <20100712220727.1be49d54@xenia.leun.net>
References: <20100709132919.7871bee6@xenia.leun.net>
	<4C3B5D68.5010809@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml@vger.kernel.org, netdev@vger.kernel.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv04.lahn.de ([213.239.197.57]:50777 "EHLO serv04.lahn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab0GLUKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 16:10:25 -0400
In-Reply-To: <4C3B5D68.5010809@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max,

On Mon, 12 Jul 2010 11:22:32 -0700
Max Krasnyansky <maxk@qualcomm.com> wrote:

> Thanks for forwarding this report. I'll take a look and try to
> reproduce and fix it when I get a chance.

Sorry, I should have send the further communication CC: to you.

This one is resolved, it is due to missing support for namespaces
almost at all in sysfs prior to 2.6.35-rc, bug does not appear
in .35-rcX anymore.

But I have found another one:

On Sat, 10 Jul 2010 16:52:08 +0200
Michael Leun <lkml20100708@newton.leun.net> wrote:

> # tunctl -u ml -t tap1    

> works as expected, but    

> # unshare -n /bin/bash
> # tunctl -u ml -t tap1    
[bug  (no sysfs support for net namespaces at all) solved in 2.6.35-rcX
- I used 2.6.34.1]

Now that we have solved that last one I've another glitch (this time using 2.6.35-rc4):

In an network namespace I can use an tun/tap tunnel through ssh and
when closing that namespace then eveything is fine.

But when using openvpn (also tunnel trough tun/tap) in an network
namespace and then closing that namespace I get:

unregister_netdevice: waiting for lo to become free
[repeated]

Please see the following two examples showing that difference:

# > unshare -n /bin/bash
# > # how to setup veth device pair to get connectivity into namespace not shown here
# > tunctl -u ml -t tap1
# > ssh -o Tunnel=Ethernet -w 1:1 somewhere
[ running some traffic over tap1 not shown here ]
^d # logging out from somewhere
# > tunctl -d tap1
# > exit # logging out from shell in network namespace

Now the veth device pair used automagically vanishes and nothing
from that different network namespace remains - very well.

but

# > unshare -n /bin/bash
# > # how to setup veth device pair to get connectivity into namespace not shown here
# > openvpn --config some.config
[ running some traffic over vpn device not shown here ]
^c # stopping openvpn
# > lsof -i
# > netstat -an
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node Path
# > ps ax|grep openvpn|grep -v grep
# > # cannot find anything that suggests there is anything left from that openvpn session
# > exit # logging out from shell in network namespace

Now I get

Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for lo to become free. Usage count = 3
[repeated]

Now one might say it is fault of openvpn (used OpenVPN 2.1_rc20
i586-suse-linux - the one in openSuSE 11.2 package), openvpn didn't
close some ressource and ssh does fine.

But: should'nt kernel clean up after process when it exits?
And/or: Should'nt kernel clean up if last process in network namespace
exits - there is nothing left which might use that interface?!

Greg KH <greg@kroah.com> wrote:

> Yes, you are correct.  Care to resend all of this to the
> network-namespace developer(s) and the netdev mailing list so that the
> correct people are notified so they can fix it all?  

[X] done - hopefully, cannot find a particular network namespace
developer in MAINTAINERS or source files. If such a one exists, please
forward.

Thanks.


-- 
MfG,

Michael Leun

