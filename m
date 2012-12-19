From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Wed, 19 Dec 2012 17:10:24 +0400
Message-ID: <50D1BCC0.2000208@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:42092 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753060Ab2LSNUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 08:20:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On kernel 3.7.1 I get strange behaviour of IP_MTU_DISCOVER socket 
option. The behaviour in case of IP_PMTUDISC_DO and IP_PMTUDISC_WANT 
values of IP_MTU_DISCOVER socket option on SOCK_DGRAM socket are the 
same and packet is always sent with "Don't Fragment" bit in case of 
IP_PMTUDISC_WANT. Also, the value of IP_MTU socket option is not updated.

This can be reproduced with 3 hosts configuration. Let it be the hosts: 
host_A, host_B and host _C. host_A via interface eth1 connected with 
host_B via intefaces eth1. Let host_C via interface eth1 connected with 
host_B via interface eth2. Also Lets address 10.0.1.1/24 is assigned to 
eth1 on host_A; 10.0.1.2/24 is assigned to eth1 on host_B; 10.0.2.1/24 
is assigned to eth2 on host_B; 10.0.2.2/24 is assigned to eth1 on 
host_C. Also there are two routes: "10.0.2.2 via 10.0.1.2 dev eth1" on 
host_A and "10.0.1.1 via 10.0.2.1 dev eth1" on host_C. Also forwarding 
is on on host_B. So we have the following picture:

host_A-eth1(10.0.1.1)<-->(10.0.1.2)eth1-host_B-eth2(10.0.2.1)<-->(10.0.2.2)eth1-host_C

MTU is equal to 1500 on all involved interfaces. Then we make the 
followign steps:

on host_A:
1. socket(SOCK_DGRAM) -> 6
2. bind(6, 10.0.1.1:25630) -> 0
on host_C:
3. socket(SOCK_DGRAM) -> 5
4. bind(5, 10.0.2.2:25631) -> 0
on host_A:
5. connect(6, 10.0.2.2:25631) -> 0
on host_C:
6. connect(5, 10.0.1.1:25630) -> 0
on host_A
7. getsockopt(6,IP_MTU) -> 0 // Returns that MTU is 1500
8. getsockopt(6,IP_MTU_DISCOVER) -> 0 // Returns that default value is 
IP_PMTUDISC_WANT

On eth2 on host_B and on eth1 on host_C change MTU from 1500 to 750. 
Wait for a while.

9. send(6, lenght=1400) -> 1400 // the packet is sent with "Don't 
Fragment" bit, tcpdump on eth1 on host_B shows it
10. sleep(5);
11. send(6, length=1400) -> -1 with EMSGSIZE
12. sleep(5);
13. getsockopt(6,IP_MTU) -> 0 // Returns that MTU is 1500 once again. So 
value is not updated.
14. send(6, lenght=1400) -> 1400 // the packet one again is sent with 
"Don't Fragment" bit, tcpdump on eth1 on host_B shows it

So "Don't Fragment" bit is always set for the packets in case when value 
of IP_MTU_DISCOVER is IP_PMTUDISC_WANT. If at step 8 we change 
IP_MTU_DISCOVER value from IP_PMTUDISC_WANT to IP_PMTUDISC_DO we have 
the same picture. The value of IP_MTU socket options is still 1500 at 
step 13 in this case.
