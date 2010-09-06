From: Krzysztof Oledzki <ole@ans.pl>
Subject: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Mon, 6 Sep 2010 19:11:56 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-1310514681-1283793116=:20113"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:36731 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab0IFRep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 13:34:45 -0400
Received: from bizon.gios.gov.pl (ole@localhost6 [IPv6:::1])
	by bizon.gios.gov.pl (8.14.3/8.14.3) with ESMTP id o86HBuN6028800
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 6 Sep 2010 19:11:58 +0200
Received: from localhost (ole@localhost)
	by bizon.gios.gov.pl (8.14.3/8.14.3/Submit) with ESMTP id o86HBuQe028796
	for <netdev@vger.kernel.org>; Mon, 6 Sep 2010 19:11:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1310514681-1283793116=:20113
Content-Type: TEXT/PLAIN; format=flowed; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT

Hello,

For the last two days I have been trying to track a starange problem I 
bumped into after upgrading my kernel from 2.6.31.12 to 2.6.34.6.

The problem is that several times a day, nagios logs that plugins are not 
able to resolve DNS hostnames of monitored hosts. The DNS service is 
provided locally by the host itself so all traffic is handled over a 
loopback interface. The host handles rather moderate traffic - ~1000pps 
and ~30 DNS requests per second. This DNS service is also provided to 
other hosts that are also running 2.6.34.6 and are connected over a 
Ethernet network, but the problem exists only locally.

After a long investigation I found that I'm able to reproduce this problem 
by adding: "*.t IN A 127.0.0.1" to the "lan" zone and using the following 
script:

--- cut here ---
a=0
while strace -o /tmp/s.log.1 -s 1024  /usr/lib64/nagios/plugins/check_icmp -H $a.t.lan ; do
  date
  sleep 0.1
  a=$((a+1))
done
-- cut here ---

Strace shows that the problem is in receiving responses from the 
nameserver:

socket(PF_INET, SOCK_DGRAM|SOCK_NONBLOCK, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("192.168.130.53")}, 28) = 0
poll([{fd=4, events=POLLOUT}], 1, 0)    = 1 ([{fd=4, revents=POLLOUT}])
sendto(4, "\333b\1\0\0\1\0\0\0\0\0\0\0041817\1t\3lan\0\0\1\0\1", 28, MSG_NOSIGNAL, NULL, 0) = 28
poll([{fd=4, events=POLLIN}], 1, 5000)  = 0 (Timeout)
poll([{fd=4, events=POLLOUT}], 1, 0)    = 1 ([{fd=4, revents=POLLOUT}])
sendto(4, "\333b\1\0\0\1\0\0\0\0\0\0\0041817\1t\3lan\0\0\1\0\1", 28, MSG_NOSIGNAL, NULL, 0) = 28
poll([{fd=4, events=POLLIN}], 1, 5000)  = 0 (Timeout)
close(4)                                = 0

However, tcpdump attached to lo shows that both the request and 
the response are properly delivered:

03:00:47.181529 IP (tos 0x0, ttl 64, id 47869, offset 0, flags [DF], proto UDP (17), length 56)
     192.168.130.53.41083 > 192.168.130.53.53: 56162+ A? 1817.t.lan. (28)
03:00:47.181585 IP (tos 0x0, ttl 64, id 29563, offset 0, flags [none], proto UDP (17), length 112)
     192.168.130.53.53 > 192.168.130.53.41083: 56162* 1/1/1 1817.t.lan. A 127.0.0.1 (84)
--
03:00:52.186465 IP (tos 0x0, ttl 64, id 47870, offset 0, flags [DF], proto UDP (17), length 56)
     192.168.130.53.41083 > 192.168.130.53.53: 56162+ A? 1817.t.lan. (28)
03:00:52.186580 IP (tos 0x0, ttl 64, id 29576, offset 0, flags [none], proto UDP (17), length 112)
     192.168.130.53.53 > 192.168.130.53.41083: 56162* 1/1/1 1817.t.lan. A 127.0.0.1 (84)

03:00:57.298221 IP (tos 0x0, ttl 64, id 57985, offset 0, flags [DF], proto UDP (17), length 60)
     192.168.130.53.39370 > 192.168.130.53.53: 145+ A? 1817.t.lan.lan. (32)
03:00:57.298300 IP (tos 0x0, ttl 64, id 29584, offset 0, flags [none], proto UDP (17), length 116)
     192.168.130.53.53 > 192.168.130.53.39370: 145 NXDomain* 0/1/0 (88)

In most cases it takes from 2m to 15m to trigger this error and so far I 
have not been able to reproduce it on my lab environment. Downgrading 
the kernel back to 2.6.31 cures the issue.

I have a very short service window so bisecting is nearly impossible. 
During the next few days I should be able to find if this problem was 
introduced in 2.6.32 or 2.6.33, but if you have clues what to check first 
or idea about some smart debug patches, I will be very grateful.

Best regards,

 			Krzysztof Olêdzki
---1144830174-1310514681-1283793116=:20113--
