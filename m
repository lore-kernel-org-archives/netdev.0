From: Tushar Shinde <mtk.tushar@gmail.com>
Subject: IPv6 Policy based routing not working.
Date: Tue, 26 Aug 2014 21:32:12 +0530
Message-ID: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f66.google.com ([74.125.82.66]:37837 "EHLO
	mail-wg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbaHZQCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 12:02:13 -0400
Received: by mail-wg0-f66.google.com with SMTP id a1so4896039wgh.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:02:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello NetDev,

I am facing problem where if ipv6 route (outside to current subnet) is
reachable only if route is present in main table. Policy based routes
are not working.

Following is my setup,

eth0   inet6 2001:1::10/120 scope global
eth1   inet6 2001:1::11/120 scope global
2001:1::1 is gateway
2.6.32-431.11.2.el6.x86_64 kernel (I tried on 3.x also)

[root@ipv6node1 ~]# ip -6 route show tab 1
2001:1::/120 dev eth0  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
default via 2001:1::1 dev eth0  metric 1024  mtu 1500 advmss 1440
hoplimit 4294967295
[root@ipv6node1 ~]#
[root@ipv6node1 ~]# ip -6 route show tab 2
2001:1::/120 dev eth1  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
default via 2001:1::1 dev eth1  metric 1024  mtu 1500 advmss 1440
hoplimit 4294967295
[root@ipv6node1 ~]#
[root@ipv6node1 ~]# ip -6 rule show
0:    from all lookup local
16383:    from 2001:1::10 lookup 1
16383:    from 2001:1::11 lookup 2
32766:    from all lookup main
[root@ipv6node1 ~]#

If I add default vai eth0 only ip of eth0 is reachable from outside or
eth1 dont work. In above setup default route is not present.

But default entry in "table" is never getting used to resolve route

[root@ipv6node1 ~]# ping6 -I eth0 2001:2::20
connect: Network is unreachable
[root@ipv6node1 ~]#
[root@ipv6node1 ~]# ping6 -I eth1 2001:2::20
connect: Network is unreachable
[root@ipv6node1 ~]#


To dig further I added printks and found fib6_rule_match function
return 1 only for table 255 and 254 rest all tables are skipped from
search.

fib6_rule_match
if (r->src.plen) {
                if (flags & RT6_LOOKUP_F_HAS_SADDR) {
                        if (!ipv6_prefix_equal(&fl->fl6_src, &r->src.addr,
                                               r->src.plen)) {
                                printk(KERN_ALERT "TS: %s:%d ret 0\n",
__func__, __LINE__);
                                return 0;
                        }
                } else if (!(r->common.flags & FIB_RULE_FIND_SADDR)) {
                        printk(KERN_ALERT "TS: %s:%d ret 0\n",
__func__, __LINE__);
           >>>             return 0;
                }
}

In case of above ping code returns from FIB_RULE_FIND_SADDR check as
pointed above.

In above case flags is 1, that is RT6_LOOKUP_F_IFACE.
Do I need to pass any extra option to ping?

Same routing table works in case of IPv4 setup without any problem.
Is policy based routing supported in ipv6?


Thank you,
Tushar
