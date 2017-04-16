From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Sat, 15 Apr 2017 20:23:31 -0600
Message-ID: <2b582c01f3d2e265cf94bc89d0346a5b@codeaurora.org>
References: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
 <479839ac1ff57240a61f43d7b128a2a3@codeaurora.org>
 <1f3828b5-6fce-ac9c-6be0-80352aef06de@cumulusnetworks.com>
 <20170415.094810.1393827754237126920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:32820 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754504AbdDPCXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 22:23:32 -0400
In-Reply-To: <20170415.094810.1393827754237126920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> It should be fixed for 4.12. Basically, __udp6_lib_demux_lookup needs 
>> to
>> be more like __udp4_lib_demux_lookup

Hi David

Would it be possible for you to test this with udp_l3mdev_accept=0

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b793ed1..0e307e5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -46,6 +46,7 @@
  #include <net/tcp_states.h>
  #include <net/ip6_checksum.h>
  #include <net/xfrm.h>
+#include <net/inet_hashtables.h>
  #include <net/inet6_hashtables.h>
  #include <net/busy_poll.h>
  #include <net/sock_reuseport.h>
@@ -864,21 +865,25 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct 
udp_table *udptable,
         return 0;
  }

+
  static struct sock *__udp6_lib_demux_lookup(struct net *net,
                         __be16 loc_port, const struct in6_addr 
*loc_addr,
                         __be16 rmt_port, const struct in6_addr 
*rmt_addr,
                         int dif)
  {
+       unsigned short hnum = ntohs(loc_port);
+       unsigned int hash2 = udp6_portaddr_hash(net, loc_addr, hnum);
+       unsigned int slot2 = hash2 & udp_table.mask;
+       struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
+       const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
         struct sock *sk;

-       rcu_read_lock();
-       sk = __udp6_lib_lookup(net, rmt_addr, rmt_port, loc_addr, 
loc_port,
-                              dif, &udp_table, NULL);
-       if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
-               sk = NULL;
-       rcu_read_unlock();
-
-       return sk;
+       udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
+               if (INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, 
dif))
+                       return sk;
+               break;
+       }
+       return NULL;
  }

  static void udp_v6_early_demux(struct sk_buff *skb)
