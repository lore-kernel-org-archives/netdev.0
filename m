From: Dexuan Cui <decui@microsoft.com>
Subject: [V2 7/7] Drivers: hv: vmbus: disable local interrupt when hvsock's
 callback is running
Date: Tue, 14 Jul 2015 03:01:28 -0700
Message-ID: <1436868088-17917-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
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

In the SMP guest case, when the per-channel callback hvsock_events() is
running on virtual CPU A, if the guest tries to close the connection on
virtual CPU B: we invoke vmbus_close() -> vmbus_close_internal(),
then we can have trouble: on B, vmbus_close_internal() will send IPI
reset_channel_cb() to A, trying to set channel->onchannel_callbackto NULL;
on A, if the IPI handler happens between
"if (channel->onchannel_callback != NULL)" and invoking
channel->onchannel_callback, we'll invoke a function pointer of NULL.

This is why the patch is necessary.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/connection.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/hv/connection.c b/drivers/hv/connection.c
index 4fc2e88..4766fd8 100644
--- a/drivers/hv/connection.c
+++ b/drivers/hv/connection.c
@@ -319,6 +319,9 @@ static void process_chn_event(u32 relid)
 	void *arg;
 	bool read_state;
 	u32 bytes_to_read;
+	bool is_hvsock = false;
+
+	local_irq_disable();
 
 	/*
 	 * Find the channel based on this relid and invokes the
@@ -327,7 +330,11 @@ static void process_chn_event(u32 relid)
 	channel = pcpu_relid2channel(relid);
 
 	if (!channel)
-		return;
+		goto out;
+
+	is_hvsock = is_hvsock_channel(channel);
+	if (!is_hvsock)
+		local_irq_enable();
 
 	/*
 	 * A channel once created is persistent even when there
@@ -363,6 +370,12 @@ static void process_chn_event(u32 relid)
 				bytes_to_read = 0;
 		} while (read_state && (bytes_to_read != 0));
 	}
+
+	/* local_irq_enable() is alredy invoked above */
+	if (!is_hvsock)
+		return;
+out:
+	local_irq_enable();
 }
 
 /*
-- 
2.1.0
