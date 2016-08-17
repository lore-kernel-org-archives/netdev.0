From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 17 Aug 2016 11:05:52 +1000
Message-ID: <20160817110552.67a3e615@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: David Miller <davem@davemloft.net>,
	Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/dsa/mv88e6xxx/chip.c

between commit:

  601bbae0bc10 ("dsa: mv88e6xxx: hide unused functions")

from the net tree and commit:

  9c93829c014f ("net: dsa: mv88e6xxx: use the new PHY API")

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

diff --cc drivers/net/dsa/mv88e6xxx/chip.c
index d1d9d3cf9139,a230fcba5b64..000000000000
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@@ -3187,48 -3250,13 +3250,20 @@@ static int mv88e6xxx_set_addr(struct ds
  	return err;
  }
  
- #ifdef CONFIG_NET_DSA_HWMON
- static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
- 				    int reg)
- {
- 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
- 	int ret;
- 
- 	mutex_lock(&chip->reg_lock);
- 	ret = _mv88e6xxx_mdio_page_read(chip, port, page, reg);
- 	mutex_unlock(&chip->reg_lock);
- 
- 	return ret;
- }
- 
- static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
- 				     int reg, int val)
- {
- 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
- 	int ret;
- 
- 	mutex_lock(&chip->reg_lock);
- 	ret = _mv88e6xxx_mdio_page_write(chip, port, page, reg, val);
- 	mutex_unlock(&chip->reg_lock);
- 
- 	return ret;
- }
- #endif
- 
 +static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_chip *chip, int port)
 +{
 +	if (port >= 0 && port < chip->info->num_ports)
 +		return port;
 +	return -EINVAL;
 +}
 +
- static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
+ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
  {
  	struct mv88e6xxx_chip *chip = bus->priv;
- 	int addr = mv88e6xxx_port_to_mdio_addr(chip, port);
- 	int ret;
+ 	u16 val;
+ 	int err;
  
- 	if (addr < 0)
+ 	if (phy >= chip->info->num_ports)
  		return 0xffff;
  
  	mutex_lock(&chip->reg_lock);
