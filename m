From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH 1/1 net-2.6] Re-enable IP when MTU > 68
Date: Fri, 29 Aug 2008 11:53:31 -0300
Message-ID: <48B80D6B.5030007@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Lorandi <rafaello@br.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:41958 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940AbYH2Oy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 10:54:58 -0400
Received: from mailhub3.br.ibm.com (unknown [9.18.232.110])
	by igw3.br.ibm.com (Postfix) with ESMTP id 5055639020E
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 11:34:25 -0300 (BRST)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m7TEs1EK3641582
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 11:54:06 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7TErsq4016654
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 11:53:54 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually if you run "ifconfig ethX mtu 56; ifconfig ethX mtu 1500",
then your interface will get corrupted. On an attempt to assign an IP
to the interface, it'll result in:
SIOCSIFADDR: No buffer space available
This happens because when decreasing the MTU under 68, it'll destroy the
in_dev reference forever, even after getting MTU higher than 68 bytes.

This patch just checks if the in_dev is NULL on a NETDEV_CHANGEMTU event
and if MTU is bigger than 68, then re-enable in_dev 

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 91d3d96..758b4f6 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1048,6 +1048,10 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
 				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
 			}
+		} else if (event == NETDEV_CHANGEMTU) {
+			/* Re-enabling IP */
+			if (dev->mtu > 68)
+				in_dev = inetdev_init(dev);
 		}
 		goto out;
 	}

