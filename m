From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (after using openvpn) (was Re: sysfs bug when using tun with network
 namespaces)
Date: Thu, 5 Aug 2010 00:11:05 +0200
Message-ID: <20100805001105.5a3453ed@xenia.leun.net>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv04.lahn.de ([213.239.197.57]:46589 "EHLO serv04.lahn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047Ab0HDWNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 18:13:54 -0400
In-Reply-To: <20100804214618.GA6289@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 4 Aug 2010 14:46:18 -0700
Greg KH <greg@kroah.com> wrote:

> Eric, here's a bug with the network namespace stuff, care to work on
> resolving it?

Just in case I provide the complete scenario again below.

If I can help somehow (provide further information, test something...)
of course I'll happily do so.

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
Proto Recv-Q Send-Q Local Address           Foreign Address
State Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node Path
# > ps ax|grep openvpn|grep -v grep
# > # cannot find anything that suggests there is anything left from that openvpn session 
# > exit # logging out from shell in network namespace

Now I get

Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for lo to
become free. Usage count = 3 [repeated]

Now one might say it is fault of openvpn (used OpenVPN 2.1_rc20
i586-suse-linux - the one in openSuSE 11.2 package - EDIT: meanwhile it
is 2.1.1, openSuSE 11.3 ), openvpn didn't close some ressource and ssh
does fine.

But: should'nt kernel clean up after process when it exits?
And/or: Should'nt kernel clean up if last process in network namespace
exits - there is nothing left which might use that interface?!


-- 
MfG,

Michael Leun

