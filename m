From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge: kernel panic when unloading bridge module
Date: Mon, 28 Apr 2008 17:29:07 -0700
Message-ID: <20080428172907.2517c12e@extreme>
References: <20080428172809.7f814ed5@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Bodo Stroesser <bstroesser@fujitsu-siemens.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44333 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936152AbYD2A3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 20:29:36 -0400
In-Reply-To: <20080428172809.7f814ed5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition when unloading bridge and netfilter.

The problem happens if __fake_rtable is in use by a skb
coming in, while someone starts to unload bridge.ko.
br_netfilter_fini() is called at the beginning of unload
in br_deinit() while skbs still are being forwarded and
transferred to local ip stack. Thus there is a possibility
of the __fake_rtable pointer not being removed in a skb that
goes up to ip stack. This results in a kernel panic, as
ip_rcv() calls the input-function of __fake_rtable, which
is NULL.

Moving the call of br_netfilter_fini() to the end of
br_deinit() solves the problem.

Signed-off-by: Bodo Stroesser <bstroesser@fujitsu-siemens.com>
Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

---
 net/bridge/br.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/bridge/br.c	2008-04-28 15:27:06.000000000 -0700
+++ b/net/bridge/br.c	2008-04-28 15:31:32.000000000 -0700
@@ -76,7 +76,6 @@ static void __exit br_deinit(void)
 	rcu_assign_pointer(br_stp_sap->rcv_func, NULL);
 
 	br_netlink_fini();
-	br_netfilter_fini();
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
 
@@ -84,6 +83,7 @@ static void __exit br_deinit(void)
 
 	synchronize_net();
 
+	br_netfilter_fini();
 	llc_sap_put(br_stp_sap);
 	br_fdb_get_hook = NULL;
 	br_fdb_put_hook = NULL;
