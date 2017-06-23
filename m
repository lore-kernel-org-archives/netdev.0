From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 23 Jun 2017 11:12:07 +1000
Message-ID: <20170623111207.4c1663fa@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/macvlan.c

between commits:

  e26f43faa0d7 ("macvlan: Do not return error when setting the same mac address")
  18c8c54de9a6 ("macvlan: Let passthru macvlan correctly restore lower mac address")

from the net tree and commit:

  a88e2676a6cd ("macvlan: propagate the mac address change status for lowerdev")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/macvlan.c
index 72b801803aa4,8ca274c6df3d..000000000000
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@@ -743,15 -703,8 +743,14 @@@ static int macvlan_set_mac_address(stru
  	if (!is_valid_ether_addr(addr->sa_data))
  		return -EADDRNOTAVAIL;
  
 -	if (vlan->mode == MACVLAN_MODE_PASSTHRU)
 +	/* If the addresses are the same, this is a no-op */
 +	if (ether_addr_equal(dev->dev_addr, addr->sa_data))
 +		return 0;
 +
 +	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
 +		macvlan_set_addr_change(vlan->port);
- 		dev_set_mac_address(vlan->lowerdev, addr);
- 		return 0;
+ 		return dev_set_mac_address(vlan->lowerdev, addr);
 +	}
  
  	return macvlan_sync_address(dev, addr->sa_data);
  }
