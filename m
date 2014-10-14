From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,
 v2] hyperv: Add handling of IP header with option field in
 netvsc_set_hash()
Date: Tue, 14 Oct 2014 15:16:28 -0700
Message-ID: <1413324988-8863-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

In case that the IP header has optional field at the end, this patch will
get the port numbers after that field, and compute the hash.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0fcb5e7..0d60c91 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -162,7 +162,7 @@ union sub_key {
  * data: network byte order
  * return: host byte order
  */
-static u32 comp_hash(u8 *key, int klen, u8 *data, int dlen)
+static u32 comp_hash(u8 *key, int klen, void *data, int dlen)
 {
 	union sub_key subk;
 	int k_next = 4;
@@ -176,7 +176,7 @@ static u32 comp_hash(u8 *key, int klen, u8 *data, int dlen)
 	for (i = 0; i < dlen; i++) {
 		subk.kb = key[k_next];
 		k_next = (k_next + 1) % klen;
-		dt = data[i];
+		dt = ((u8 *)data)[i];
 		for (j = 0; j < 8; j++) {
 			if (dt & 0x80)
 				ret ^= subk.ka;
@@ -191,6 +191,7 @@ static u32 comp_hash(u8 *key, int klen, u8 *data, int dlen)
 static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 {
 	struct iphdr *iphdr;
+	__be32 dbuf[3];
 	int data_len;
 	bool ret = false;
 
@@ -200,12 +201,15 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 	iphdr = ip_hdr(skb);
 
 	if (iphdr->version == 4) {
-		if (iphdr->protocol == IPPROTO_TCP)
+		dbuf[0] = iphdr->saddr;
+		dbuf[1] = iphdr->daddr;
+		if (iphdr->protocol == IPPROTO_TCP) {
+			dbuf[2] = *(__be32 *)&tcp_hdr(skb)->source;
 			data_len = 12;
-		else
+		} else {
 			data_len = 8;
-		*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN,
-				  (u8 *)&iphdr->saddr, data_len);
+		}
+		*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, dbuf, data_len);
 		ret = true;
 	}
 
-- 
1.7.1
