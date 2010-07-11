From: Michael Leun <lkml20100708@newton.leun.net>
Subject: FW: NET_NS: unregister_netdevice: waiting for lo to become free
 (after using openvpn) (was Re: sysfs bug when using tun with network
 namespaces)
Date: Sun, 11 Jul 2010 19:29:39 +0200
Message-ID: <20100711192939.1c25dcaf@xenia.leun.net>
References: <loom.20100708T183152-326@post.gmane.org>
 <20100709235744.GA12752@kroah.com>
 <20100710101540.2799c9ef@xenia.leun.net>
 <20100710140800.GA20424@kroah.com>
 <20100710165208.59272ae6@xenia.leun.net>
 <20100710235323.5336f627@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100710235323.5336f627@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

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
