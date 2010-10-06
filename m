From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix sk_dst_check() to reset the obsolete
 dst_entry of a socket.
Date: Wed, 06 Oct 2010 00:35:41 -0700 (PDT)
Message-ID: <20101006.003541.71128466.davem@davemloft.net>
References: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi
To: cywang@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This should have been fixed by:

--------------------
commit ae2688d59b5f861dc70a091d003773975d2ae7fb
Author: Jianzhao Wang <jianzhao.wang@6wind.com>
Date:   Wed Sep 8 14:35:43 2010 -0700

    net: blackhole route should always be recalculated
    
    Blackhole routes are used when xfrm_lookup() returns -EREMOTE (error
    triggered by IKE for example), hence this kind of route is always
    temporary and so we should check if a better route exists for next
    packets.
    Bug has been introduced by commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92.
    
    Signed-off-by: Jianzhao Wang <jianzhao.wang@6wind.com>
    Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3f56b6e..6298f75 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2738,6 +2738,11 @@ slow_output:
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
+static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
+{
+	return NULL;
+}
+
 static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
@@ -2746,7 +2751,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.family			=	AF_INET,
 	.protocol		=	cpu_to_be16(ETH_P_IP),
 	.destroy		=	ipv4_dst_destroy,
-	.check			=	ipv4_dst_check,
+	.check			=	ipv4_blackhole_dst_check,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.entries		=	ATOMIC_INIT(0),
 };
