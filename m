From: Tony Asleson <linux.netdev.list@gmail.com>
Subject: Kernel behavior when returning NETDEV_TX_BUSY from hard_start_xmit
Date: Thu, 19 Feb 2009 14:19:10 -0600
Message-ID: <587a3eeb0902191219r1c3e61dbkee1a5b45dceacc1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:37477 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbZBSUTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 15:19:11 -0500
Received: by yw-out-2324.google.com with SMTP id 5so236530ywh.1
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2009 12:19:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am running into the following scenario and I wanted to verify that it is
expected.

A user application does a single 8k UDP send.  While the Ethernet device
driver is accepting each skb via hard_start_xmit it temporarily runs out
of resources and calls netif_stop_queue and returns NETDEV_TX_BUSY.
When the driver catches up it does a netif_wake_queue to resume skb
transmission.  When this occurs during the UDP send, the Ethernet driver
does not get any of the remaining skb buffers and the UDP send is
incomplete.  However, the user application returns from the sendto
with success.

Because UDP has no guaranteed delivery this seems like an acceptable thing.
However, if a device driver imposes a limit to the number of skb buffers
it can handle in flight which is < the total number of skb buffers it takes
to complete.  The operation will never be successful.

For example, to support a single 64k UDP send, the device driver must be
able to accept ~45 skb buffers (1500 MTU) without returning NETDEV_TX_BUSY.
If the Ethernet device is unable to transmit faster than the arrival rate
of skb buffers the driver then needs to queue them up.

Is this expected behavior or am I missing something in my driver?  How
much should a device driver be expected to queue before calling
netif_stop_queue and ensure normal packet transmission?  Why doesn't
the network stack continue after the queue has been stopped?

Notes:
-Linux 2.6.16.21 kernel (sles 10) embedded PPC platform.
-Pseudo Ethernet device in question has ~2.8 MiB bandwidth.

Many thanks!
-Tony
