From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH v4] xfrm: take net hdr len into account for esp payload size calculation
Date: Thu, 24 May 2012 17:32:38 -0400
Message-ID: <1337895158-23521-1-git-send-email-bpoirier@suse.de>
References: <20120517.200509.2290282427866555176.davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Diego Beltrami <diego.beltrami@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120517.200509.2290282427866555176.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corrects the function that determines the esp payload size. The calculations
done in esp{4,6}_get_mtu() lead to overlength frames in transport mode for
certain mtu values and suboptimal frames for others.

According to what is done, mainly in esp{,6}_output() and tcp_mtu_to_mss(),
net_header_len must be taken into account before doing the alignment
calculation.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

---
Changes since v3:
* also fix ipv6

Changes since v2:
* rename l3_adj to net_adj
* fix indentation

Changes since v1:
* introduce l3_adj to preserve the same returned value as before for tunnel
  mode

For example:
* on ipv4 with md5 AH and 3des ESP (transport mode):
mtu = 1499 leads to FRAGFAILS
mtu = 1500 the addition of padding in the esp header could be avoided
* on ipv6 with md5 AH and twofish-sha1 ESP (transport mode):
mtu = 1491 leads to Ip6FragFails
mtu = 1499 padding can be avoided

For details on how the formula is established, see
https://lkml.org/lkml/2012/5/10/597

Tested with
* transport mode E
* transport mode EA
* transport mode E + ah
* tunnel mode E

Not tested with BEET, but it should be the same as transport mode
	draft-nikander-esp-beet-mode-03.txt Section 5.2:
	"The wire packet format is identical to the ESP transport mode"
---
 net/ipv4/esp4.c |   24 +++++++++---------------
 net/ipv6/esp6.c |   18 +++++++-----------
 2 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 89a47b3..cb982a6 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -459,28 +459,22 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
 	u32 align = max_t(u32, blksize, esp->padlen);
-	u32 rem;
-
-	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
-	rem = mtu & (align - 1);
-	mtu &= ~(align - 1);
+	unsigned int net_adj;
 
 	switch (x->props.mode) {
-	case XFRM_MODE_TUNNEL:
-		break;
-	default:
 	case XFRM_MODE_TRANSPORT:
-		/* The worst case */
-		mtu -= blksize - 4;
-		mtu += min_t(u32, blksize - 4, rem);
-		break;
 	case XFRM_MODE_BEET:
-		/* The worst case. */
-		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
+		net_adj = sizeof(struct iphdr);
 		break;
+	case XFRM_MODE_TUNNEL:
+		net_adj = 0;
+		break;
+	default:
+		BUG();
 	}
 
-	return mtu - 2;
+	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
+		 net_adj) & ~(align - 1)) + (net_adj - 2);
 }
 
 static void esp4_err(struct sk_buff *skb, u32 info)
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 1e62b75..db1521f 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -413,19 +413,15 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
 	u32 align = max_t(u32, blksize, esp->padlen);
-	u32 rem;
+	unsigned int net_adj;
 
-	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
-	rem = mtu & (align - 1);
-	mtu &= ~(align - 1);
-
-	if (x->props.mode != XFRM_MODE_TUNNEL) {
-		u32 padsize = ((blksize - 1) & 7) + 1;
-		mtu -= blksize - padsize;
-		mtu += min_t(u32, blksize - padsize, rem);
-	}
+	if (x->props.mode != XFRM_MODE_TUNNEL)
+		net_adj = sizeof(struct ipv6hdr);
+	else
+		net_adj = 0;
 
-	return mtu - 2;
+	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
+		 net_adj) & ~(align - 1)) + (net_adj - 2);
 }
 
 static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-- 
1.7.7
