From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 06/10] netvsc: signal host if receive ring is
 emptied
Date: Wed, 26 Jul 2017 16:40:25 -0700
Message-ID: <20170726234029.7342-7-sthemmin@microsoft.com>
References: <20170726234029.7342-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
 corbet@lwn.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170726234029.7342-1-sthemmin@microsoft.com>
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

Latency improvement related to NAPI conversion.
If all packets are processed from receive ring then need
to signal host.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4c709b454d34..c5e6f7fc4f2b 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1195,10 +1195,15 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 		nvchan->desc = hv_pkt_iter_next(channel, nvchan->desc);
 	}
 
-	/* If send of  pending receive completions suceeded
-	 *   and did not exhaust NAPI budget
+	/* if ring is empty, signal host */
+	if (!nvchan->desc)
+		hv_pkt_iter_close(channel);
+
+	/* If send of pending receive completions suceeded
+	 *   and did not exhaust NAPI budget this time
 	 *   and not doing busy poll
-	 * then reschedule if more data has arrived from host
+	 * then re-enable host interrupts
+	 *     and reschedule if ring is not empty.
 	 */
 	if (send_recv_completions(nvchan) == 0 &&
 	    work_done < budget &&
-- 
2.11.0
