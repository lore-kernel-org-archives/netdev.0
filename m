From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: ensure GPRS device does not go away during TX work
Date: Wed, 10 Dec 2008 15:15:28 +0200
Message-ID: <1228914929-26337-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200812101514.56827.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:23834 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302AbYLJNPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 08:15:48 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBADFXMI014020
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 15:15:45 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBADFTX9010974
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 15:15:29 +0200
In-Reply-To: <200812101514.56827.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to hold the device while TX work is pending, as work is flushed
only after the network device is unregistered.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index e6e8e44..5985bc5 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -184,6 +184,7 @@ static int gprs_xmit(struct sk_buff *skb, struct ne=
t_device *net)
 	spin_lock(&dev->tx_lock);
 	if (likely(skb_queue_len(&dev->tx_queue) < dev->tx_max)) {
 		skb_queue_tail(&dev->tx_queue, skb);
+		dev_hold(net);
 		skb =3D NULL;
 	}
 	if (skb_queue_len(&dev->tx_queue) >=3D dev->tx_max)
@@ -221,6 +222,7 @@ static void gprs_tx(struct work_struct *work)
 			net->stats.tx_errors++;
 		}
 		release_sock(sk);
+		dev_put(net);
 	}
=20
 	lock_sock(sk);
--=20
1.5.4.3

