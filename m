From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v2] ipv6: fix ipv6_cow_metrics for non DST_HOST case
Date: Thu, 12 Feb 2015 16:14:08 -0800
Message-ID: <1423786448-1158200-1-git-send-email-kafai@fb.com>
References: <1423771650-870555-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38326 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbbBMAOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 19:14:12 -0500
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t1D0APv4020055
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 16:14:11 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1sh2vd8w9d-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 16:14:11 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 3af021e6b31511e4a9a40002c95209d8-585d4390 for <netdev@vger.kernel.org>;	Thu,
 12 Feb 2015 16:14:09 -0800
In-Reply-To: <1423771650-870555-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_cow_metrics() currently assumes only DST_HOST routes require
dynamic metrics allocation from inetpeer.  The assumption breaks
when ndisc discovered router with RTAX_MTU and RTAX_HOPLIMIT metric.
Refer to ndisc_router_discovery() in ndisc.c and note that dst_metric_set()
is called after the route is created.

This patch creates the metrics array (by calling dst_cow_metrics_generic) in
ipv6_cow_metrics().

Test:
radvd.conf:
interface qemubr0
{
	AdvLinkMTU 1300;
	AdvCurHopLimit 30;

	prefix fd00:face:face:face::/64
	{
		AdvOnLink on;
		AdvAutonomous on;
		AdvRouterAddr off;
	};
};

Before:
[root@qemu1 ~]# ip -6 r show | egrep -v unreachable
fd00:face:face:face::/64 dev eth0  proto kernel  metric 256  expires 27sec
fe80::/64 dev eth0  proto kernel  metric 256
default via fe80::74df:d0ff:fe23:8ef2 dev eth0  proto ra  metric 1024  expires 27sec

After:
[root@qemu1 ~]# ip -6 r show | egrep -v unreachable
fd00:face:face:face::/64 dev eth0  proto kernel  metric 256  expires 27sec mtu 1300
fe80::/64 dev eth0  proto kernel  metric 256  mtu 1300
default via fe80::74df:d0ff:fe23:8ef2 dev eth0  proto ra  metric 1024  expires 27sec mtu 1300 hoplimit 30

Fixes: 8e2ec639173f325 (ipv6: don't use inetpeer to store metrics for routes.)
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 98565ce..4688bd4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -141,7 +141,7 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	u32 *p = NULL;
 
 	if (!(rt->dst.flags & DST_HOST))
-		return NULL;
+		return dst_cow_metrics_generic(dst, old);
 
 	peer = rt6_get_peer_create(rt);
 	if (peer) {
-- 
1.8.1
