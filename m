From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Mon, 18 Sep 2017 20:27:13 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170907223625.GW11248@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +/**
> > + * Some counters do not need to be read too often because they are less
> likely
> > + * to increase much.
> > + */
> 
> What does comment mean? Are you caching statistics, and updating
> different values at different rates?
> 

There are 34 counters.  In normal case using generic bus I/O or PCI to read them
is very quick, but the switch is mostly accessed using SPI, or even I2C.  As the SPI
access is very slow and cannot run in interrupt context I keep worrying reading
the MIB counters in a loop for 5 or more ports will prevent other critical hardware
access from executing soon enough.  These accesses can be getting 1588 PTP
timestamps and opening/closing ports.  (RSTP Conformance Test sends test traffic
to port supposed to be closed/opened after receiving specific RSTP BPDU.)

> > +static const struct {
> > +	int interval;
> > +	char string[ETH_GSTRING_LEN];
> > +} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
> > +	{ 1, "rx_hi" },
> > +	{ 4, "rx_undersize" },
> > +	{ 4, "rx_fragments" },
> > +	{ 4, "rx_oversize" },
> > +	{ 4, "rx_jabbers" },
> > +	{ 4, "rx_symbol_err" },
> > +	{ 4, "rx_crc_err" },
> > +	{ 4, "rx_align_err" },
> > +	{ 4, "rx_mac_ctrl" },
> > +	{ 1, "rx_pause" },
> > +	{ 1, "rx_bcast" },
> > +	{ 1, "rx_mcast" },
> > +	{ 1, "rx_ucast" },
> > +	{ 2, "rx_64_or_less" },
> > +	{ 2, "rx_65_127" },
> > +	{ 2, "rx_128_255" },
> > +	{ 2, "rx_256_511" },
> > +	{ 2, "rx_512_1023" },
> > +	{ 2, "rx_1024_1522" },
> > +	{ 2, "rx_1523_2000" },
> > +	{ 2, "rx_2001" },
> > +	{ 1, "tx_hi" },
> > +	{ 4, "tx_late_col" },
> > +	{ 1, "tx_pause" },
> > +	{ 1, "tx_bcast" },
> > +	{ 1, "tx_mcast" },
> > +	{ 1, "tx_ucast" },
> > +	{ 4, "tx_deferred" },
> > +	{ 4, "tx_total_col" },
> > +	{ 4, "tx_exc_col" },
> > +	{ 4, "tx_single_col" },
> > +	{ 4, "tx_mult_col" },
> > +	{ 1, "rx_total" },
> > +	{ 1, "tx_total" },
> > +	{ 2, "rx_discards" },
> > +	{ 2, "tx_discards" },
> > +};

> > +{
> > +	u32 data;
> > +	u16 ctrl_addr;
> > +	u8 check;
> > +	int timeout;
> > +
> > +	ctrl_addr = addr + SWITCH_COUNTER_NUM * port;
> > +
> > +	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
> > +	mutex_lock(&dev->stats_mutex);
> > +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> > +
> > +	for (timeout = 1; timeout > 0; timeout--) {
> 
> A rather short timeount!
> 
> > +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> > +
> > +		if (check & MIB_COUNTER_VALID) {
> > +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> > +			if (check & MIB_COUNTER_OVERFLOW)
> > +				*cnt += MIB_COUNTER_VALUE + 1;
> > +			*cnt += data & MIB_COUNTER_VALUE;
> > +			break;
> > +		}
> 
> Should there be a dev_err() here about timing out?
> 

The timeout value should be at least 2.  Hardware datasheet says the
valid bit should be checked, but in my experience it is always there.
Maybe a very slow SPI access speed can make that happen, but it is
pointless to run in slow speed if the system can run in the fastest speed
possible.
 
> > +static void ksz_r_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 *val)
> > +{
> > +	struct ksz_port *port;
> > +	u8 ctrl;
> > +	u8 restart;
> > +	u8 link;
> > +	u8 speed;
> > +	u8 force;
> > +	u8 p = phy;
> > +	u16 data = 0;
> > +	int processed = true;
> > +
> > +	port = &dev->ports[p];
> > +	switch (reg) {
> > +	case PHY_REG_CTRL:
> > +		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
> > +		ksz_pread8(dev, p, P_NEG_RESTART_CTRL, &restart);
> > +		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
> > +		ksz_pread8(dev, p, P_FORCE_CTRL, &force);
> > +		if (restart & PORT_PHY_LOOPBACK)
> > +			data |= PHY_LOOPBACK;
> > +		if (force & PORT_FORCE_100_MBIT)
> > +			data |= PHY_SPEED_100MBIT;
> > +		if (!(force & PORT_AUTO_NEG_DISABLE))
> > +			data |= PHY_AUTO_NEG_ENABLE;
> > +		if (restart & PORT_POWER_DOWN)
> > +			data |= PHY_POWER_DOWN;
> 
> Same questions i asked Pavel
> 
> Is there a way to access the PHY registers over SPI? The datasheet
> suggests there is, but it does not say how, as far as i can tell.
> 
> Ideally, we want to use just a normal PHY driver.
>

The switch does not have actual PHY registers when used in SPI mode,
so the PHY register access has to be simulated.

A side-note is the PHY device id returned will pair the PHY with one of
the Micrel PHYs defined in the kernel.  I just found out the new phylib
code removed the Asymmetric/Symmetric Pause support in the PHY
driver and let the MAC driver indicate the support.  This is reasonable
as the MAC is responsible for sending and processing PAUSE frames.
However, the PHY in the switch port is not connected to the MAC.
Is there a way to indicate this support in the DSA model?

Ideally the switch should have control over which Pause mode should
be enabled.  Generally Asymmetric Pause is used in Gigabit switch, and
flow control is better disabled if some other traffic shaping is used.

> > +static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
> > +				  uint64_t *buf)
> > +{
> > +	struct ksz_device *dev = ds->priv;
> > +	struct ksz_port_mib *mib;
> > +	struct ksz_port_mib_info *info;
> > +	int i;
> > +
> > +	mib = &dev->ports[port].mib;
> > +
> > +	spin_lock(&dev->mib_read_lock);
> > +	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
> > +		info = &mib->info[i];
> > +		buf[i] = info->counter;
> > +		info->read_cnt += info->read_max;
> > +	}
> > +	spin_unlock(&dev->mib_read_lock);
> > +
> > +	mib->ctrl = 1;
> > +	schedule_work(&dev->mib_read);
> 
> Humm. I want to take a closer look at this caching code...

The switch needs to read MIB counters periodically as the counters
will overflow when there are lots of traffic.  The current
implementation is to read all ports every second but not all at the
same time as the operation may block other critical hardware
register access.

The idea is if the users check the MIB counters once they will check
them again very soon to note which counter has been increased.
