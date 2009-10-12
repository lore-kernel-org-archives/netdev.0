From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 09:47:52 +0000
Message-ID: <20091012094752.GA8114@ff.dom.local>
References: <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: public-netdev-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org,
	Omaha Linux User Group
	<public-olug-u8lKhlSLHjY@plane.gmane.org>
To: CentOS mailing list
	<public-centos-IFYaIzF+flcdnm+yROfE0A@plane.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45119 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125AbZJLJsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 05:48:42 -0400
Received: from public by plane.gmane.org with local (Exim 4.63)
	(envelope-from <public@plane.gmane.org>)
	id 1MxHVZ-0005RS-E7
	for netdev@vger.kernel.org; Mon, 12 Oct 2009 11:48:01 +0200
Content-Disposition: inline
In-Reply-To: <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09-10-2009 18:44, Rob Townley wrote:
> ping -I is broken
> 
> The following deals with bug in ping that made it very difficult to set up a
> system with two gateways.
> 
> Demonstration that *ping -I is broken*. When specifying the source
> interface using -I with an *ethX* alias and that interface is not the
> default gateway
> interface, then ping fails. When specifying the interface as an ip address,
> ping works. Search for "Destination Host Unreachable" to find the bug.
> 
> 
> eth*0* = 4.3.2.8 and the default gateway is accessed through a different
> interface eth*1*.
> eth*1* = 192.168.168.155 is used as the device to get to the default
> gateway.
> *FAILS *: ping *-I eth0* 208.67.222.222
> *WORKS*: ping *-I 4.3.2.8* 208.67.222.222
> *WORKS*: ping *-I eth1* 208.67.222.222
> *WORKS*: ping *-I 192.168.168.155* 208.67.222.222
...
> man ping:
>    -I interface address
>         Set source address to specified interface address.
>         Argument may be *numeric IP address or name of device*.
>         When  pinging  IPv6  link-local  address  this option is required.

It seems this description might be misleading that IP address and name
of device are equivalent here, while they are treated a bit different.
The device name is additionally used in a sendmsg message, probably to
guarantee the device is really used (not its address only), so it
looks like intended.

> ping -V returns the latest available on CentOS and Fedora and the
> maintainers website:
> ping utility, iputils-ss020927

I guess the patch below could do what you expect in this case, but
rather "man" should be fixed...

Jarek P.
---

--- ping.c.orig	2002-09-20 15:08:11.000000000 +0000
+++ ping.c	2009-10-12 08:51:25.000000000 +0000
@@ -323,7 +323,7 @@ main(int argc, char **argv)
 		perror("ping: icmp open socket");
 		exit(2);
 	}
-
+#if 0
 	if (device) {
 		struct ifreq ifr;
 
@@ -336,7 +336,7 @@ main(int argc, char **argv)
 		cmsg.ipi.ipi_ifindex = ifr.ifr_ifindex;
 		cmsg_len = sizeof(cmsg);
 	}
-
+#endif
 	if (broadcast_pings || IN_MULTICAST(ntohl(whereto.sin_addr.s_addr))) {
 		if (uid) {
 			if (interval < 1000) {

