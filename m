From: Daniel Drake <dsd@gentoo.org>
Subject: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Fri, 09 Jun 2006 00:14:05 +0100
Message-ID: <4488AF3D.2040601@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:24291 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S965045AbWFHXNC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 19:13:02 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In order to avoid disconnect races in ZD1211, I'm trying to convince 
myself that other USB network drivers are race-free (and why).

I brought up a possible issue in usbnet with David Brownell, but it 
appears neither of us are 100% clear on the details, so it would be good 
to get some extra clarification.

USB devices can be yanked out by the user at *any* time, and typically 
free_netdev is called in the disconnect handler, which frees all 
device-specific structures.

The issue I brought up is that code using these structures may be 
running concurrently on another CPU when the disconnect handler is 
invoked, resulting in access to freed data.

More specifically, we're talking about drivers/usb/net/usbnet.c and the 
usbnet_disconnect() function.  The race I am highlighting is that 
usbnet's hard_start_xmit handler (usbnet_start_xmit) may be running when 
the disconnect happens.

Is this a possible scenario?

My thoughts on avoiding this are to ensure that the TX queue is stopped 
and all current transmissions in usbnet_stop (the netdev->stop hook). I 
understand that the stop function is called during disconnect, because 
usbnet_disconnect() calls unregister_netdev(). The stop function already 
has a call to netif_stop_queue but (based on my knowledge from LDD3) 
this is not enough.

My understanding is that netif_stop_queue() should be used only inside a 
hard_start_xmit function, when it wants to make sure that no more 
transmissions are started until the queue is reopened.

I suggested that we use netif_tx_disable here, which is effectively the 
same but because it takes the lock, it guarantees that no 
hard_start_xmit transmissions are running on any CPU when it returns.

David pointed out that netif_tx_disable is rarely used, and a large 
number of drivers call netif_stop_queue in their stop function, so if 
what I suggest is true, there may be many such potential races 
elsewhere. Am I missing something simple?

Thanks,
Daniel
