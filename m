From: Russell King <rmk@arm.linux.org.uk>
Subject: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Mon, 28 Apr 2008 00:14:11 +0100
Message-ID: <20080427231411.GA5261@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:56670 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbYD0XOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 19:14:19 -0400
Received: from flint.arm.linux.org.uk ([2002:4e20:1eda:1:201:2ff:fe14:8fad])
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1JqG4U-0000CM-9r
	for netdev@vger.kernel.org; Mon, 28 Apr 2008 00:14:14 +0100
Received: from rmk by flint.arm.linux.org.uk with local (Exim 4.69)
	(envelope-from <rmk@flint.arm.linux.org.uk>)
	id 1JqG4S-00030e-2I
	for netdev@vger.kernel.org; Mon, 28 Apr 2008 00:14:12 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've upgraded lists.arm.linux.org.uk to 2.6.25, and I'm now seeing some
very weird networking behaviour from the machine which seems to only
affect IPv4 - including ICMP and NFS(tcp).

tcpdump is available (all 4MB worth):
 http://www.home.arm.linux.org.uk/~rmk/ping.capture

Machines involved:
  dyn-67 - x86 box 2.6.20-1.2320.fc5
  (192.168.0.67 / 2002:4e20:1eda:1:201:80ff:fe4b:1778)

  n2100 - ARM box 2.6.24
  (78.32.30.221, has ipv6 as well)

  lists - ARM box 2.6.25
  (78.32.30.220 / 2002:4e20:1eda:1:201:3dff:fe00:0156)

The dump shows three 8200 byte pings running - one IPv4 on n2100 against
lists, one IPv4 on dyn-67 against lists, and one IPv6 on dyn-67 against
lists.

The tcpdump was running on lists itself.

Everything looks fine until around packet 1688, where n2100 sends an
echo request to lists, which doesn't get a reply.  300ms later, dyn-67
sends an echo request to lists, which also coincidentally doesn't get
a reply.  Note, however, how the IPv6 pings continue.

The stats for the pings upon their termination are:

rmk@dyn-67:[~]:<1005> ping6 -s 8192 lists
PING lists(lists.arm.linux.org.uk) 8192 data bytes
--- lists ping statistics ---
101 packets transmitted, 101 received, 0% packet loss, time 99990ms
rtt min/avg/max/mdev = 4.132/4.488/26.585/2.374 ms, pipe 2

rmk@dyn-67:[~]:<1051> ping -s 8192 lists
PING lists.arm.linux.org.uk (78.32.30.220) 8192(8220) bytes of data.
--- lists.arm.linux.org.uk ping statistics ---
101 packets transmitted, 54 received, 46% packet loss, time 99993ms
rtt min/avg/max/mdev = 4.139/6.027/35.274/6.405 ms

root@n2100:~# ping -s 8192 lists
PING lists.arm.linux.org.uk (78.32.30.220) 8192(8220) bytes of data.
--- lists.arm.linux.org.uk ping statistics ---
101 packets transmitted, 55 received, 45% packet loss, time 100020ms
rtt min/avg/max/mdev = 4.404/4.610/13.235/1.175 ms

Lastly, in /proc/net/snmp on lists, I find:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 2 64 12771 0 0 0 0 0 5159 6262 9 0 2 8172 1363 2 922 0 5520

Note - InReceives = 12771, but InDelivers = 5159 - so roughly 50% of
IPv4 packets were received but not delivered, which appears to tie up
with the ping statistics.

Not sure what to make of this at the moment.  Any ideas?

-- 
Russell King
