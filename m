From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 13/14] ipvs: fix info leak in getsockopt(IP_VS_SO_GET_TIMEOUT)
Date: Wed, 15 Aug 2012 23:31:56 +0200
Message-ID: <1345066317-22512-14-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If at least one of CONFIG_IP_VS_PROTO_TCP or CONFIG_IP_VS_PROTO_UDP is
not set, __ip_vs_get_timeouts() does not fully initialize the structure
that gets copied to userland and that for leaks up to 12 bytes of kernel
stack. Add an explicit memset(0) before passing the structure to
__ip_vs_get_timeouts() to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 84444dd..72bf32a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2759,6 +2759,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
+		memset(&t, 0, sizeof(t));
 		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
-- 
1.7.10.4
