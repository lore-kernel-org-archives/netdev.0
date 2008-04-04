From: Pavel Emelyanov <xemul@openvz.org>
Subject: [RFC][PATCH 0/3] Make loopback device weight twice as little.
Date: Fri, 04 Apr 2008 18:09:05 +0400
Message-ID: <47F63681.1030603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33460 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbYDDNpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 09:45:30 -0400
Received: from [10.30.3.76] (swsoft-msk-nat.sw.ru [195.214.232.10])
	(authenticated bits=0)
	by sacred.ru (8.13.8/8.13.8) with ESMTP id m34DjM8v007736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 4 Apr 2008 17:45:22 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed, that on a 32bit box with a non-debug config the 
sizeof(struct net_device) is slightly more than 1024. This 
means, that for example loopback device (with sizeof_priv == 0) 
is allocated from the size-2048 cache and thus we have ~1000
wasted bytes.

I know, that this is not that much, all the more so on most of
the setups the lo device is single :) but with the net-namespaced
kernel each namespace has its own loopback device, so this problem
becomes more relevant.

I also guess, that the net_device struct allows many ways to get
shrunk, but I noticed, that is has ~20 pointers on functions for
different purposes, like init, hard_start_xmit, neigh_setup, etc.

The proposal is to _move_ all these callbacks on a new structure
called net_device_ops and put a pointer on it on the net_device.
I've checked how much will the net_device weigh after this and
it turned out, that this difference (80 bytes) is enough to get
the 1024-sized net_device and thus a halved loopback.

To make this change smooth, I propose the following plan (however,
three patches I sent will demonstrate the idea better). 

* First - declare an empty nd_default_ops and make all new devices 
  point on this new ops temporarily. 
* Then replace each call to dev->xxx() with the dev->nd_ops->xxx() 
  one step by step. The ns_ops->xxx() will be the nd_default_ops->xxx
  then and they all will (temporarily) look like
	static void nd_default_xxx(struct net_device *dev, ...)
	{
		if (dev->xxx)
			dev->xxx(dev, ...)
	}
* After this patch switch all the drivers (lots of work :( but it can
  be done driver-by-driver, i.e. without HUGE patches) from on-device
  ops to nd_ops pointer.
* Finally - remove all the ops from the net_device and the default 
  stubs described above.

Does this idea worth being developed further?

Thanks,
Pavel
