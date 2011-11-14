From: Mike McElroy <mike.mcelroy@stratus.com>
Subject: Hitting BUG_ON() from napi_enable in e1000e
Date: Mon, 14 Nov 2011 14:37:07 -0500
Message-ID: <4EC16DE3.5020701@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub4.stratus.com ([134.111.1.17]:54908 "EHLO
	mailhub4.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab1KNUIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 15:08:52 -0500
Received: from EXHQ.corp.stratus.com (exhq.corp.stratus.com [134.111.201.100])
	by mailhub4.stratus.com (8.12.11/8.12.11) with ESMTP id pAEJbB5g016070
	for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 14:37:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hitting the BUG_ON in napi_enable(). Code inspection shows that this can 
only be triggered by calling napi_enable() twice without an intervening 
napi_disable().

I saw the following sequence of events in the stack trace:

1) We simulated a cable pull using an Extreme switch.
2) e1000_tx_timeout() was entered.
3) e1000_reset_task() was called. Saw the message from e_err() in the 
console log.
4) e1000_reinit_locked was called. This function calls e1000_down() and 
e1000_up(). These functions call napi_disable() and napi_enable() 
respectively.
5) Then on another thread, a monitor task saw carrier was down and 
executed 'ip set link down' and 'ip set link up' commands.
6) Saw the '_E1000_RESETTING'warning fron the e1000_close function.
7) Either the e1000_open() executed between the e1000_down() and 
e1000_up() calls in step 4 or the e1000_open() call executed after the 
e0001_up() call. In either case, napi_enable() is called twice which 
triggers the BUG_ON.

This code sequence is present in the e1000 driver also.

There are two bugs here:
1) The napi_enable() and napi_disable() should only be called in the 
e1000_open and e1000_close functions respectively
2) There no synchronization preventing a call to the driver close while 
executing error processing.

Here is a patch for the napi_enable BUG_ON:

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5ec1f99..e1af6fa 100755
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4242,9 +4242,6 @@ int e1000e_up(struct e1000_adapter *adapter)

         clear_bit(__E1000_DOWN, &adapter->state);

-#ifdef CONFIG_E1000E_NAPI
-       napi_enable(&adapter->napi);
-#endif
  #ifdef CONFIG_E1000E_MSIX
         if (adapter->msix_entries)
                 e1000_configure_msix(adapter);
@@ -4307,10 +4304,6 @@ void e1000e_down(struct e1000_adapter *adapter)
         /* flush both disables and wait for them to finish */
         e1e_flush();
         usleep_range(10000, 20000);
-
-#ifdef CONFIG_E1000E_NAPI
-       napi_disable(&adapter->napi);
-#endif
         e1000_irq_disable(adapter);

         del_timer_sync(&adapter->watchdog_timer);
@@ -4677,6 +4670,10 @@ static int e1000_close(struct net_device *netdev)

         pm_runtime_get_sync(&pdev->dev);

+#ifdef CONFIG_E1000E_NAPI
+       napi_disable(&adapter->napi);
+#endif
+
         if (!test_bit(__E1000_DOWN, &adapter->state)) {
                 e1000e_down(adapter);
                 e1000_free_irq(adapter);
