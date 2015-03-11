From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 2/3 net-next] Drivers: hv: vmbus: Fix a bug in the
 signalling logic with kick_q
Date: Wed, 11 Mar 2015 12:04:19 -0700
Message-ID: <1426100660-9547-2-git-send-email-kys@microsoft.com>
References: <1426100635-9508-1-git-send-email-kys@microsoft.com>
 <1426100660-9547-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1426100660-9547-1-git-send-email-kys@microsoft.com>
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

When the caller specifies that signalling should be deferred, we need to
address the case where we are not able to place the current packet because
the buffer is full. In this case, we will signal the host as some packets
may have been placed on the ring buffer.
I would like to thank Jason Wang <jasowang@redhat.com> for pointing
out this issue.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/channel.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index e58cdb7..ae06ba9 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -614,8 +614,24 @@ int vmbus_sendpacket_ctl(struct vmbus_channel *channel, void *buffer,
 
 	ret = hv_ringbuffer_write(&channel->outbound, bufferlist, 3, &signal);
 
+	/*
+	 * Here is the logic for signalling the host:
+	 * 1. If the host is already draining the ringbuffer,
+	 *    don't signal. This is indicated by the parameter
+	 *    "signal".
+	 *
+	 * 2. If we are not able to write, signal if kick_q is false.
+	 *    kick_q being false indicates that we may have placed zero or
+	 *    more packets with more packets to come. We will signal in
+	 *    this case even if potentially we may have not placed any
+	 *    packet. This is a rare enough condition that it should not
+	 *    matter.
+	 */
+
 	if ((ret == 0) && kick_q && signal)
 		vmbus_setevent(channel);
+	else if ((ret != 0) && !kick_q)
+		vmbus_setevent(channel);
 
 	return ret;
 }
@@ -705,8 +721,24 @@ int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
 
 	ret = hv_ringbuffer_write(&channel->outbound, bufferlist, 3, &signal);
 
+	/*
+	 * Here is the logic for signalling the host:
+	 * 1. If the host is already draining the ringbuffer,
+	 *    don't signal. This is indicated by the parameter
+	 *    "signal".
+	 *
+	 * 2. If we are not able to write, signal if kick_q is false.
+	 *    kick_q being false indicates that we may have placed zero or
+	 *    more packets with more packets to come. We will signal in
+	 *    this case even if potentially we may have not placed any
+	 *    packet. This is a rare enough condition that it should not
+	 *    matter.
+	 */
+
 	if ((ret == 0) && kick_q && signal)
 		vmbus_setevent(channel);
+	else if ((ret != 0) && !kick_q)
+		vmbus_setevent(channel);
 
 	return ret;
 }
-- 
1.7.4.1
