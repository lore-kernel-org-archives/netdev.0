From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v3] ipv4: Make IP_MULTICAST_ALL and IP_MSFILTER work on raw
 sockets
Date: Wed, 23 Jul 2014 09:58:01 +0100
Message-ID: <1406105881.2990.60.camel@samson1.armitage.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"David S.Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, although IP_MULTICAST_ALL and IP_MSFILTER ioctl calls succeed on
raw sockets, there is no code to implement the functionality on received
packets; it is only implemented for UDP sockets. The raw(7) man page states:
"In addition, all ip(7) IPPROTO_IP socket options valid for datagram sockets
are supported", which implies these ioctls should work on raw sockets.

To fix this, add a call to ip_mc_sf_allow on raw sockets.

This should not break any existing code, since the current position of
not calling ip_mc_sf_filter makes it behave as if neither the IP_MULTICAST_ALL
nor the IP_MSFILTER ioctl had been called. Adding the call to ip_mc_sf_allow
will therefore maintain the current behaviour so long as IP_MULTICAST_ALL and
IP_MSFILTER ioctls are not called. Any code that currently is calling
IP_MULTICAST_ALL or IP_MSFILTER ioctls on raw sockets presumably is wanting
the filter to be applied, although no filtering will currently be occurring.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
v2: * Fixed subject line

v3: * Fix space/tab formatting. With apologies to all concerned.

---
 net/ipv4/raw.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2c65160..2e1628c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -58,6 +58,7 @@
 #include <linux/in_route.h>
 #include <linux/route.h>
 #include <linux/skbuff.h>
+#include <linux/igmp.h>
 #include <net/net_namespace.h>
 #include <net/dst.h>
 #include <net/sock.h>
@@ -174,7 +175,9 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 
 	while (sk) {
 		delivered = 1;
-		if (iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) {
+		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
+		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
+				   skb->dev->ifindex)) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
 			/* Not releasing hash table! */
-- 
1.7.7.6
