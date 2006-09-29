From: Peter Bieringer <pb@bieringer.de>
Subject: lifetime of IPv6 tempaddr is limited to lifetime specified in router
 advertisements: address lost while SSH connection is still established
Date: Fri, 29 Sep 2006 13:52:02 +0200
Message-ID: <451D08E2.9060106@bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay.aerasec.de ([212.18.21.178]:3043 "EHLO
	smtp1.aerasec.de") by vger.kernel.org with ESMTP id S1750774AbWI2LwI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 07:52:08 -0400
To: usagi-users@linux-ipv6.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

running kernel-2.6.17-1.2187_FC5 and using

net.ipv6.conf.default.use_tempaddr = 2 in /etc/sysctl.conf

results in enabling and prefered use of temporary IPv6 addresses as
expected.


Current related sysctl values are:

# sysctl -a |grep temp_
net.ipv6.conf.eth0.temp_prefered_lft = 86400
net.ipv6.conf.eth0.temp_valid_lft = 604800
net.ipv6.conf.default.temp_prefered_lft = 86400
net.ipv6.conf.default.temp_valid_lft = 604800
net.ipv6.conf.all.temp_prefered_lft = 86400
net.ipv6.conf.all.temp_valid_lft = 604800
net.ipv6.conf.lo.temp_prefered_lft = 86400
net.ipv6.conf.lo.temp_valid_lft = 604800


But now strange things happen. It looks like that the prefered_lft is
not used because of receiving router advertisements (imho a normal
scenario).

Router advertisements have
	valid time 3000s, pref. time 2000s


Current available addresses:

# ip -6 addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
    inet6 2001:db8:0:0:f0fc:f50b:3cb1:cfea/64 scope global secondary dynamic
       valid_lft 2047sec preferred_lft 1047sec
    inet6 2001:db8:0:0:a963:ce7f:8e4e:fdf2/64 scope global secondary
deprecated dynamic
       valid_lft 265sec preferred_lft -735sec
    inet6 2001:db8:0:0:201:3ff:fe33:23c9/64 scope global dynamic
       valid_lft 2555sec preferred_lft 1555sec
    inet6 fe80::201:3ff:fe01:2345/64 scope link
       valid_lft forever preferred_lft forever


Established TCP sessions:

# lsof -n -i :22
COMMAND   PID  USER   FD   TYPE DEVICE SIZE NODE NAME
sshd     1613  root    3u  IPv6   4777       TCP *:ssh (LISTEN)
ssh     15606 peter    3u  IPv6 153678       TCP
[2001:db8:0:0:d45e:37d7:616d:99a]:55953->[2001:dba:0:1::164:1]:ssh
(ESTABLISHED)

As you see, the source address "2001:db8:0:0:d45e:37d7:616d:99a" do no
longer appear in interface address list.


So it looks like that if lifetime from router advertisment limits the
lifetime of the temporary address, but there is an update mechanism
missing which extends the lifetime of this temporary address (up to the
sysctl limit), if a next router advertisement is received.

Also it should not happen that the address is removed completly in case
it's still used in an open socket.


Is this a (known) bug or a (strange) feature or already fixed in 2.6.18?


Thank you very much.

Regards,
	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889
