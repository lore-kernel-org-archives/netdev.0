From: Mazhar Rana <ranamazharp@gmail.com>
Subject: [PATCH ipv6 0/1] ipv6: addrconf: routes are not deleted if last ipv6 address is removed
Date: Thu, 18 Jun 2015 14:59:01 +0530
Message-ID: <1434619742-10423-1-git-send-email-ranamazharp@gmail.com>
Cc: Mazhar Rana <ranamazharp@gmail.com>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, sanket.saha@cyberoam.com,
	mazhar.rana@cyberoam.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

After 'commit 876fd05ddbae03166e7037fca957b55bb3be6594
("ipv6: don't disable interface if last ipv6 address is removed")'
it is not clearing ipv6 interface configurations(routes, neighbours,
etc) when last ipv6 address of interface is removed.

This is now creating functionality issue with below deployment.

On ubuntu 14.04 (upgraded with linux kernel 3.19)
eth1 GW1: 2604:2000:7000:2::102
eth0 GW2: 2001:df7:6000:101::1b:102

HostA: 3804:3000:1406:2::102 (reachable via GW1 and GW2 both)

In this deployment, HostA is reachable via eth0 and eth1. I prefer
that all traffic for HostA should go via GW1 which is available on 
link eth1. 

$ ip -6 ro s
2001:df7:6000:101::/64 dev eth0  proto kernel  metric 256 
2604:2000:7000:2::/64 dev eth1  proto kernel  metric 256 
3804:3000:1406:2::/64 via 2604:2000:7000:2::102 dev eth1  metric 1024 
fe80::/64 dev eth0  proto kernel  metric 256 
fe80::/64 dev eth1  proto kernel  metric 256 
default via 2001:df7:6000:101::1b:102 dev eth0  proto static  metric 1 

On failure of GW1 I removed all ipv6 address of eth1 so all traffic
should go through default gateway 'GW2'.

$ sudo ip -6 addr flush dev eth1
$ ip -6 ro s
2001:df7:6000:101::/64 dev eth0  proto kernel  metric 256 
3804:3000:1406:2::/64 via 2604:2000:7000:2::102 dev eth1  metric 1024 
fe80::/64 dev eth0  proto kernel  metric 256 
fe80::/64 dev eth0.100  proto kernel  metric 256 
default via 2001:df7:6000:101::1b:102 dev eth0  proto static  metric 1

But here, route for HostA is not deleted, so traffic for HostA is
still trying to go through GW1 which is not reachable anymore.

If 'commit 876fd05ddbae03166e7037fca957b55bb3be6594
("ipv6: don't disable interface if last ipv6 address is removed")'
is taken only for problem mention on changlog of that commit then 
here I have alternate proposal which will overcome both issue.

Do you see any side effect of this proposal?

Mazhar Rana (1):
  ipv6: addrconf: do addrconf_ifdown when last ipv6 address is removed

 net/ipv6/addrconf.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
1.9.1
