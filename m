From: Martin Vopatek <vopatek@ingate.com>
Subject: iproute2: ip addr flush fail on many secondary addresses
Date: Wed, 12 Mar 2014 15:45:09 +0100
Message-ID: <532072F5.4000304@ingate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neko.ingate.se ([193.180.23.132]:37066 "EHLO neko.ingate.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753073AbaCLOzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 10:55:18 -0400
Received: from [192.168.2.11] (sip.intertex.se [213.136.58.100])
	by neko.ingate.se (Postfix) with ESMTPSA id AABE71F740
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 15:45:09 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

ip addr flush dev eth0

Returns:
Failed to send flush request: Cannot assign requested address
when I have many (> 62) secondary addresses.

Deletion is handled by ipaddr_flush sending two filters
(secondary/primary) to rtnl_dump_filter_l.

With a lot of addresses rtnl_dump_filter_l calls recvmsg
more than once. However, all filters are traversed for each
recv call, so the primary address will be deleted before
all the secondary addresses have been removed.

Running with stat the primary address is not the last.
ip -stat -stat addr flush dev eth0

Flushing secondary/primary addresses has been addressed before:
b49240ec7eab91418d2f090536bf8cd2205988d6
3bc1c4f29777171b484d36abf673667e3729202b

As mentioned there, trying to remove the remaining secondary
addresses will cause an error as they were auto removed when
deleting the primary.

Workaround:
sysctl -w net.ipv4.conf.all.promote_secondaries=1

Regards, vopatek
