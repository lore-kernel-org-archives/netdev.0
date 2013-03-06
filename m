From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: kernel panic in fib6_age (linux-3.6.6) and sugguested fix
Date: Wed, 6 Mar 2013 23:36:08 +0800
Message-ID: <CAABZP2xs4qm7j75Hu5BaXuWOF3ddzrZPJxbTGhxpOvwHxA75Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:50204 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757845Ab3CFPgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 10:36:09 -0500
Received: by mail-pb0-f49.google.com with SMTP id xa12so6119907pbc.22
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 07:36:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,
  My linux-3.6.6 kernel panics very often during reboot.
  I have reported in bugzilla.kernel.org as bug id 54731.

Kernel panic backtrace (using remote gdb):
#0  0xffffffff8176a91a in fib6_age (rt=0xffff8800571c6780, arg=0x0
<irq_stack_union>) at net/ipv6/ip6_fib.c:1566
#1  0xffffffff8176a461 in fib6_clean_node (w=0xffff8800655fb4e8) at
net/ipv6/ip6_fib.c:1422
#2  0xffffffff8176a266 in fib6_walk_continue (w=0xffff8800655fb4e8) at
net/ipv6/ip6_fib.c:1362
#3  0xffffffff8176a3d5 in fib6_walk (w=0xffff8800655fb4e8) at
net/ipv6/ip6_fib.c:1406
#4  0xffffffff8176a59d in fib6_clean_tree (net=0xffffffff81edb300 <init_net>,
root=0xffff880036c41950
...
gdb>p neigh
(gdb) p neigh
$18 = (struct neighbour *) 0xffffffffffffff97



There are a lot of ipv6 nodes in my link local environment, and the kernel
report IPv6: Neighbour table overflow constantly.

I guess the cause of the panic is:
dst_neigh_lookup calls ip6_neigh_lookup indirectly, and neigh_create return
ENOBUFS in case of neighbour table full.
139 static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
140                                           struct sk_buff *skb,
141                                           const void *daddr)
142 {
143         struct rt6_info *rt = (struct rt6_info *) dst;
144         struct neighbour *n;
145
146         daddr = choose_neigh_daddr(rt, skb, daddr);
147         n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
148         if (n)
149                 return n;
150         return neigh_create(&nd_tbl, daddr, dst->dev);
151 }

A possible fix may be:

            neigh = dst_neigh_lookup(&rt->dst, &rt->rt6i_gateway);
+           if (IS_ERR(neigh))
+             return PTR_ERR(neigh);
            else{
                     neigh_flags = neigh->flags;
                     neigh_release(neigh);
            }

Thanks for your attention

Zhouyi
