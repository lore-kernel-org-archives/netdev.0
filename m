From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next 4/5] bridge: vlan: fix possible null ptr derefs
 on port init and deinit
Date: Sun, 11 Oct 2015 15:21:18 +0300
Message-ID: <20151011122118.GB2793@colbert.mtl.com>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
 <1443637015-4153-5-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <roopa@cumulusnetworks.com>,
	<vyasevich@gmail.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	"Nikolay Aleksandrov" <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0059.outbound.protection.outlook.com ([157.55.234.59]:44505
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751282AbbJKMzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Oct 2015 08:55:14 -0400
Content-Disposition: inline
In-Reply-To: <1443637015-4153-5-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 30, 2015 at 09:16:54PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>When a new port is being added we need to make vlgrp available after
>rhashtable has been initialized and when removing a port we need to
>flush the vlans and free the resources after we're sure noone can use
>the port, i.e. after it's removed from the port list and synchronize_rcu
>is executed.

Hi Nikolay,

Changing the order of port deinit breaks symmetry with the init
sequence. It also introduces a problem for switchdev drivers. Flushing
the VLANs clears HW VLAN filters and then, when port is unlinked from
bridge and CHANGEUPPER is received, port is configured to direct traffic
to CPU (as it's not offloaded anymore). Doing the reverse (like in this
patch) renders the port unusable.

Regarding the reason for this change, are you afraid that vlgrp will be
accessed in bridge's rx handler or xmit function after it's freed? If
so, maybe we can access it using RCU primitives? That way, both the rx
handler and xmit function (executed under RCU lock) will either have a
valid copy or not. Looking at previous iterations of this code, I see
that was the case with the 'net_port_vlans' struct.

I can start working on a fix if you agree with the proposed solution.

Thanks.
