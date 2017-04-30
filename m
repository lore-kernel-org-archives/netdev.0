From: kys@exchange.microsoft.com
Subject: [PATCH 4/6] Drivers: hv: util: Make hv_poll_channel() a little more
 efficient
Date: Sun, 30 Apr 2017 16:21:17 -0700
Message-ID: <1493594479-25329-4-git-send-email-kys@exchange.microsoft.com>
References: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
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

From: K. Y. Srinivasan <kys@microsoft.com>

The current code unconditionally sends an IPI. If we are running on the
correct CPU and are in interrupt level, we don't need an IPI.
Make this adjustment.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/hyperv_vmbus.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/hv/hyperv_vmbus.h b/drivers/hv/hyperv_vmbus.h
index 6113e91..fa514be 100644
--- a/drivers/hv/hyperv_vmbus.h
+++ b/drivers/hv/hyperv_vmbus.h
@@ -411,6 +411,10 @@ static inline void hv_poll_channel(struct vmbus_channel *channel,
 	if (!channel)
 		return;
 
+	if (in_interrupt() && (channel->target_cpu == smp_processor_id())) {
+		cb(channel);
+		return;
+	}
 	smp_call_function_single(channel->target_cpu, cb, channel, true);
 }
 
-- 
1.7.1
