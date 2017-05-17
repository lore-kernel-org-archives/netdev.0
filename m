From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] net: make struct net_device::tx_queue_len unsigned
 int
Date: Wed, 17 May 2017 13:30:44 +0300
Message-ID: <20170517103044.GA28488@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35987 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbdEQKau (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 06:30:50 -0400
Received: by mail-wr0-f194.google.com with SMTP id v42so1092047wrc.3
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 03:30:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

4 billion packet queue is something unthinkable so use 32-bit value
for now.

Space savings on x86_64:

	add/remove: 0/0 grow/shrink: 3/70 up/down: 16/-131 (-115)
	function                                     old     new   delta
	change_tx_queue_len                           94     108     +14
	qdisc_create                                1176    1177      +1
	alloc_netdev_mqs                            1124    1125      +1
	xenvif_alloc                                 533     532      -1
	x25_asy_setup                                167     166      -1
			...
	tun_queue_resize                             945     940      -5
	pfifo_fast_enqueue                           167     162      -5
	qfq_init_qdisc                               168     158     -10
	tap_queue_resize                             810     799     -11
	transmit                                     719     698     -21

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/wan/hdlc_raw_eth.c |    3 ++-
 include/linux/netdevice.h      |    2 +-
 net/core/net-sysfs.c           |    8 ++++++--
 net/core/rtnetlink.c           |    4 ++--
 4 files changed, 11 insertions(+), 6 deletions(-)

--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -57,7 +57,8 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 	const size_t size = sizeof(raw_hdlc_proto);
 	raw_hdlc_proto new_settings;
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	int result, old_qlen;
+	unsigned int old_qlen;
+	int result;
 
 	switch (ifr->ifr_settings.type) {
 	case IF_GET_PROTO:
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1824,7 +1824,7 @@ struct net_device {
 #ifdef CONFIG_NET_SCHED
 	DECLARE_HASHTABLE	(qdisc_hash, 4);
 #endif
-	unsigned long		tx_queue_len;
+	unsigned int		tx_queue_len;
 	spinlock_t		tx_global_lock;
 	int			watchdog_timeo;
 
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -323,7 +323,11 @@ NETDEVICE_SHOW_RW(flags, fmt_hex);
 
 static int change_tx_queue_len(struct net_device *dev, unsigned long new_len)
 {
-	int res, orig_len = dev->tx_queue_len;
+	unsigned int orig_len = dev->tx_queue_len;
+	int res;
+
+	if (new_len != (unsigned int)new_len)
+		return -ERANGE;
 
 	if (new_len != orig_len) {
 		dev->tx_queue_len = new_len;
@@ -349,7 +353,7 @@ static ssize_t tx_queue_len_store(struct device *dev,
 
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
-NETDEVICE_SHOW_RW(tx_queue_len, fmt_ulong);
+NETDEVICE_SHOW_RW(tx_queue_len, fmt_dec);
 
 static int change_gro_flush_timeout(struct net_device *dev, unsigned long val)
 {
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2046,8 +2046,8 @@ static int do_setlink(const struct sk_buff *skb,
 	}
 
 	if (tb[IFLA_TXQLEN]) {
-		unsigned long value = nla_get_u32(tb[IFLA_TXQLEN]);
-		unsigned long orig_len = dev->tx_queue_len;
+		unsigned int value = nla_get_u32(tb[IFLA_TXQLEN]);
+		unsigned int orig_len = dev->tx_queue_len;
 
 		if (dev->tx_queue_len ^ value) {
 			dev->tx_queue_len = value;
