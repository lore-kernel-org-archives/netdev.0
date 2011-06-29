From: Nick Carter <ncarter100@gmail.com>
Subject: [PATCH] bridge: Forward EAPOL when sysfs bridge/pae_forward is set
Date: Thu, 30 Jun 2011 00:02:36 +0100
Message-ID: <BANLkTikcEpxPdoB9ALSjAu_tSyLCwatV2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net
To: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62594 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab1F2XCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 19:02:37 -0400
Received: by pzk9 with SMTP id 9so1222171pzk.19
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2011 16:02:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Control the forwarding of 802.1x EAPOL frames destined for the 802.1x
PAE group mac address.

These diffs do not change the current forwarding behaviour of
bridge.ko.  If the sysfs bridge/pae_forward attribute is set, then
frames destined to the 802.1x PAE group address will be forwarded.

This functionality is required so that virtual machines running an
802.1x Supplicant can authenticate to an external 802.1x
Authenticator.

Signed-off-by: Nick Carter <ncarter100@gmail.com>

diff based off linux-next
 net/bridge/br_device.c   |    1 +
 net/bridge/br_input.c    |    4 ++++
 net/bridge/br_private.h  |    1 +
 net/bridge/br_sysfs_br.c |   23 +++++++++++++++++++++++
 4 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index c188c80..1efd9bf 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -364,6 +364,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
 	br->ageing_time = 300 * HZ;
+	br->pae_forward = false;

 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f3ac1e8..94a9715 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -168,6 +168,10 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
 			goto forward;

+		/* Check if PAE frame should be forwarded */
+		if (p->br->pae_forward && dest[5] == 3)
+			goto forward;
+
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 54578f2..2c298f3 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -215,6 +215,7 @@ struct net_bridge

 	unsigned char			topology_change;
 	unsigned char			topology_change_detected;
+	bool				pae_forward;

 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	unsigned char			multicast_router;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 68b893e..534323a 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -646,6 +646,28 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_IWUSR,
 		   show_nf_call_arptables, store_nf_call_arptables);
 #endif

+static ssize_t show_pae_forward(struct device *d, struct
device_attribute *attr,
+				char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->pae_forward);
+}
+
+static int set_pae_forward(struct net_bridge *br, unsigned long val)
+{
+	br->pae_forward = val ? true : false;
+	return 0;
+}
+
+static ssize_t store_pae_forward(struct device *d,
+				 struct device_attribute *attr, const char *buf,
+				 size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_pae_forward);
+}
+static DEVICE_ATTR(pae_forward, S_IRUGO | S_IWUSR, show_pae_forward,
+		   store_pae_forward);
+
 static struct attribute *bridge_attrs[] = {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -665,6 +687,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_pae_forward.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
