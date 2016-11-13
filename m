From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ip6_output: ensure flow saddr actually belongs
	to device
Date: Sun, 13 Nov 2016 14:23:47 +0100
Message-ID: <20161113132347.17907-1-Jason@zx2c4.com>
References: <CAHmME9qYYU-p5BhR0ReNSB+__wysuDK+eEk1SisCoyf4=2woxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9qYYU-p5BhR0ReNSB+__wysuDK+eEk1SisCoyf4=2woxg@mail.gmail.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

This puts the IPv6 routing functions in parity with the IPv4 routing
functions. Namely, we now check in v6 that if a flowi6 requests an
saddr, the returned dst actually corresponds to a net device that has
that saddr. This mirrors the v4 logic with __ip_dev_find in
__ip_route_output_key_hash. In the event that the returned dst is not
for a dst with a dev that has the saddr, we return -EINVAL, just like
v4; this makes it easy to use the same error handlers for both cases.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/ip6_output.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..a834129 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1011,6 +1011,11 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 		}
 	}
 #endif
+	if (!ipv6_addr_any(&fl6->saddr) &&
+	    !ipv6_chk_addr(net, &fl6->saddr, (*dst)->dev, 1)) {
+		err = -EINVAL;
+		goto out_err_release;
+	}
 
 	return 0;
 
-- 
2.10.2
