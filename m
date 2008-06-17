From: Ben Greear <greearb@candelatech.com>
Subject: Add/Delete IPv6 addresses and netlink
Date: Mon, 16 Jun 2008 18:33:36 -0700
Message-ID: <48571470.7010307@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:60184 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbYFQBdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 21:33:37 -0400
Received: from [71.113.76.161] (pool-71-113-76-161.sttlwa.dsl-w.verizon.net [71.113.76.161])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m5H1Xa0v005310
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 18:33:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not sure this is a bug, but it is at least making my life difficult 
in user-space.

This is with 2.6.25.4 kernel plus some of my own hackings not directly 
related
to ipv6.

First:
You can get a state where you never get a netlink address add message, but
you do get the delete message.  Eth0 has no link, by the way, but it 
does not
seem to matter in this particular case:

ip -6 addr flush eth0
ip link set dev eth0 down
ip -6 addr add 2000::8:2/112 scope global dev eth0
ip -6 addr flush eth0

I would much prefer to have a netlink message when the address is added, 
regardless of
whether it is tentative or not.  A new message could be sent when it 
changes state to/from tentative.
As it is, there is no way to verify that an IP address was actually 
added by listening to netlink
messages if the address stays tentative.

Second:

NOTE:  I cannot reproduce this problem on FC8's 2.6.24.7-92.fc8 kernel 
on a different
machine.  It may just be something lame about my development 
environment, the different
hardware, or perhaps some issue with the newer lkml kernel.

I am not sure whether I am just confused about how all of this is 
supposed to work or not, but the
following commands will leave the global address in tentative state:

ip link set eth1 down; ip -6 addr flush dev eth1;
ip -6 addr add 2000::9:2/112 scope global dev eth1
ip link set eth1 up
# Wait 10+ seconds
ip -6 addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2000::9:2/112 scope global tentative
       valid_lft forever preferred_lft forever
    inet6 fe80::203:2dff:fe0c:d022/64 scope link
       valid_lft forever preferred_lft forever

If you add the global addr while the device is already up, however, then 
it will not be in
tentative state.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


