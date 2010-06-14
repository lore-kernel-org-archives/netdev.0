From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net: deliver skbs on inactive slaves to exact
	matches
Date: Mon, 14 Jun 2010 16:21:20 +0300
Message-ID: <20100614132120.GA24785@redhat.com>
References: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, davem@davemloft.net, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab0FNN0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 09:26:19 -0400
Content-Disposition: inline
In-Reply-To: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 03, 2010 at 12:30:11PM -0700, John Fastabend wrote:
> Currently, the accelerated receive path for VLAN's will
> drop packets if the real device is an inactive slave and
> is not one of the special pkts tested for in
> skb_bond_should_drop().  This behavior is different then
> the non-accelerated path and for pkts over a bonded vlan.
> 
> For example,
> 
> vlanx -> bond0 -> ethx
> 
> will be dropped in the vlan path and not delivered to any
> packet handlers at all.  However,
> 
> bond0 -> vlanx -> ethx
> 
> and
> 
> bond0 -> ethx
> 
> will be delivered to handlers that match the exact dev,
> because the VLAN path checks the real_dev which is not a
> slave and netif_recv_skb() doesn't drop frames but only
> delivers them to exact matches.
> 
> This patch adds a sk_buff flag which is used for tagging
> skbs that would previously been dropped and allows the
> skb to continue to skb_netif_recv().  Here we add
> logic to check for the deliver_no_wcard flag and if it
> is set only deliver to handlers that match exactly.  This
> makes both paths above consistent and gives pkt handlers
> a way to identify skbs that come from inactive slaves.
> Without this patch in some configurations skbs will be
> delivered to handlers with exact matches and in others
> be dropped out right in the vlan path.
> 
> I have tested the following 4 configurations in failover modes
> and load balancing modes.
> 
> # bond0 -> ethx
> 
> # vlanx -> bond0 -> ethx
> 
> # bond0 -> vlanx -> ethx
> 
> # bond0 -> ethx
>             |
>   vlanx -> --
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I am using qemu with both tap and slirp (userspace) networking.
This works fine under 2.6.35-rc2 but breaks under 2.6.35-rc3:
ssh over slirp stops working sometimes right away
and sometimes after a bit of use, connection times out.

Git bisect gave me this commit:
597a264b1a9c7e36d1728f677c66c5c1f7e3b837.

Reverting 597a264b1a9c7e36d1728f677c66c5c1f7e3b837 fixes the issue
for me.

I'm short for time now so didn't debug this further.
I opened a bugzilla to track this issue:
https://bugzilla.kernel.org/show_bug.cgi?id=16204

-- 
MST
