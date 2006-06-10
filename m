From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 10 Jun 2006 20:37:15 +0100
Message-ID: <448B1F6B.2020809@gentoo.org>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:52821 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030504AbWFJTf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 15:35:57 -0400
To: Oliver Neukum <oliver@neukum.org>
In-Reply-To: <200606031951.09135.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> +static void disconnect(struct usb_interface *intf)
> +{
> 
> This is racy. It allows io to disconnected devices. You must take the
> lock and set a flag that you test after you've taken the lock elsewhere.

It's been a bit of an adventure, but I'm now fairly confident that only 
a single-line change is required to fix this: stop the TX queue early on 
in the netdev->stop function.

When disconnect() happens, we call unregister_netdev(). This will call 
netdev->stop if the interface was up, and netdev->stop ensures that no 
more packets are queued for transmission, and that the host does not 
receive any more packets or interrupts from the device.

unregister_netdev() also does some synchronization and rtnl stuff, and 
after it has returned, it is guaranteed that no ioctls or other 
functions (hard_start_xmit/set_mac_address) are in progress, and it is 
guaranteed that no more of those will happen.

In disconnect() we also kill all urbs that we know about. All of our URB 
completions handle the cancelled case without generating further I/O.

Additionally, the return values of all of our usb I/O function calls are 
checked and propagated up, so most code will simply stop when the device 
gets unplugged.

At this point, it's now safe to say that nobody is using (or will use) 
the various structures, so disconnect() frees the whole lot and returns.

Do you agree, or did you have certain other race paths in mind which I 
might have missed?

Thanks,
Daniel
