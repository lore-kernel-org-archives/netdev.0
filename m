From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Mon, 12 Sep 2016 15:16:20 +0200
Message-ID: <20160912131620.GB17533@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473669337-21221-4-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static u32
> +qca8k_mii_read32(struct mii_bus *bus, int phy_id, u32 regnum)
> +{
> +	u16 lo, hi;
> +
> +	lo = bus->read(bus, phy_id, regnum);
> +	hi = bus->read(bus, phy_id, regnum + 1);
> +
> +	return (hi << 16) | lo;
> +}
> +
> +static void
> +qca8k_mii_write32(struct mii_bus *bus, int phy_id, u32 regnum, u32 val)
> +{
> +	u16 lo, hi;
> +
> +	lo = val & 0xffff;
> +	hi = (u16)(val >> 16);
> +
> +	bus->write(bus, phy_id, regnum, lo);
> +	bus->write(bus, phy_id, regnum + 1, hi);
> +}

Hi John

Thanks for picking up this driver and continuing its journey towards
mainline.

bus->read() and bus->write() can return an error code. There is a lot
of error handling in the mv88e6xxx driver looking at the error code
from these two functions. And it very rarely happens. So it seems
overkill to me. However, i have had errors, when bringing up a new
board and the device tree is wrong somehow.

But ignoring potential error altogether does not seem wise. I think at
minimum you should look at the return code in these functions and do a
rate limited dev_err().

> +
> +static void
> +qca8k_set_page(struct mii_bus *bus, u16 page)
> +{
> +	if (page == qca8k_current_page)
> +		return;
> +
> +	bus->write(bus, 0x18, 0, page);
> +	udelay(5);

Is that delay in the data sheet? What about other accesses, like
reading the stats which is going to generate a lot of back to back
reads?

> +	qca8k_current_page = page;
> +}
> +
> +static u32
> +qca8k_read(struct qca8k_priv *priv, u32 reg)
> +{
> +	u16 r1, r2, page;
> +	u32 val;
> +
> +	qca8k_split_addr(reg, &r1, &r2, &page);
> +
> +	mutex_lock(&priv->bus->mdio_lock);
> +
> +	qca8k_set_page(priv->bus, page);
> +	val = qca8k_mii_read32(priv->bus, 0x10 | r2, r1);
> +
> +	mutex_unlock(&priv->bus->mdio_lock);
> +
> +	return val;
> +}
> +
> +static void
> +qca8k_write(struct qca8k_priv *priv, u32 reg, u32 val)
> +{
> +	u16 r1, r2, page;
> +
> +	qca8k_split_addr(reg, &r1, &r2, &page);
> +
> +	mutex_lock(&priv->bus->mdio_lock);
> +
> +	qca8k_set_page(priv->bus, page);
> +	qca8k_mii_write32(priv->bus, 0x10 | r2, r1, val);
> +
> +	mutex_unlock(&priv->bus->mdio_lock);
> +}
> +
> +static u32
> +qca8k_rmw(struct qca8k_priv *priv, u32 reg, u32 mask, u32 val)
> +{
> +	u16 r1, r2, page;
> +	u32 ret;
> +
> +	qca8k_split_addr(reg, &r1, &r2, &page);
> +
> +	mutex_lock(&priv->bus->mdio_lock);
> +
> +	qca8k_set_page(priv->bus, page);
> +	ret = qca8k_mii_read32(priv->bus, 0x10 | r2, r1);
> +	ret &= ~mask;
> +	ret |= val;
> +	qca8k_mii_write32(priv->bus, 0x10 | r2, r1, ret);
> +
> +	mutex_unlock(&priv->bus->mdio_lock);
> +
> +	return ret;
> +}
> +
> +static inline void
> +qca8k_reg_set(struct qca8k_priv *priv, u32 reg, u32 val)
> +{
> +	qca8k_rmw(priv, reg, 0, val);
> +}
> +
> +static inline void
> +qca8k_reg_clear(struct qca8k_priv *priv, u32 reg, u32 val)
> +{
> +	qca8k_rmw(priv, reg, val, 0);
> +}

Drop the inline please.

> +static u16
> +qca8k_phy_mmd_read(struct qca8k_priv *priv, int phy_addr, u16 addr, u16 reg)
> +{
> +	u16 data;
> +
> +	mutex_lock(&priv->bus->mdio_lock);
> +
> +	priv->bus->write(priv->bus, phy_addr, MII_ATH_MMD_ADDR, addr);
> +	priv->bus->write(priv->bus, phy_addr, MII_ATH_MMD_DATA, reg);
> +	priv->bus->write(priv->bus, phy_addr, MII_ATH_MMD_ADDR, addr | 0x4000);
> +	data = priv->bus->read(priv->bus, phy_addr, MII_ATH_MMD_DATA);
> +
> +	mutex_unlock(&priv->bus->mdio_lock);

Have you run lockdep on this? The mv88e6xxx has something similar, and
were getying false positive splats. We needed to use
mdiobus_write_nested(). Since you are using bus->write directly, not
using the wrapper, maybe this is not an issue. But i'm wondering if
ignoring the wrapped is the right thing to do, with nested MDIO
busses. Something i need to think about.

> +static int
> +qca8k_fdb_busy_wait(struct qca8k_priv *priv)
> +{
> +	unsigned long timeout;
> +
> +	timeout = jiffies + msecs_to_jiffies(20);
> +
> +	/* loop until the busy flag has cleared */
> +	do {
> +		u32 reg = qca8k_read(priv, QCA8K_REG_ATU_FUNC);
> +		int busy = reg & QCA8K_ATU_FUNC_BUSY;
> +
> +		if (!busy)
> +			break;
> +	} while (!time_after_eq(jiffies, timeout));
> +
> +	return time_after_eq(jiffies, timeout);
> +}

No sleep? You busy loop for 20ms?

> +
> +static void
> +qca8k_fdb_read(struct qca8k_priv *priv, struct qca8k_fdb *fdb)
> +{
> +	u32 reg[4];
> +	int i;
> +
> +	/* load the ARL table into an array */
> +	for (i = 0; i < 4; i++)
> +		reg[i] = qca8k_read(priv, QCA8K_REG_ATU_DATA0 + (i * 4));
> +
> +	/* vid - 83:72 */
> +	fdb->vid = (reg[2] >> QCA8K_ATU_VID_S) & QCA8K_ATU_VID_M;
> +	/* aging - 67:64 */
> +	fdb->aging = reg[2] & QCA8K_ATU_STATUS_M;
> +	/* portmask - 54:48 */
> +	fdb->port_mask = (reg[1] >> QCA8K_ATU_PORT_S) & QCA8K_ATU_PORT_M;
> +	/* mac - 47:0 */
> +	fdb->mac[0] = (reg[1] >> QCA8K_ATU_ADDR0_S) & 0xff;
> +	fdb->mac[1] = reg[1] & 0xff;
> +	fdb->mac[2] = (reg[0] >> QCA8K_ATU_ADDR2_S) & 0xff;
> +	fdb->mac[3] = (reg[0] >> QCA8K_ATU_ADDR3_S) & 0xff;
> +	fdb->mac[4] = (reg[0] >> QCA8K_ATU_ADDR4_S) & 0xff;
> +	fdb->mac[5] = reg[0] & 0xff;
> +}
> +
> +static void
> +qca8k_fdb_write(struct qca8k_priv *priv, u16 vid, u8 port_mask, const u8 *mac,
> +		u8 aging)
> +{
> +	u32 reg[3] = { 0 };
> +	int i;
> +
> +	/* vid - 83:72 */
> +	reg[2] = (vid & QCA8K_ATU_VID_M) << QCA8K_ATU_VID_S;
> +	/* aging - 67:64 */
> +	reg[2] |= aging & QCA8K_ATU_STATUS_M;
> +	/* portmask - 54:48 */
> +	reg[1] = (port_mask & QCA8K_ATU_PORT_M) << QCA8K_ATU_PORT_S;
> +	/* mac - 47:0 */
> +	reg[1] |= mac[0] << QCA8K_ATU_ADDR0_S;
> +	reg[1] |= mac[1];
> +	reg[0] |= mac[2] << QCA8K_ATU_ADDR2_S;
> +	reg[0] |= mac[3] << QCA8K_ATU_ADDR3_S;
> +	reg[0] |= mac[4] << QCA8K_ATU_ADDR4_S;
> +	reg[0] |= mac[5];
> +
> +	/* load the array into the ARL table */
> +	for (i = 0; i < 3; i++)
> +		qca8k_write(priv, QCA8K_REG_ATU_DATA0 + (i * 4), reg[i]);
> +}
> +
> +static int
> +qca8k_fdb_access(struct qca8k_priv *priv, enum qca8k_fdb_cmd cmd, int port)
> +{
> +	u32 reg;
> +
> +	/* Set the command and FDB index */
> +	reg = QCA8K_ATU_FUNC_BUSY;
> +	reg |= cmd;
> +	if (port >= 0) {
> +		reg |= QCA8K_ATU_FUNC_PORT_EN;
> +		reg |= (port && QCA8K_ATU_FUNC_PORT_M) << QCA8K_ATU_FUNC_PORT_S;
> +	}
> +
> +	/* Write the function register triggering the table access */
> +	qca8k_write(priv, QCA8K_REG_ATU_FUNC, reg);
> +
> +	/* wait for completion */
> +	if (qca8k_fdb_busy_wait(priv))
> +		return -1;
> +
> +	return 0;
> +}
> +
> +static int
> +qca8k_fdb_next(struct qca8k_priv *priv, struct qca8k_fdb *fdb, int port)
> +{
> +	int ret;
> +
> +	qca8k_fdb_write(priv, fdb->vid, fdb->port_mask, fdb->mac, fdb->aging);
> +	ret = qca8k_fdb_access(priv, QCA8K_FDB_NEXT, port);
> +	if (ret >= 0)
> +		qca8k_fdb_read(priv, fdb);
> +
> +	return ret;
> +}

So a big picture question. How does locking work?

qca8k_fdb_write() will take and release the MDIO bus
lock. qca8k_fdb_access() will also multiple times take and release the
lock and then qca8k_fdb_read() will take and release the lock a few
times. So it seems like there are multiple opportunities for a race
condition, multiple parallel calls to qca8k_fdb_next() for different
ports. Is this addresses somewhere?

I'm out of time for the moment. More comments later.

    Andrew
