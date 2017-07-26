From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 08/10] net: dsa: lan9303: Added ALR/fdb/mdb
 handling
Date: Wed, 26 Jul 2017 19:41:54 +0200
Message-ID: <20170726174154.GS12049@lunn.ch>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-9-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170725161553.30147-9-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil

> +/* This function will wait a while until mask & reg == value */
> +/* Otherwise, return timeout */
> +static int lan9303_csr_reg_wait(struct lan9303 *chip, int regno,
> +				int mask, char value)
> +{
> +	int i;
> +
> +	for (i = 0; i < 0x1000; i++) {
> +		u32 reg;
> +
> +		lan9303_read_switch_reg(chip, regno, &reg);
> +		if ((reg & mask) == value)
> +			return 0;
> +	}
> +	return -ETIMEDOUT;

Busy looping is probably not a good idea. Can you add a usleep()?

> +}
> +
> +static int _lan9303_alr_make_entry_raw(struct lan9303 *chip, u32 dat0, u32 dat1)

What does the _ indicate. I could understand having it when you have
lan9303_alr_make_entry_raw() call _lan9303_alr_make_entry_raw() after
taking a lock, but i don't see anything like that here.

> +{
> +	lan9303_write_switch_reg(
> +		chip, LAN9303_SWE_ALR_WR_DAT_0, dat0);
> +	lan9303_write_switch_reg(
> +		chip, LAN9303_SWE_ALR_WR_DAT_1, dat1);
> +	lan9303_write_switch_reg(
> +		chip, LAN9303_SWE_ALR_CMD, ALR_CMD_MAKE_ENTRY);
> +	lan9303_csr_reg_wait(
> +		chip, LAN9303_SWE_ALR_CMD_STS, ALR_STS_MAKE_PEND, 0);
> +	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
> +	return 0;
> +}
> +
> +typedef void alr_loop_cb_t(
> +	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx);
> +
> +static void lan9303_alr_loop(struct lan9303 *chip, alr_loop_cb_t *cb, void *ctx)
> +{
> +	int i;
> +
> +	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, ALR_CMD_GET_FIRST);
> +	lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
> +
> +	for (i = 1; i < LAN9303_NUM_ALR_RECORDS; i++) {
> +		u32 dat0, dat1;
> +		int alrport, portmap;
> +
> +		lan9303_read_switch_reg(chip, LAN9303_SWE_ALR_RD_DAT_0, &dat0);
> +		lan9303_read_switch_reg(chip, LAN9303_SWE_ALR_RD_DAT_1, &dat1);
> +		if (dat1 & ALR_DAT1_END_OF_TABL)
> +			break;
> +
> +		alrport = (dat1 & ALR_DAT1_PORT_MASK) >> ALR_DAT1_PORT_BITOFFS;
> +		portmap = alrport_2_portmap[alrport];
> +
> +		cb(chip, dat0, dat1, portmap, ctx);
> +
> +		lan9303_write_switch_reg(
> +			chip, LAN9303_SWE_ALR_CMD, ALR_CMD_GET_NEXT);
> +		lan9303_write_switch_reg(chip, LAN9303_SWE_ALR_CMD, 0);
> +	}
> +}
> +
> +/* ALR: lan9303_alr_loop callback functions */
> +
> +static void _alr_reg_to_mac(u32 dat0, u32 dat1, u8 mac[6])
> +{
> +	mac[0] = (dat0 >>  0) & 0xff;
> +	mac[1] = (dat0 >>  8) & 0xff;
> +	mac[2] = (dat0 >> 16) & 0xff;
> +	mac[3] = (dat0 >> 24) & 0xff;
> +	mac[4] = (dat1 >>  0) & 0xff;
> +	mac[5] = (dat1 >>  8) & 0xff;
> +}
> +
> +/* Clear learned (non-static) entry on given port */
> +static void alr_loop_cb_del_port_learned(
> +	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx)
> +{
> +	int *port = ctx;
> +
> +	if (((BIT(*port) & portmap) == 0) || (dat1 & ALR_DAT1_STATIC))
> +		return;
> +
> +	/* learned entries has only one port, we can just delete */
> +	dat1 &= ~ALR_DAT1_VALID; /* delete entry */
> +	_lan9303_alr_make_entry_raw(chip, dat0, dat1);
> +}
> +
> +struct port_fdb_dump_ctx {
> +	int port;
> +	struct switchdev_obj_port_fdb *fdb;
> +	switchdev_obj_dump_cb_t       *cb;
> +};
> +
> +static void alr_loop_cb_fdb_port_dump(
> +	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx)
> +{
> +	struct port_fdb_dump_ctx *dump_ctx = ctx;
> +	struct switchdev_obj_port_fdb *fdb = dump_ctx->fdb;
> +	u8 mac[ETH_ALEN];
> +
> +	if ((BIT(dump_ctx->port) & portmap) == 0)
> +		return;
> +
> +	_alr_reg_to_mac(dat0, dat1, mac);
> +	ether_addr_copy(fdb->addr, mac);
> +	fdb->vid = 0;
> +	fdb->ndm_state = (dat1 & ALR_DAT1_STATIC) ?
> +		NUD_NOARP : NUD_REACHABLE;
> +	dump_ctx->cb(&fdb->obj);
> +}
> +
> +/* ALR: Add/modify/delete ALR entries */
> +
> +/* Set a static ALR entry. Delete entry if port_map is zero */
> +static void _lan9303_alr_set_entry(struct lan9303 *chip, const u8 *mac,
> +				   u8 port_map, bool stp_override)
> +{
> +	u32 dat0, dat1, alr_port;
> +
> +	dat1 = ALR_DAT1_STATIC;
> +	if (port_map)
> +		dat1 |= ALR_DAT1_VALID; /* otherwise no ports: delete entry */
> +	if (stp_override)
> +		dat1 |= ALR_DAT1_AGE_OVERRID;
> +
> +	alr_port = portmap_2_alrport[port_map & 7];
> +	dat1 &= ~ALR_DAT1_PORT_MASK;
> +	dat1 |= alr_port << ALR_DAT1_PORT_BITOFFS;
> +
> +	dat0 = 0;
> +	dat0 |= (mac[0] << 0);
> +	dat0 |= (mac[1] << 8);
> +	dat0 |= (mac[2] << 16);
> +	dat0 |= (mac[3] << 24);
> +
> +	dat1 |= (mac[4] << 0);
> +	dat1 |= (mac[5] << 8);
> +
> +	dev_dbg(chip->dev, "%s %pM %d %08x %08x\n",
> +		__func__, mac, port_map, dat0, dat1);
> +	_lan9303_alr_make_entry_raw(chip, dat0, dat1);
> +}
> +
> +/* Add port to static ALR entry, create new static entry if needed */
> +static int lan9303_alr_add_port(struct lan9303 *chip, const u8 *mac,
> +				int port, bool stp_override)
> +{
> +	struct lan9303_alr_cache_entry *entr = lan9303_alr_cache_find_mac(
> +		chip, mac);

A long line like this should be split into a declaration and an
assignment.

> +
> +	if (!entr) { /*New entry */
> +		entr = lan9303_alr_cache_find_free(chip);
> +		if (!entr)
> +			return -ENOSPC;
> +		ether_addr_copy(entr->mac_addr, mac);
> +	}
> +	entr->port_map |= BIT(port);
> +	entr->stp_override = stp_override;
> +	_lan9303_alr_set_entry(chip, mac, entr->port_map, stp_override);
> +	return 0;
> +}
> +
> +/* Delete static port from ALR entry, delete entry if last port */
> +static int lan9303_alr_del_port(struct lan9303 *chip, const u8 *mac,
> +				int port)
> +{
> +	struct lan9303_alr_cache_entry *entr = lan9303_alr_cache_find_mac(
> +		chip, mac);
> +
> +	if (!entr) { /* no static entry found */
> +		/* Should we delete any learned entry?
> +		 * _lan9303_alr_set_entry(chip, mac, 0, false);
> +		 */
> +		return 0;
> +	}
> +	entr->port_map &= ~BIT(port); /* zero means its free again */
> +	if (entr->port_map == 0)
> +		eth_zero_addr(&entr->port_map);
> +	_lan9303_alr_set_entry(chip, mac, entr->port_map, entr->stp_override);
> +	return 0;
> +}
> +
> +/* --------------------- Various chip setup ----------------------*/
>  static int lan9303_disable_packet_processing(struct lan9303 *chip,
>  					     unsigned int port)
>  {
> @@ -729,6 +968,14 @@ static int lan9303_setup(struct dsa_switch *ds)
>  	return 0;
>  }
>  
> +static int lan9303_set_addr(struct dsa_switch *ds, u8 *addr)
> +{
> +	struct lan9303 *chip = ds->priv;
> +
> +	lan9303_alr_add_port(chip, addr, 0, false);
> +	return 0;
> +}
> +

I would probably make this a separate patch.

  Andrew
