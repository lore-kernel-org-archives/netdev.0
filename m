From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: xen-netfront: bug with napi_synchronize()
Date: Thu, 20 Aug 2015 16:50:01 -0400
Message-ID: <1440103801.2546.14.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:32966 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbHTUuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:50:04 -0400
Received: by qged69 with SMTP id d69so35673142qge.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 13:50:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have seen some hangs in recent versions of the xen-netfront driver.
If I unload or unbind the driver immediately befor bringing up the
interface, I get a hang as show in the traceback here.


...
[  194.037351]  [<ffffffff810ae1a7>] ? msleep+0x27/0x30
[  194.037358]  [<ffffffffa004b48a>] ? xennet_disconnect_backend+0xfa/0x390 [xen_netfront]
[  194.037364]  [<ffffffffa004b789>] ? xennet_remove+0x19/0x60 [xen_netfront]
[  194.037368]  [<ffffffff8132971b>] ? xenbus_dev_remove+0x4b/0xa0
[  194.037375]  [<ffffffff8137bf41>] ? __device_release_driver+0x81/0x120
[  194.037378]  [<ffffffff8137bffd>] ? device_release_driver+0x1d/0x30
[  194.037382]  [<ffffffff8137b340>] ? unbind_store+0xf0/0x150
...

This offset in xennet_disconnect_backend is approximately in the area
of napi_synchronize().  napi_synchronize() does contain an msleep()
and nothing else would really sleep in this routine.

                queue->tx_evtchn = queue->rx_evtchn = 0;
                queue->tx_irq = queue->rx_irq = 0;

                napi_synchronize(&queue->napi);

                xennet_release_tx_bufs(queue);
                xennet_release_rx_bufs(queue);

Since I never started the interface, I know napi_enable() was never
called on queue->napi.  However, what is the expected behavior for
napi_synchronize() on something that was never enabled/disabled?
