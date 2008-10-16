From: Nick 'Zaf' Clifford <zaf@nrc.co.nz>
Subject: PMTU with SA
Date: Thu, 16 Oct 2008 22:37:55 +1300
Message-ID: <48F70B73.2080802@nrc.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx8.orcon.net.nz ([219.88.242.58]:57879 "EHLO mx8.orcon.net.nz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbYJPKZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 06:25:09 -0400
Received: from Debian-exim by mx8.orcon.net.nz with local (Exim 4.69)
	(envelope-from <zaf@nrc.co.nz>)
	id 1KqPIr-0006DU-BI
	for netdev@vger.kernel.org; Thu, 16 Oct 2008 22:37:57 +1300
Received: from cerberus.nrc.co.nz ([121.98.166.152])
	by mx8.orcon.net.nz with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <zaf@nrc.co.nz>)
	id 1KqPIq-0006Cw-Vz
	for netdev@vger.kernel.org; Thu, 16 Oct 2008 22:37:57 +1300
Received: from [2001:4428:202:1:216:17ff:fed4:fc99]
	by cerberus.nrc.co.nz with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <zaf@nrc.co.nz>)
	id 1KqPIq-00076H-5z
	for netdev@vger.kernel.org; Thu, 16 Oct 2008 22:37:56 +1300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this isn't the correct list, please let me know, and please CC me on
replies as I'm not subscribed. I will try to read the archives for a few
days in case I miss something.

I have an IPSEC transport mode link set up between a (local) Linux
router and a remote node. All works fine normally, and always from on
the router itself.

The issue comes with clients behind the router, attempting to access the
remote node. They experience an MTU issue with large packets. The linux
router does not send the icmp frag needed messages for DF packets that
are >1442 bytes and <1492 bytes. (The outgoing link's MTU is 1492). (If
the packets are >1492, then it correctly generates and returns a frag
needed).

In the linux router's kernel log, it is logging "pmtu discovery on SA
ESP/xxxx/xxxx".

I think the issue appears to be that the ICMP frag needed message is not
generated, or not sent back out to the client behind the Linux router.

When attempting to send packets ON the linux router, it correctly
handles it (ping returns "sendmsg: Message too long").

To clarify the network layout, there is the Linux router, with a IPSEC
transport mode NETKEY encryption to a particular destination. Then there
are NAT'd clients behind the router, who wish to connect to this
destination. They don't know, nor care that the connection goes via the
Internet wrapped in transport mode encryption.

A few examples:
On the internal client:
//Works
$ ping -M do -s 1414 203.109.246.49 -c 1 -n
PING (203.109.246.49) 1414(1442) bytes of data.
1422 bytes from 203.109.246.49 icmp_seq=1 ttl=53 time=90.6 ms

--- qvr.co.nz ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 90.661/90.661/90.661/0.000 ms

//Doesn't
$ ping -M do -s 1415 203.109.246.49 -c 1
PING qvr.co.nz (203.109.246.49) 1415(1443) bytes of data.

--- qvr.co.nz ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms


On the router (eth1 is the internal interface, hence why its not
encrypted, eth0 is rather boring):
$ tcpdump -i eth1 -n icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
22:10:01.986871 IP 10.42.0.11 > 203.109.246.49: ICMP echo request, id
10090, seq 1, length 1422
22:10:02.073945 IP 203.109.246.49 > 10.42.0.11: ICMP echo reply, id
10090, seq 1, length 1422

22:10:12.540799 IP 10.42.0.11 > 203.109.246.49: ICMP echo request, id
53609, seq 1, length 1423
^C

$ tail /var/log/kern.log -n 1
Oct 16 22:10:12 cerberus kernel: [4903404.569127] pmtu discovery on SA
ESP/0d317d2d/cb6df631



For further info if needed:
Tunnels are set up using openswan in transport mode, using NETKEY
OpenSwan 2.4.9
Running 2.6.26 stock standard.

# ip xfrm state
src 203.109.246.49 dst 121.98.166.152
    proto esp spi 0x192bd540 reqid 16385 mode transport
    replay-window 32
    auth hmac(sha1) 0x4ccf..........
    enc cbc(aes) 0x480c.........
    sel src 0.0.0.0/0 dst 0.0.0.0/0
src 121.98.166.152 dst 203.109.246.49
    proto esp spi 0xc32a08e0 reqid 16385 mode transport
    replay-window 32
    auth hmac(sha1) 0x1cf8............
    enc cbc(aes) 0xdbb1..........
    sel src 0.0.0.0/0 dst 0.0.0.0/0
src 203.109.246.49 dst 121.98.166.152
    proto esp spi 0xf0fb36d4 reqid 16385 mode transport
    replay-window 32
    auth hmac(sha1) 0x1c47.......
    enc cbc(aes) 0x499............
    sel src 0.0.0.0/0 dst 0.0.0.0/0
src 121.98.166.152 dst 203.109.246.49
    proto esp spi 0x0d317d2d reqid 16385 mode transport
    replay-window 32
    auth hmac(sha1) 0x5fbd..........
    enc cbc(aes) 0x1564............
    sel src 0.0.0.0/0 dst 0.0.0.0/0


I can also give full network diagrams, etc, if required.


Thanks,

Nick

