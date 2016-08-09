From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 9 Aug 2016 14:10:59 -0700
Message-ID: <20160809211058.GP22974@cork>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
 <57A9DA8D.3010407@huawei.com>
 <20160809180830.GM22974@cork>
 <20160809.120636.2039586307820412288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dingtianhong@huawei.com, zyjzyj2000@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33011 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324AbcHIVLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:11:06 -0400
Received: by mail-pf0-f178.google.com with SMTP id y134so8532051pfg.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:11:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160809.120636.2039586307820412288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2016 at 12:06:36PM -0700, David Miller wrote:
> > On Tue, Aug 09, 2016 at 09:28:45PM +0800, Ding Tianhong wrote:
> > 
> > Simply not checking errors when setting the mac address solves the
> > problem for me.  No new features needed.
> 
> But it only works in certain modes.
> 
> So the best we can do is enforce the MAC address setting in the
> modes that absolutely require it.  We cannot ignore the MAC
> address setting unilaterally.

Something like this?

[PATCH] bonding: Allow tun-interfaces as slaves in balance-rr mode

Up until 00503b6f702e (part of 3.14-rc1), the bonding driver could be
used to enslave tun-interfaces.  00503b6f702e broke that behaviour,
afaics as an unintended side-effect.

For the purpose of bond-over-tun in balance-rr mode, simply ignoring the
error from dev_set_mac_address() is good enough.

Signed-off-by: Joern Engel <joern@purestorage.com>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1f276fa30ba6..2f686bfe4304 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1490,7 +1490,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
 		addr.sa_family = slave_dev->type;
 		res = dev_set_mac_address(slave_dev, &addr);
-		if (res) {
+		/* round-robin mode works fine without a mac address */
+		if (res && BOND_MODE(bond) != BOND_MODE_ROUNDROBIN) {
 			netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
 			goto err_restore_mtu;
 		}
-- 
2.1.4
