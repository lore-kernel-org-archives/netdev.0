From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 03:47:13 +0900
Message-ID: <50FC3BB1.4070005@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48957 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752367Ab3ATSrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 13:47:16 -0500
In-Reply-To: <50FC2EE4.3080705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
> I've implemented IPv6 over firewire. Right now I'm facing the problem that the corresponding RFC3146 requires very firewire specific information sent during neighborhood discovery.
> 
> There was already a discussion on the linux1394 mailing list (http://sourceforge.net/mailarchive/message.php?msg_id=30342089 and http://sourceforge.net/mailarchive/forum.php?thread_name=50E4A3E5.8080304%40gmail.com&forum_name=linux1394-devel)
> 
> During that discussion all participants agreed that it makes no sense to introduce a dependency between the ndisc code and the firewire net driver.
> 
> So the most appealing option seems to be to introduce on more callback routine either in struct net_device or struct net_device_ops:
> 
> int (*ndo_fill_llao)(void *llao);
> 
> Because I'm not so familiar with the structure of the whole network infrastructure in Linux, I need some advice if struct net_device or struct net_device_ops is the right place.
> 
> Maybe it's worth to generalize this and do the same for IPv4/ARP because right now the ARP packets are mangled in the firewire net driver.
> 
> Nevertheless, I've to admit that right now it seems that only IPv6 over firewire requires such a callback routine.

My current position is to change "mac address" to

struct fwnet_hwaddr {
	u8	guid[8];
	u8	max_rec;
	u8	sspd;
	u8	fifo[6];
};

Benefits:

[ARP and NDISC]
- both can be handled in more natural way.
-- You will not need to mangle those packets when
   sending/receiving.
-- You do not need to inspect ARP/NDISC packet.
   By using netevent notification mechanism, you can
   learn peer parameters.
-- IP layer is not required to change very much.

[Multicast]
-it can be handled in more natural way.
-- MCAP (Multicast Channel Allocation Protocol) needs to
   know full IP multicast address.
-- We have IP multicast address => "hardware address"
   mapping for each L2 type in IP layer.
-- We expect that IP layer can request net_device to
   receive multicast stream for some multicast address
   via corresponding "hardware address".
-- This means that we need to have "hardware address"
   of 128bits (16 octets) or more.
-- By increasing size of dev->dev_addr, we can embedded
   full IPv6 address in it.

--yoshfuji
