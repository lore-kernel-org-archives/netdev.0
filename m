From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V6 3/8] Drivers: hv: vmbus: vmbus_sendpacket_ctl: hvsock:
 avoid unnecessary signaling
Date: Tue, 26 Jan 2016 01:44:30 -0800
Message-ID: <1453801470-3331-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
 vkuznets@redhat.com
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

When the hvsock channel's outbound ringbuffer is full (i.e.,
hv_ringbuffer_write() returns -EAGAIN), we should avoid the unnecessary
signaling the host.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index 1161d68..3f04533 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -659,6 +659,9 @@ int vmbus_sendpacket_ctl(struct vmbus_channel *channel, void *buffer,
 	 * If we cannot write to the ring-buffer; signal the host
 	 * even if we may not have written anything. This is a rare
 	 * enough condition that it should not matter.
+	 * NOTE: in this case, the hvsock channel is an exception, because
+	 * it looks the host side's hvsock implementation has a throttling
+	 * mechanism which can hurt the performance otherwise.
 	 */
 
 	if (channel->signal_policy)
@@ -666,7 +669,8 @@ int vmbus_sendpacket_ctl(struct vmbus_channel *channel, void *buffer,
 	else
 		kick_q = true;
 
-	if (((ret == 0) && kick_q && signal) || (ret))
+	if (((ret == 0) && kick_q && signal) ||
+	    (ret && !is_hvsock_channel(channel)))
 		vmbus_setevent(channel);
 
 	return ret;
-- 
2.1.0
