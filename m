From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/3] Fix Network namespace shutdown take 2
Date: Fri, 20 Feb 2009 07:47:01 -0800
Message-ID: <m1ocwxi00a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>,
	"Denis V. Lunev" <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35934 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758284AbZBTPqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 10:46:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


6 months ago when I introduced net_alive I fixed the symptoms
but I failed to properly fix network namespace shutdown.

I realized this when I received a bug report on Tuesday about a
failure in icmp_send caused by packets in the arp_gueue.

It turns out that the net_alive check in netif_receive_skb
is completely unnecessary and just masked the real problem.

If we remove all network devices from a network namespace before we
shutdown network subsystems and protocols then as designed we cannot
have packets in flight causing problems.

It turns out that the root cause of these problems is that the icmp
code was calling register_pernet_device instead of
register_pernet_subsys and so it's cleanup was happening much too
early.

The following patchset which should work against both 2.6.29-rcX
and net-next fixes the registration problems and removes the
unncessary net_alive check, making the code simpler and hopefully
more comprehensible.

Eric
