From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS] Don't panic on creating the namespace's loopback
Date: Mon, 15 Oct 2007 14:23:13 +0400
Message-ID: <47133F91.4030209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35148 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757718AbXJOK0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 06:26:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the loopback device is failed to initialize inside the new 
namespaces, panic() is called. Do not do it when the namespace 
in question is not the init_net.

Plus cleanup the error path a bit.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 drivers/net/loopback.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index be25aa3..662b8d1 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -265,17 +265,16 @@ static __net_init int loopback_net_init(struct net *net)
 	if (err)
 		goto out_free_netdev;
 
-	err = 0;
 	net->loopback_dev = dev;
+	return 0;
 
-out:
-	if (err)
-		panic("loopback: Failed to register netdevice: %d\n", err);
-	return err;
 
 out_free_netdev:
 	free_netdev(dev);
-	goto out;
+out:
+	if (net == &init_net)
+		panic("loopback: Failed to register netdevice: %d\n", err);
+	return err;
 }
 
 static __net_exit void loopback_net_exit(struct net *net)
