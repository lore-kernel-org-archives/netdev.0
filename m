From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH] xfrm: take iphdr size into account for esp payload size calculation
Date: Wed,  9 May 2012 18:35:52 -0400
Message-ID: <1336602952-10479-1-git-send-email-bpoirier@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corrects the function that determines the esp payload size.
The calculations done in esp4_get_mtu lead to overlength frames in transport
mode for certain mtu values (eg. 1499 leads to FRAGFAILS) and suboptimal
frames for others (eg. 1500, where the addition of padding in the esp header
can be avoided).

According to what is done, mainly in esp_output(), net_header_len aka
sizeof(struct iphdr) must be taken into account before doing the alignment
calculation.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

---
Tested with
* transport mode E
* transport mode EA
* transport mode E + ah
* tunnel mode E

Not tested with BEET, but it should be the same as transport mode
	draft-nikander-esp-beet-mode-03.txt Section 5.2:
	"The wire packet format is identical to the ESP transport mode"
---
 net/ipv4/esp4.c |   24 +++---------------------
 1 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 89a47b3..60f2738 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -459,28 +459,10 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
 	u32 align = max_t(u32, blksize, esp->padlen);
-	u32 rem;
 
-	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
-	rem = mtu & (align - 1);
-	mtu &= ~(align - 1);
-
-	switch (x->props.mode) {
-	case XFRM_MODE_TUNNEL:
-		break;
-	default:
-	case XFRM_MODE_TRANSPORT:
-		/* The worst case */
-		mtu -= blksize - 4;
-		mtu += min_t(u32, blksize - 4, rem);
-		break;
-	case XFRM_MODE_BEET:
-		/* The worst case. */
-		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
-		break;
-	}
-
-	return mtu - 2;
+	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
+			sizeof(struct iphdr)) & ~(align - 1)) + (sizeof(struct
+			iphdr) - 2);
 }
 
 static void esp4_err(struct sk_buff *skb, u32 info)
-- 
1.7.7
