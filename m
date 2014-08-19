From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Add handling of IP header with option field
 in netvsc_set_hash()
Date: Tue, 19 Aug 2014 20:53:55 +0000
Message-ID: <1408481635-29639-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

In case that the IP header has optional field at the end, this patch will 
get the port numbers after that field, and compute the hash.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a9c5eaa..b12dcd9 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -191,6 +191,8 @@ static u32 comp_hash(u8 *key, int klen, u8 *data, int dlen)
 static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 {
 	struct iphdr *iphdr;
+	u8 dbuf[12];
+	u8 *data;
 	int data_len;
 	bool ret = false;
 
@@ -200,12 +202,18 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 	iphdr = ip_hdr(skb);
 
 	if (iphdr->version == 4) {
-		if (iphdr->protocol == IPPROTO_TCP)
+		data = (u8 *)&iphdr->saddr;
+		if (iphdr->protocol == IPPROTO_TCP) {
 			data_len = 12;
-		else
+			if (iphdr->ihl > 5) {
+				memcpy(dbuf, &iphdr->saddr, 8);
+				memcpy(&dbuf[8], &tcp_hdr(skb)->source, 4);
+				data = dbuf;
+			}
+		} else {
 			data_len = 8;
-		*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN,
-				  (u8 *)&iphdr->saddr, data_len);
+		}
+		*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, data, data_len);
 		ret = true;
 	}
 
-- 
1.7.1
