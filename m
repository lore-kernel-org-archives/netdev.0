From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Thu, 10 Jun 2004 12:20:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610102045.GA11616@k3.hellgate.ch>
References: <20040607115921.GB32569@k3.hellgate.ch> <OFCBC67DF9.898B09C6-ON88256EAF.001BFC9E-88256EAF.001C4AB8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, David Dillow <dave@thedillows.org>,
        Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFCBC67DF9.898B09C6-ON88256EAF.001BFC9E-88256EAF.001C4AB8@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Jun 2004 23:09:53 -0600, David Stevens wrote:
> netdev-bounce@oss.sgi.com wrote on 06/07/2004 04:59:21 AM:
> 
> > One thing maybe worth mentioning: If you want to play with different
> > addresses, remember that IP addresses are in decimal notation, ethernet
> > in hex. So if you set
> 
> > target# ip maddr add 01:00:5e:00:00:25 dev eth0
> 
> > the test would be
> 
> > tester# ping -r -I eth0 -t 1 -c 2 224.0.0.37
> 
> This will add "01:00:5e:00:00:25" to the device multicast address filter,
> which will mean the host will receive the packet. But because it doesn't
> join the group at the IP level, it'll be dropped and the ping won't be
> answered (it isn't for a local address).
> 
> If you want the machine to answer, you need to join the group, which
> will conveniently add the hardware multicast address automatically. :-)

Correct. The method I described does the trick using standard tools
(iproute2, packet sniffer), though.

> PS - Here's a trivial program that will join a group. If you run this on
> one side, then a ping to the multicast address will work when it's in
> the group, and stop answering when it exits. There are more general
> things that have been around for years for testing-- I just threw this
> together just now. (I hope it doesn't have any bugs! :-) ) Should be
> suitable for testing hardware multicast address filters...

Sure, why not? Fixed up and added to the How-To below.

Roger

Multicast Driver Testing Quick How-To (version 0.2)
=====================================

Preparation
-----------
Make sure the host you are testing replies to broadcasts:

target# cat /proc/sys/net/ipv4/icmp_echo_ignore_all
0
target# cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
0

Our test packets need to go to the target host, so either have a
route or use ping "-r -I <ifname>" option:
tester# route add -net 224.0.0.0 netmask 240.0.0.0 eth0

Test default group
------------------
Since every multicast capable host interface joins 224.0.0.1, you
can already ping your target:

tester# ping -r -I eth0 -t 1 -c 2 224.0.0.1

Your target host should answer this (so may your tester, depending on
your setup).

Join group on Ethernet level
----------------------------
We haven't joined the next group yet, so there should be no answer:

tester# ping -r -I eth0 -t 1 -c 2 224.1.1.37

Use packet sniffer to confirm that target is not seeing the request
(use -p option for tcpdump or tethereal to prevent promiscuous mode)

Now join the group (Ethernet level):

target# ip maddr add 01:00:5e:01:01:25 dev eth0

tester# ping -r -I eth0 -t 1 -c 2 224.1.1.37

Use packet sniffer to confirm that target is seeing the request now.

Join group on IP level
----------------------
The program below will join a multicast group at IP level and thus
at Ethernet level as well -- provided driver and hardware work
properly. Group membership end with termination of the program.

Remove hardware filter (if any left from previous test):

target# ip maddr del 01:00:5e:01:01:25 dev eth0

Join multicast group:

target# ./mcjoin eth0 224.1.1.37

tester# ping -r -I eth0 -t 1 -c 2 224.1.1.37

No need for packet sniffer this time, the target will answer since the
IP layer is aware of our group membership.

--------------------------------------------------------------------------------
/* Purpose: Join a multicast group (for testing)	*/
/* Author: David Stevens <dlstevens@us.ibm.com>, 2004	*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <net/if.h>

int
main(int argc, char *argv[])
{
	struct ip_mreqn mreqn;
	int s;

	if (argc != 3) {
		fprintf(stderr, "usage: %s <dev> <group>\n", argv[0]);
		exit(1);
	}
	s = socket(PF_INET, SOCK_DGRAM, 0);
	if (s < 0) {
		perror("socket");
		exit(1);
	}
	memset(&mreqn, 0, sizeof(mreqn));
	mreqn.imr_ifindex = if_nametoindex(argv[1]);
	if (!mreqn.imr_ifindex) {
		fprintf(stderr, "%s: \"%s\" invalid interface\n", argv[0],
		        argv[1]);
		exit(1);
	}
	if (inet_pton(AF_INET, argv[2], &mreqn.imr_multiaddr) <= 0) {
		fprintf(stderr, "%s: \"%s\" invalid group address\n", argv[0],
		        argv[2]);
		exit(1);
	}
	if (setsockopt(s, SOL_IP, IP_ADD_MEMBERSHIP, &mreqn,sizeof mreqn) < 0) {
		perror("IP_ADD_MEMBERSHIP");
		exit(1);
	}
	printf("joined group %s on %s (pausing...)\n", argv[2], argv[1]);
	fflush(stdout);
	pause();
	exit(0);
}
--------------------------------------------------------------------------------
