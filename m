From: Vincent Li <vincent.mc.li@gmail.com>
Subject: is printk proper tool to trace code path in net code ?
Date: Fri, 7 Mar 2014 16:09:14 -0800
Message-ID: <CAK3+h2xOJnxKrHvcmxzzAGoT-ZZuSpzFhMCcD5+iTY6aepVmDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:34637 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbaCHAJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 19:09:15 -0500
Received: by mail-oa0-f49.google.com with SMTP id g12so4850076oah.22
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 16:09:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am still trying to trace a potential kernel bug selecting wrong
source ip 127.0.0.1 when there is route proper route table in kernel
on centos 2.6.32 based kernel

http://www.spinics.net/lists/netdev/msg271050.html

 and here I am trying to use printk to understand a code path of
kernel selecting source ip logic

I am only doing printk when the destination ip matches my input ip
'myip', I want to know if I am doing something stupid that could crash
kernel, cause I did see get a kernel panic when I put printk in
ip_route_output_slow() routine during reboot. but only see once so
far.


[root@vincent-centos64 kernel]# git diff net/ipv4/tcp_ipv4.c
diff --git a/kernel/net/ipv4/tcp_ipv4.c b/kernel/net/ipv4/tcp_ipv4.c
index f43a3b3..8f41d46 100644
--- a/kernel/net/ipv4/tcp_ipv4.c
+++ b/kernel/net/ipv4/tcp_ipv4.c
@@ -152,6 +152,7 @@ int tcp_v4_connect(struct sock *sk, struct
sockaddr *uaddr, int addr_len)
        __be32 daddr, nexthop;
        int tmp;
        int err;
+       u32 myip = 167921763;

        if (addr_len < sizeof(struct sockaddr_in))
                return -EINVAL;
@@ -166,6 +167,14 @@ int tcp_v4_connect(struct sock *sk, struct
sockaddr *uaddr, int addr_len)
                nexthop = inet->opt->faddr;
        }

+       if (ntohl(nexthop) == myip ) {
+               printk(KERN_INFO "%s:%d - %s()  (%pI4, %d)->(%pI4, %d)\n",
+                               __FILE__, __LINE__, __FUNCTION__,
+                               &inet->saddr, ntohs(inet->sport),
+                               &nexthop, ntohs(usin->sin_port));
+       }
+
+
        tmp = ip_route_connect(&rt, nexthop, inet->saddr,
                               RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
                               IPPROTO_TCP,
@@ -230,6 +239,13 @@ int tcp_v4_connect(struct sock *sk, struct
sockaddr *uaddr, int addr_len)
        if (err)
                goto failure;

+        if (ntohl(inet->daddr) == myip ) {
+                printk(KERN_INFO "%s:%d - %s()  (%pI4, %d)->(%pI4, %d)\n",
+                                __FILE__, __LINE__, __FUNCTION__,
+                               &inet->saddr, ntohs(inet->sport),
+                               &inet->daddr, ntohs(inet->dport));
+        }
+
        err = ip_route_newports(&rt, IPPROTO_TCP,
                                inet->sport, inet->dport, sk);
        if (err)


[root@vincent-centos64 kernel]# git diff include/net/route.h
diff --git a/kernel/include/net/route.h b/kernel/include/net/route.h
index f494b24..85ef3e5 100644
--- a/kernel/include/net/route.h
+++ b/kernel/include/net/route.h
@@ -161,6 +161,7 @@ static inline int ip_route_connect(struct rtable
**rp, __be32 dst,

        int err;
        struct net *net = sock_net(sk);
+       u32 myip = 167921763;

        if (inet_sk(sk)->transparent)
                fl.flags |= FLOWI_FLAG_ANYSRC;
@@ -174,6 +175,14 @@ static inline int ip_route_connect(struct rtable
**rp, __be32 dst,
                ip_rt_put(*rp);
                *rp = NULL;
        }
+       if (ntohl(fl.fl4_dst) == myip ) {
+
+               printk(KERN_INFO "%s:%d - %s()  (%pI4, %d)->(%pI4, %d)\n",
+                               __FILE__, __LINE__, __FUNCTION__,
+                              &fl.fl4_src, ntohs(fl.fl_ip_sport),
+                               &fl.fl4_dst, ntohs(fl.fl_ip_dport));
+       }
+
        security_sk_classify_flow(sk, &fl);
        return ip_route_output_flow(net, rp, &fl, sk, flags);
 }

[root@vincent-centos64 kernel]# git diff net/ipv4/route.c
diff --git a/kernel/net/ipv4/route.c b/kernel/net/ipv4/route.c
index 5eef4e1..721b54d 100644
--- a/kernel/net/ipv4/route.c
+++ b/kernel/net/ipv4/route.c
@@ -2494,6 +2494,7 @@ static int ip_route_output_slow(struct net *net,
struct rtable **rp,
        int free_res = 0;
        int err;

+        printk(KERN_INFO "%s:%d - %s() ", __FILE__, __LINE__, __FUNCTION__);

        res.fi          = NULL;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -2679,6 +2680,7 @@ int __ip_route_output_key(struct net *net,
struct rtable **rp,
 {
        unsigned hash;
        struct rtable *rth;
+       u32 myip = 167921763;

        if (!rt_caching(net))
                goto slow_output;
@@ -2701,6 +2703,16 @@ int __ip_route_output_key(struct net *net,
struct rtable **rp,
                        RT_CACHE_STAT_INC(out_hit);
                        rcu_read_unlock_bh();
                        *rp = rth;
+                       if (ntohl((*rp)->rt_dst) == myip ) {
+                               printk(KERN_INFO "%s:%d - %s()  (%pI4,
%d)->(%pI4, %d) dev %s oif %d\n",
+                                       __FILE__, __LINE__, __FUNCTION__,
+                                       &(*rp)->rt_src,
ntohs((*rp)->fl.fl_ip_sport),
+                                               &(*rp)->rt_dst,
ntohs((*rp)->fl.fl_ip_dport),
+                                               //&(*rp)->rt_dst,
ntohs(flp->fl_ip_dport),
+                                       (*rp)->u.dst.dev->name, flp->oif
+                               );
+                       }
+
                        return 0;
                }
                RT_CACHE_STAT_INC(out_hlist_search);


[root@vincent-centos64 kernel]# git diff net/ipv4/devinet.c
diff --git a/kernel/net/ipv4/devinet.c b/kernel/net/ipv4/devinet.c
index f84f6dd..f9963e3 100644
--- a/kernel/net/ipv4/devinet.c
+++ b/kernel/net/ipv4/devinet.c
@@ -859,12 +859,21 @@ __be32 inet_select_addr(const struct net_device
*dev, __be32 dst, int scope)
        __be32 addr = 0;
        struct in_device *in_dev;
        struct net *net = dev_net(dev);
+       u32 myip = 167921763;

        rcu_read_lock();
        in_dev = __in_dev_get_rcu(dev);
+
        if (!in_dev)
                goto no_in_dev;

+        if (ntohl(dst) == myip ) {
+                printk(KERN_INFO "%s:%d - %s()  in_dev %s, dst %pI4\n",
+                           __FILE__, __LINE__, __FUNCTION__,
+                               in_dev->dev->name, &dst
+                  );
+       }
+
        for_primary_ifa(in_dev) {
                if (ifa->ifa_scope > scope)
                        continue;
