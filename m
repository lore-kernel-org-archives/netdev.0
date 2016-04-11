From: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Subject: veth produces martians after pushing veth into ns
Date: Mon, 11 Apr 2016 10:46:17 +0000
Message-ID: <D3313F06.570CA%Shaun.Crampton@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0105.outbound.protection.outlook.com ([207.46.100.105]:21536
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750820AbcDKLBw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 07:01:52 -0400
Content-Language: en-US
Content-ID: <D233EC8942EF2E4BB27F5B63C001DE83@metaswitch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'd appreciate if you could CC me on any responses.

I'm trying to push a veth into a namespace and then give it an IP address
and a default route.  The procedure that I have works fine at low scale,
but once I have ~100 veths on a moderately-loaded system, I start seeing
1s delays before processes in a namespace with a new veth can send
traffic.  The delays correspond with martian packet logs in the kernel log
so it's like the IP or route update hasn't taken effect yet and it's
trying to send packets with the wrong source.

My procedure looks like this:

# Outside the container, create a veth.
ip link add <vethname> type veth
ip link set <vethname> up
sleep 1  # This bypasses the (probably unrelated) 1s link-status timer in
the kernel.

# Push veth into container.
ip link set <vethname> netns <nsname>

# Inside the container, rename the veth, add IP addr and default route.
ip netns exec <nsname> ip link set <vethname> eth0
ip netns exec <nsname> ip link set <vethname> up
ip netns exec <nsname> ip addr add <ipaddr>
ip netns exec <nsname> ip route replace <hostaddr> dev eth0
ip netns exec <nsname> ip route replace default via <hostaddr> dev eth0

# Actually start the target program in the namespace.
ip netns exec <nsname> <executable to run>





Process tries to send UDP packets to a remote IP, first packet is dropped
with a martian warning on the host.  The source address for the martian is
the host's IP address so it appears that there's a window where the
namespace thinks it has the wrong IP, even though the ip route commands
completed before I exec the test program in the namespace.  After
(exactly) 1s, packets start flowing with correct source address.

Given that this only happens under load, I suspect that there's some async
processing going on that hasn't finished when the "ip route" commands
return.   Or, perhaps the veth has a routing or ARP cache that I need to
clear when I push it into the namespace.

I tried adding these calls after the "ip route replace"s:

ip netns exec <nsname> ip addr
ip netns exec <nsname> ip route


They both show the expected new IP/routes.  Adding those commands seems to
improve the success rate  (presumably because it effectively adds a small
sleep before the exec).

Can anyone suggest a good way to make sure that my script blocks until the
IPs and routes really are in place and active (or any caches I should be
clearing to avoid this issue)?

I'm running this kernel:

Linux smc-host-0015 3.19.0-28-generic #30-Ubuntu SMP Mon Aug 31 15:52:51
UTC 2015 x86_64 x86_64 x86_64 GNU/Linux


Thanks,

-Shaun
