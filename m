From: Wichert Akkerman <wichert@wiggy.net>
Subject: sendmsg ignoring bind?
Date: Fri, 20 May 2005 10:18:05 +0200
Message-ID: <20050520081805.GR25658@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After moving a RADIUS server from a machine running 2.6.8.1 to
to another host running 2.6.11.9 yesterday things suddenly
broke: proxy requests were send from the wrong IP address.

Here is the network configuration:

1: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:13:21:b3:ba:ef brd ff:ff:ff:ff:ff:ff
    inet 212.123.202.85/26 brd 212.123.202.127 scope global eth0
    inet 212.123.202.78/26 scope global secondary eth0
    inet 212.123.202.70/26 scope global secondary eth0
    inet 212.123.202.73/26 scope global secondary eth0
    inet 212.123.202.76/26 scope global secondary eth0
    inet 212.123.202.74/26 scope global secondary eth0
    inet6 2001:960:6a6:2:213:21ff:feb3:baef/64 scope global dynamic
       valid_lft 2591728sec preferred_lft 604528sec
    inet6 fe80::213:21ff:feb3:baef/64 scope link
       valid_lft forever preferred_lft forever

This is an strace of the relevant code:

socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
setsockopt(7, SOL_IP, IP_PKTINFO, [1], 4) = 0
bind(7, {sa_family=AF_INET, sin_port=htons(1814),
          sin_addr=inet_addr("212.123.202.74")}, 16) = 0
sendmsg(7, {msg_name(16)={sa_family=AF_INET, sin_port=htons(1812),
	sin_addr=inet_addr("212.100.254.89")},
	msg_iov(1)=[{"....", 249}], msg_controllen=24, {cmsg_len=24,
	cmsg_level=SOL_IP, cmsg_type=, ...}, msg_flags=0}, 0) = 249

One would expect that packet to be send from 212.123.202.74, but instead
it is send using the machine's primary IP address 212.123.202.85. As a
temporary workaround I added routes for the relevant targets that
explicitly set the src to 212.123.202.74.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
