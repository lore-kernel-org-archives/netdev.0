From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6698] New: unregister_netdevice hangs
 indefinitely from /proc/sys/net/ipv6/conf/all/forwarding
Date: Mon, 19 Jun 2006 16:06:20 -0700
Message-ID: <20060619160620.093eac25.akpm@osdl.org>
References: <200606161620.k5GGKagU011416@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, kernelbmw@lsmod.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4818 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964974AbWFSXDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 19:03:09 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200606161620.k5GGKagU011416@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6698
> 
>            Summary: unregister_netdevice hangs indefinitely from
>                     /proc/sys/net/ipv6/conf/all/forwarding
>     Kernel Version: 2.6.17-rc6
>             Status: NEW
>           Severity: normal
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: kernelbmw@lsmod.de
> 
> 
> Most recent kernel where this bug did not occur: none known (yet)
> Distribution: reproduced on Debian/stable, SuSE/10.0, SuSE/10.1
> Hardware Environment: reproduced on UML, i386, x86/64
> Software Environment: reproduced with openvpn and UML tap devices
> Problem Description: after adding IPv6 to my previously working openvpn
> tunneling setup, a (really old) IPv6-related bug started to occurr:
> http://lkml.org/lkml/2003/8/21/1
> I also reproduced this bug with kernel 2.6.15.1(vanilla,uml) and
> 2.6.16.13(SuSE-version,x86/64) and linux-2.6.13 (SuSE-version,i386)
> 
> Steps to reproduce:
> echo 0 > /proc/sys/net/ipv6/conf/all/forwarding # this is important initialization
> 
> Have (any version of) openvpn open a tunnel using a tap (virtual ethernet)
> device. In the "up" script do:
> echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
> this can be easily tested with these lines:
> apt-get install openvpn
> modprobe tun
> mknod /dev/net/tun c 10 200
> echo 0 > /proc/sys/net/ipv6/conf/all/forwarding
> echo "echo 1 > /proc/sys/net/ipv6/conf/all/forwarding" > /tmp/up ; chmod a+x /tmp/up
> openvpn --dev-type tap --remote tunnel.lsmod.de 5003 --ifconfig 10.9.0.2
> 255.255.255.0 --dev-node /dev/net/tun --up /tmp/up
> # at this point you can verify your tunnel setup by ping 10.9.0.1
> # on the server I have this: openvpn --dev-type tap --ifconfig 10.9.0.1
> 255.255.255.0 --port 5003 --dev-node /dev/net/tun --float
> # you need UDP port 5003 to pass through your firewall for this
> 
> 
> Alternatively get an user-mode-linux(UML) binary and do something along the
> lines of:
> apt-get install uml-utilities
> TAP=`tunctl -b`
> ifconfig $TAP 192.168.121.1 netmask 255.255.255.252
> echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
> /path/to/linux eth0=tuntap,$TAP ... # booting up to the point where the tap dev
> is really bound (at "ifconfig eth0 192.168.121.2" within the UML)
> tunctl -d $TAP
> 
> 
> After 20 seconds kill the openvpn or linux process.
> This hangs indefinitely, leaving the openvpn process in "D" state.
> syslog states every 10 secs:
> unregister_netdevice: waiting for tap0 to become free.  Usage count = 1
> 
> The kernel will then hang "ifconfig" and "ip" commands, probably because the
> waiting-for-tap0 still holds a mutex.
> 
> After a dozen reboots of trying I found a work-around: replacing the critical
> line with
> (sleep 2 ; echo 1 > /proc/sys/net/ipv6/conf/all/forwarding )&
> 
> A sleep 1 does not suffice.
> Doing the echo before calling openvpn also works fine, so there seems to be a
> timing problem or race condition during initialization of the IPv6 on the newly
> created tap0 device.
> 

Thought to be an ipv6 refcount leak.
