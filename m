From: Stephen Hemminger <sthemmin@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: fix a race between netvsc_send() and
 netvsc_init_buf()
Date: Thu, 20 Oct 2016 08:36:21 +0000
Message-ID: <BLUPR0301MB2098D6A07F0D465E63988D9FCCD50@BLUPR0301MB2098.namprd03.prod.outlook.com>
References: <1476885181-3456-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476885181-3456-1-git-send-email-vkuznets@redhat.com>
Content-Language: en-US
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

Do we need ACCESS_ONCE() here to avoid check/use issues?

-----Original Message-----
From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com] 
Sent: Wednesday, October 19, 2016 2:53 PM
To: netdev@vger.kernel.org
Cc: Stephen Hemminger <sthemmin@microsoft.com>; devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; KY Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: fix a race between netvsc_send() and netvsc_init_buf()

Fix in commit 880988348270 ("hv_netvsc: set nvdev link after populating
chn_table") turns out to be incomplete. A crash in
netvsc_get_next_send_section() is observed on mtu change when the device is under load. The race I identified is: if we get to netvsc_send() after we set net_device_ctx->nvdev link in netvsc_device_add() but before we finish netvsc_connect_vsp()->netvsc_init_buf() send_section_map is not allocated and we crash. Unfortunately we can't set net_device_ctx->nvdev link after the netvsc_init_buf() call as during the negotiation we need to receive packets and on the receive path we check for it. It would probably be possible to split nvdev into a pair of nvdev_in and nvdev_out links and check them accordingly in get_outbound_net_device()/
get_inbound_net_device() but this looks like an overkill.

Check that send_section_map is allocated in netvsc_send().

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c index 720b5fa..e2bfaac 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -888,6 +888,13 @@ int netvsc_send(struct hv_device *device,
 	if (!net_device)
 		return -ENODEV;
 
+	/* We may race with netvsc_connect_vsp()/netvsc_init_buf() and get
+	 * here before the negotiation with the host is finished and
+	 * send_section_map may not be allocated yet.
+	 */
+	if (!net_device->send_section_map)
+		return -EAGAIN;
+
 	out_channel = net_device->chn_table[q_idx];
 
 	packet->send_buf_index = NETVSC_INVALID_INDEX;
--
2.7.4
