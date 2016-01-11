From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] udp: disallow UFO for sockets with SO_NO_CHECK option
Date: Mon, 11 Jan 2016 07:50:30 +0100 (CET)
Message-ID: <20160111065030.F3FFCA0EF1@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit acf8dd0a9d0b ("udp: only allow UFO for packets from SOCK_DGRAM
sockets") disallows UFO for packets sent from raw sockets. We need to do
the same also for SOCK_DGRAM sockets with SO_NO_CHECK options, even if
for a bit different reason: while such socket would override the
CHECKSUM_PARTIAL set by ip_ufo_append_data(), gso_size is still set and
bad offloading flags warning is triggered in __skb_gso_segment().

In the IPv6 case, SO_NO_CHECK option is ignored but we need to disallow
UFO for packets sent by sockets with UDP_NO_CHECK6_TX option.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Tested-by: Shannon Nelson <shannon.nelson@intel.com>
---
 net/ipv4/ip_output.c  | 2 +-
 net/ipv6/ip6_output.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe47052..36ac9f3a6451 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -921,7 +921,7 @@ static int __ip_append_data(struct sock *sk,
 	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
-	    (sk->sk_type == SOCK_DGRAM)) {
+	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
 					 maxfraglen, flags);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e6a7bd15b9b7..6473889f1736 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1353,7 +1353,7 @@ emsgsize:
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) &&
-	    (sk->sk_type == SOCK_DGRAM)) {
+	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen,
 					  transhdrlen, mtu, flags, fl6);
-- 
2.7.0
