From: Jiri Slaby <jirislaby@gmail.com>
Subject: bonding: potential null dereference?
Date: Fri, 08 Jan 2010 11:16:38 +0100
Message-ID: <4B470606.7090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:17253 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab0AHKQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 05:16:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm looking at Stanse errors and it detected a suspected behaviour in
bonding. In bond_slave_netdev_event, bond_dev is passed down to
netdev_priv, but due to 'if (bond_dev)' test later, it deduced it can be
also NULL.

I can see, that passing NULL to netdev_priv is OK nowadays, as it just
returns NULL + some offset. But what if this changes in the future?

I would bake a patch, but I don't know if bond_dev may be NULL at all
(i.e. superfluous test) or may not (wrong netdev_priv(bond_dev)).

static int (unsigned long event,
                                   struct net_device *slave_dev)
{
        struct net_device *bond_dev = slave_dev->master;
        struct bonding *bond = netdev_priv(bond_dev);

        switch (event) {
        case NETDEV_UNREGISTER:
                if (bond_dev) {
                        if (bond->setup_by_slave)
                                bond_release_and_destroy(bond_dev,
slave_dev);
                        else
                                bond_release(bond_dev, slave_dev);
                }
                break;

-- 
js
