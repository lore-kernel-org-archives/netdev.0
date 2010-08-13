From: "Morgon J. Kanter" <morgon.j.kanter@dartmouth.edu>
Subject: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Fri, 13 Aug 2010 13:07:38 -0400
Message-ID: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_avXZMuUnIDaVYxs"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub1.dartmouth.edu ([129.170.16.122]:56555 "EHLO
	mailhub1.dartmouth.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761900Ab0HMSW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 14:22:58 -0400
Received: from mewtwo.localnet (nj-71-2-243-192.dhcp.embarqhsd.net [71.2.243.192])
	(authenticated bits=0)
	by mailhub1.dartmouth.edu (8.13.5/DND2.0/8.13.5) with ESMTP id o7DI9qYL012649
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 14:09:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_avXZMuUnIDaVYxs
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have stumbled across what I think is a rare bug in the raw socket mechanism 
of the kernel. When attempting to send a certain packet with an IP ID of zero 
from a raw socket created with the call "socket(AF_INET, SOCK_RAW, 
IPPROTO_RAW)", the kernel will modify the IP ID field and update the checksum. 
It only seems to do it with this specific packet for some reason, similar 
packets with an IP ID of zero do not get so mangled.

To reproduce, I have attached a packet that contains the issue and code that I 
use to send it. To reproduce, compile the sending code:
$ gcc -o testpacket testpacket.c
and run it on the packet:
$ sudo ./testpacket packet1189641421

(You may need to disable your firewall or whatnot. You might also need to 
change the IP field if you don't have a route that satisfies 192.168.1.*, but 
I haven't tried to see if this works or not with another IP.) Note the packet 
itself has an IP ID field of zero. But check in Wireshark or another scanner 
scanner, and when the packet comes out the IP ID is now non-zero! I've 
attached a pcap file with the packet as it was captured from Wireshark.

To double-check that Wireshark is right, you can do the following:

$ sudo iptables -A OUTPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m u32 ! --u32 "2 
& 0xFFFF = 0" -j DROP

(for those not used to reading iptables rules, that simply blocks anything 
with a non-zero IP ID and SYN/ACK flags) When you do such, and attempt to send 
the packet using the provided program, you'll get an EPERM because Netfilter 
is blocking the packet -- even though it is supposedly going in with an IP ID 
of zero, the kernel is rewriting the ID somewhere.

This seems like a bug, because IPPROTO_RAW means IP_HDRINCL should be on and 
we should be providing the IP header exactly as we want it sent out on the 
wire. It's really puzzling because this only happens on very specific packets 
(this was taken from a modified response to the 6th probe from nmap, probes 
1-5 went fine but probe 6 was blocked).

ver_linux output:
Linux mewtwo 2.6.34-gentoo-r1 #4 SMP PREEMPT Tue Aug 10 13:35:42 EDT 2010 
x86_64 Intel(R) Core(TM)2 Duo CPU T9600 @ 2.80GHz GenuineIntel GNU/Linux
 
Gnu C                  4.3.4
Gnu make               3.81
binutils               2.20.1.20100303
util-linux             scripts/ver_linux: line 23: fdformat: command not found
mount                  support
module-init-tools      found
Linux C Library        2.11.2
Dynamic linker (ldd)   2.11.2
Procps                 3.2.8
Kbd                    1.15
Sh-utils               8.5
Modules Loaded         r8192se_pci vboxnetadp vboxnetflt vboxdrv

If you need any more information, please let me know.
Thanks,
-- Morgon

PS: My apologies if the bug format is bad or sent to the wrong place, this is 
the first time I've submitted a bug to for the kernel.

--Boundary-00=_avXZMuUnIDaVYxs
Content-Type: application/octet-stream;
  name="packet1189641421"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="packet1189641421"

RQAAPAAAAAA/BveYwKgBa8CoAWgAGYOoNyNPc3CvGPegEhagGTAAAAIEBbQEAggK/////wAAAAAB
AwMF

--Boundary-00=_avXZMuUnIDaVYxs
Content-Type: text/x-csrc;
  charset="ISO-8859-1";
  name="testpacket.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="testpacket.c"

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <errno.h>

int main(int argc, char **argv) {
	const char *packet_file = argv[1];
	FILE *packet_stream = fopen(packet_file, "rb");
	unsigned char packet[60];
	int sock;
	int r;
	struct sockaddr_in target;
	struct iphdr *ip;

	fread(packet, 1, 60, packet_stream);
	ip = (struct iphdr *)packet;

	if(ip->id != 0) {
		puts("IP ID is non-zero.");
		return -1;
	}

	sock = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
	target.sin_family = AF_INET;
	target.sin_addr.s_addr = ip->daddr;
	r = sendto(sock, packet, 60, 0, (struct sockaddr *)&target, sizeof(struct sockaddr_in));
	if(r == -1)
		if(errno == EPERM)
			puts("Errno EPERM found!");
		else
			puts("Other errno found!");
	else
		printf("No errno found! r = %d\n", r);
	
	return 0;
}

--Boundary-00=_avXZMuUnIDaVYxs
Content-Type: application/octet-stream;
  name="strange_packet.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="strange_packet.pcap"

1MOyoQIABAAAAAAAAAAAAP//AABxAAAA5G5lTGuFCABMAAAATAAAAAAEAAEABpBM5eE85AAACABF
AAA8AAMAAD8G95XAqAFrwKgBaAAZg6I3I09vcK8Y/KASFqAMMgAAAgQFtAQCCAr/////AwMKAAED
AwU=

--Boundary-00=_avXZMuUnIDaVYxs--
