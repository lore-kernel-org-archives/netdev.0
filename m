From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/4] WAN: HDLC: Call notifiers before and after changing device type
Date: Thu,  3 Dec 2015 21:12:31 +0100
Message-ID: <1449173553-23784-3-git-send-email-andrew@lunn.ch>
References: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	netdev <netdev@vger.kernel.org>,
	"B.A.T.M.A.N" <b.a.t.m.a.n@lists.open-mesh.net>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53073 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557AbbLCUM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 15:12:57 -0500
In-Reply-To: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An HDLC device can change type when the protocol driver is changed.
Calling the notifier change allows potential users of the interface
know about this planned change, and even block it. After the change
has occurred, send a second notification to users can evaluate the new
device type etc.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/wan/hdlc.c         | 19 +++++++++++++++++--
 drivers/net/wan/hdlc_cisco.c   |  1 +
 drivers/net/wan/hdlc_fr.c      |  1 +
 drivers/net/wan/hdlc_ppp.c     |  1 +
 drivers/net/wan/hdlc_raw.c     |  1 +
 drivers/net/wan/hdlc_raw_eth.c |  1 +
 drivers/net/wan/hdlc_x25.c     |  1 +
 include/linux/hdlc.h           |  2 +-
 8 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 2a6595b4ae15..9bd4aa8083ce 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -276,7 +276,11 @@ void unregister_hdlc_device(struct net_device *dev)
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			 size_t size)
 {
-	detach_hdlc_protocol(dev);
+	int err;
+
+	err = detach_hdlc_protocol(dev);
+	if (err)
+		return err;
 
 	if (!try_module_get(proto->module))
 		return -ENOSYS;
@@ -289,15 +293,24 @@ int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 		}
 	}
 	dev_to_hdlc(dev)->proto = proto;
+
 	return 0;
 }
 
 
-void detach_hdlc_protocol(struct net_device *dev)
+int detach_hdlc_protocol(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
+	int err;
 
 	if (hdlc->proto) {
+		err = call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE, dev);
+		err = notifier_to_errno(err);
+		if (err) {
+			netdev_err(dev, "Refused to change device type\n");
+			return err;
+		}
+
 		if (hdlc->proto->detach)
 			hdlc->proto->detach(dev);
 		module_put(hdlc->proto->module);
@@ -306,6 +319,8 @@ void detach_hdlc_protocol(struct net_device *dev)
 	kfree(hdlc->state);
 	hdlc->state = NULL;
 	hdlc_setup_dev(dev);
+
+	return 0;
 }
 
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 3f20808b5ff8..a408abc25512 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -378,6 +378,7 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 		spin_lock_init(&state(hdlc)->lock);
 		dev->header_ops = &cisco_header_ops;
 		dev->type = ARPHRD_CISCO;
+		call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
 		netif_dormant_on(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index e92aaf615901..6d46838db476 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1240,6 +1240,7 @@ static int fr_ioctl(struct net_device *dev, struct ifreq *ifr)
 		}
 		memcpy(&state(hdlc)->settings, &new_settings, size);
 		dev->type = ARPHRD_FRAD;
+		call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
 		return 0;
 
 	case IF_PROTO_FR_ADD_PVC:
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 0d7645581f91..47fdb87d3567 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -687,6 +687,7 @@ static int ppp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		dev->hard_header_len = sizeof(struct hdlc_header);
 		dev->header_ops = &ppp_header_ops;
 		dev->type = ARPHRD_PPP;
+		call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
 		netif_dormant_on(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index 5dc153e8a29d..4feb45001aac 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -84,6 +84,7 @@ static int raw_ioctl(struct net_device *dev, struct ifreq *ifr)
 			return result;
 		memcpy(hdlc->state, &new_settings, size);
 		dev->type = ARPHRD_RAWHDLC;
+		call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index 3ab72b3082de..2f11836078ab 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -102,6 +102,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		ether_setup(dev);
 		dev->tx_queue_len = old_qlen;
 		eth_hw_addr_random(dev);
+		call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index a49aec5efd20..e867638067a6 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -213,6 +213,7 @@ static int x25_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if ((result = attach_hdlc_protocol(dev, &proto, 0)))
 			return result;
 		dev->type = ARPHRD_X25;
+		call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index 1acb1445e05f..e31bcd4c7859 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -101,7 +101,7 @@ netdev_tx_t hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			 size_t size);
 /* May be used by hardware driver to gain control over HDLC device */
-void detach_hdlc_protocol(struct net_device *dev);
+int detach_hdlc_protocol(struct net_device *dev);
 
 static __inline__ __be16 hdlc_type_trans(struct sk_buff *skb,
 					 struct net_device *dev)
-- 
2.6.2
