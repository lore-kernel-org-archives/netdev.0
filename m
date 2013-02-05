From: Carl Baldwin <carl@ecbaldwin.net>
Subject: PMTU discovery is updating route's MTU with per-route mtu lock
Date: Mon, 4 Feb 2013 17:59:06 -0700
Message-ID: <CALiLy7oUyxZ=DbXcZvHg141eQ3-WYJrsoRBwaZDVxDfsUufctQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:43068 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab3BEA71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 19:59:27 -0500
Received: by mail-qc0-f174.google.com with SMTP id z24so2915136qcq.33
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 16:59:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

Let me lay down a little context.  I am using the 3.2.0 kernel on
Ubuntu 12.04 64 bit.  I have repeated the issue with 3.5.0 on 12.10 as
well.  My eth0 has mtu set to 9000 so that a vlan interface,
vlan331@eth0 can have mtu set at 9000.

# ip addr show eth0 | head -n 1
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast
state UP qlen 1000

I have attempted to set the mtu on the link local route through eth0
to 1500 using the "mtu lock 1500" option to "ip route."

# ip route show dev eth0
default via 192.168.122.1  metric 100
192.168.122.0/24  proto kernel  scope link  src 192.168.122.160  mtu lock 1500

At first, this appears to work as shown by this output:

# ping -c 2 -s $((9000-28)) -M do 192.168.122.251
PING 192.168.122.251 (192.168.122.251) 8972(9000) bytes of data.
>From 192.168.122.160 icmp_seq=1 Frag needed and DF set (mtu = 1500)
>From 192.168.122.160 icmp_seq=1 Frag needed and DF set (mtu = 1500)

However, after some time, usually 10-15 minutes, it seems that PMTU
discovery updates the MTU on this route and the ICMP packets from the
command above is allowed through.  "ip route show" still shows the mtu
lock option is set on the route.  My understanding from the ip command
documentation is that PMTUD shouldn't touch this route because I have
used the lock keyword.

Any help or insight would be greatly appreciated.  Is there something
that I'm missing?  Is my expectation incorrect?

Cheers,
Carl



PS  Here are a few things that I've tried:

I disabled path mtu discovery by setting the sysctl
"net.ipv4.ip_no_pmtu_disc=1."  This appears to prevent the updating of
the mtu on the route even after waiting some time.  I did this mostly
to prove to myself that it was, in fact, pmtu discovery running that
is starting the problem.  However, I do not fully understand the
implications of disabling PMTU entirely and I am reluctant to pursue
that course.

I found a very recent commit to Linus's tree:  commit
fa1e492aa3cbafba9f8fc6d05e5b08a3091daf4a.  This appeared to be
targeting this very problem.  I tried an admittedly naive backport of
this fix to my 3.2.0 kernel and built and installed it.  It did not
fix the problem for me.  My constraints are such that I cannot use the
most recent kernel.  I will need to figure out how to properly
backport this fix to 3.2.0.  Here was my naive backport:

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94cdbc5..6fd8af2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1760,6 +1760,9 @@ static void ip_rt_update_pmtu(struct dst_entry
*dst, u32 mtu)
  struct rtable *rt = (struct rtable *) dst;
  struct inet_peer *peer;

+ if (dst_metric_locked(dst, RTAX_MTU))
+ return;
+
  dst_confirm(dst);

  if (!rt->peer)
