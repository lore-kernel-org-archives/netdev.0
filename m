From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] Check if user has CAP_NET_ADMIN to change congestion control algorithm
Date: Fri, 27 Oct 2006 01:52:56 +0200
Message-ID: <20061026235256.GB2018@c3po.0xdef.net>
References: <20061025110843.0cbd18a7@freekitty> <4540F076.70801@psc.edu> <20061026224407.GA2018@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:42246 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S1423529AbWJZXw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:52:57 -0400
To: Hagen Paul Pfeifer <hagen@jauu.net>,
	John Heffner <jheffner@psc.edu>,
	Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061026224407.GA2018@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Check if user has CAP_NET_ADMIN capability to change congestion control
algorithm.

Under normal circumstances a application programmer doesn't have enough
information to choose the "right" algorithm (expect he is the pchar/pathchar
maintainer). At 99.9% only the local host administrator has the knowledge to
select a proper standard, system-wide algorithm (the remaining 0.1% are
for testing purpose). If we let the user select an alternative algorithm we
introduce one potential weak spot - so we ban this eventuality.

HGN


Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index af0aca1..c1ae2e9 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -10,6 +10,7 @@ #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/types.h>
 #include <linux/list.h>
+#include <linux/capability.h>
 #include <net/tcp.h>

 static DEFINE_SPINLOCK(tcp_cong_list_lock);
@@ -151,6 +152,9 @@ int tcp_set_congestion_control(struct so
        struct tcp_congestion_ops *ca;
        int err = 0;

+       if (!capable(CAP_NET_ADMIN))
+               return -EPERM;
+
        rcu_read_lock();
        ca = tcp_ca_find(name);
        if (ca == icsk->icsk_ca_ops)
