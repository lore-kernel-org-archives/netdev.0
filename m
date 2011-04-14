From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next-2.6 04/24] e1000: convert to set_phys_id
Date: Wed, 13 Apr 2011 18:12:45 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90018A3428DE@orsmsx509.amr.corp.intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1302742940-22141-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: stephen hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41216 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973Ab1DNBMr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 21:12:47 -0400
In-Reply-To: <1302742940-22141-5-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Jeff Kirsher
>Sent: Wednesday, April 13, 2011 6:02 PM
>To: davem@davemloft.net
>Cc: stephen hemminger; netdev@vger.kernel.org; gospo@redhat.com;
>bphilips@novell.com; Kirsher, Jeffrey T
>Subject: [net-next-2.6 04/24] e1000: convert to set_phys_id
>
>From: stephen hemminger <shemminger@vyatta.com>
>
>Convert to new LED control infrastucture and remove no longer
>necessary bits.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>---
> drivers/net/e1000/e1000.h         |    3 --
> drivers/net/e1000/e1000_ethtool.c |   50 ++++++++++++-------------------------
> 2 files changed, 16 insertions(+), 37 deletions(-)
>
>diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
>index a881dd0..f96475c 100644
>--- a/drivers/net/e1000/e1000.h
>+++ b/drivers/net/e1000/e1000.h
>@@ -238,9 +238,6 @@ struct e1000_adapter {
> 	struct work_struct reset_task;
> 	u8 fc_autoneg;
>
>-	struct timer_list blink_timer;
>-	unsigned long led_status;
>-
> 	/* TX */
> 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
> 	unsigned int restart_queue;
>diff --git a/drivers/net/e1000/e1000_ethtool.c
>b/drivers/net/e1000/e1000_ethtool.c
>index dd70738..5c998a9 100644
>--- a/drivers/net/e1000/e1000_ethtool.c
>+++ b/drivers/net/e1000/e1000_ethtool.c
>@@ -1753,46 +1753,28 @@ static int e1000_set_wol(struct net_device *netdev,
>struct ethtool_wolinfo *wol)
> 	return 0;
> }
>
>-/* toggle LED 4 times per second = 2 "blinks" per second */
>-#define E1000_ID_INTERVAL	(HZ/4)
>-
>-/* bit defines for adapter->led_status */
>-#define E1000_LED_ON		0
>-
>-static void e1000_led_blink_callback(unsigned long data)
>+static int e1000_set_phys_id(struct net_device *netdev,
>+			     enum ethtool_phys_id_state state)
> {
>-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
>+	struct e1000_adapter *adapter = netdev_priv(netdev);
> 	struct e1000_hw *hw = &adapter->hw;
>
>-	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
>-		e1000_led_off(hw);
>-	else
>-		e1000_led_on(hw);
>-
>-	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
>-}
>+	switch (state) {
>+	case ETHTOOL_ID_ACTIVE:
>+		e1000_setup_led(hw);
>+		return -EINVAL;

This conflicts with the patch I submitted a few hours ago - with it, this
feature is broken for e1000.

>
>-static int e1000_phys_id(struct net_device *netdev, u32 data)
>-{
>-	struct e1000_adapter *adapter = netdev_priv(netdev);
>-	struct e1000_hw *hw = &adapter->hw;
>+	case ETHTOOL_ID_ON:
>+		e1000_led_on(hw);
>+		break;
>
>-	if (!data)
>-		data = INT_MAX;
>+	case ETHTOOL_ID_OFF:
>+		e1000_led_off(hw);
>+		break;
>
>-	if (!adapter->blink_timer.function) {
>-		init_timer(&adapter->blink_timer);
>-		adapter->blink_timer.function = e1000_led_blink_callback;
>-		adapter->blink_timer.data = (unsigned long)adapter;
>+	case ETHTOOL_ID_INACTIVE:
>+		e1000_cleanup_led(hw);
> 	}
>-	e1000_setup_led(hw);
>-	mod_timer(&adapter->blink_timer, jiffies);
>-	msleep_interruptible(data * 1000);
>-	del_timer_sync(&adapter->blink_timer);
>-
>-	e1000_led_off(hw);
>-	clear_bit(E1000_LED_ON, &adapter->led_status);
>-	e1000_cleanup_led(hw);
>
> 	return 0;
> }
>@@ -1929,7 +1911,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
> 	.set_tso                = e1000_set_tso,
> 	.self_test              = e1000_diag_test,
> 	.get_strings            = e1000_get_strings,
>-	.phys_id                = e1000_phys_id,
>+	.set_phys_id            = e1000_set_phys_id,
> 	.get_ethtool_stats      = e1000_get_ethtool_stats,
> 	.get_sset_count         = e1000_get_sset_count,
> 	.get_coalesce           = e1000_get_coalesce,
>--
>1.7.4.2
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
