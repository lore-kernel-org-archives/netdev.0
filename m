From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: [PATCH RESEND v2] ipv4: Do not cache routing failures due to disabled forwarding.
Date: Thu, 30 Oct 2014 10:09:53 +0100
Message-ID: <1414660193-4177-1-git-send-email-nicolas.cavallari@green-communications.fr>
References: <20141029.150328.530876391340346443.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029.150328.530876391340346443.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we cache them, the kernel will reuse them, independently of
whether forwarding is enabled or not.  Which means that if forwarding is
disabled on the input interface where the first routing request comes
from, then that unreachable result will be cached and reused for
other interfaces, even if forwarding is enabled on them.  The opposite
is also true.

This can be verified with two interfaces A and B and an output interface
C, where B has forwarding enabled, but not A and trying
ip route get $dst iif A from $src && ip route get $dst iif B from $src

Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Reviewed-by: Julian Anastasov <ja@ssi.bg>
---
> Sorry Nicolas, this seems to have fallen on the floor.  Could you please
> resubmit your most uptodate version of this patch so I can apply it?

Here you are.

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2d4ae46..6a2155b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1798,6 +1798,7 @@ local_input:
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
 	res.type = RTN_UNREACHABLE;
+	res.fi = NULL;
 	goto local_input;
 
 	/*
-- 
2.1.1
