From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 8/9] net: dsa: mv88e6xxx: add rx/tx
 timestamping support
Date: Sun, 8 Oct 2017 10:24:56 -0400
Message-ID: <20171008142456.jukb47somn6y7sq3@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-9-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-9-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:40AM -0500, Brandon Streiff wrote:

> +static bool mv88e6xxx_should_tstamp(struct mv88e6xxx_chip *chip, int port,
> +				    struct sk_buff *skb, unsigned int type)
> +{
> +	struct mv88e6xxx_port_hwtstamp *ps = &chip->port_hwtstamp[port];
> +	u8 *ptp_hdr, *msgtype;
> +	bool ret;
> +
> +	if (port < 0 || port >= mv88e6xxx_num_ports(chip))
> +		return false;
> +
> +	ptp_hdr = _get_ptp_header(skb, type);
> +	if (IS_ERR(ptp_hdr))
> +		return false;
> +
> +	if (unlikely(type & PTP_CLASS_V1))
> +		msgtype = ptp_hdr + OFF_PTP_CONTROL;
> +	else
> +		msgtype = ptp_hdr;
> +
> +	ret = test_bit(MV88E6XXX_HWTSTAMP_ENABLED, &ps->state);

This should be the first test, don't you think?

> +	dev_dbg(chip->dev,
> +		"p%d: PTP message classification 0x%x type 0x%x, tstamp? %d",
> +		port, type, *msgtype, (int)ret);
> +
> +	return ret;
> +}
> +
> +/* rxtstamp will be called in interrupt context so we don't to do
> + * anything like read PTP registers over SMI.
> + */
> +bool mv88e6xxx_port_rxtstamp(struct dsa_switch *ds, int port,
> +			     struct sk_buff *skb, unsigned int type)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +	struct skb_shared_hwtstamps *shhwtstamps;
> +	__be32 *ptp_rx_ts;
> +	u8 *ptp_hdr;
> +	u32 raw_ts;
> +	u64 ns;
> +
> +	if (!chip->info->ptp_support)
> +		return false;
> +
> +	if (port < 0 || port >= mv88e6xxx_num_ports(chip))
> +		return false;

This test is duplicated in mv88e6xxx_should_tstamp().

> +	if (!mv88e6xxx_should_tstamp(chip, port, skb, type))
> +		return false;
> +
> +	shhwtstamps = skb_hwtstamps(skb);
> +	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
> +
> +	/* Because we configured the arrival timestamper to put the counter
> +	 * into the 32-bit "reserved" field of the PTP header, we can retrieve
> +	 * the value from the packet directly instead of having to retrieve it
> +	 * via SMI.
> +	 */
> +	ptp_hdr = _get_ptp_header(skb, type);
> +	if (IS_ERR(ptp_hdr))
> +		return false;
> +	ptp_rx_ts = (__be32 *)(ptp_hdr + OFF_PTP_RESERVED);
> +	raw_ts = __be32_to_cpu(*ptp_rx_ts);
> +	ns = timecounter_cyc2time(&chip->tstamp_tc, raw_ts);
> +	shhwtstamps->hwtstamp = ns_to_ktime(ns);
> +
> +	dev_dbg(chip->dev, "p%d: rxtstamp %llx\n", port, ns);
> +
> +	return false;
> +}
> +
> +static void mv88e6xxx_txtstamp_work(struct work_struct *ugly)
> +{
> +	struct mv88e6xxx_port_hwtstamp *ps = container_of(
> +		ugly, struct mv88e6xxx_port_hwtstamp, tx_tstamp_work);
> +	struct mv88e6xxx_chip *chip = container_of(
> +		ps, struct mv88e6xxx_chip, port_hwtstamp[ps->port_id]);
> +	struct sk_buff *tmp_skb;
> +	unsigned long tmp_tstamp_start;
> +	int err;
> +	u16 departure_block[4];
> +	u16 tmp_seq_id;
> +
> +	if (!test_bit(MV88E6XXX_HWTSTAMP_TX_IN_PROGRESS, &ps->state))
> +		return;
> +
> +	tmp_skb = ps->tx_skb;
> +	tmp_seq_id = ps->tx_seq_id;
> +	tmp_tstamp_start = ps->tx_tstamp_start;
> +
> +	if (!tmp_skb)
> +		return;
> +
> +	mutex_lock(&chip->reg_lock);
> +	err = mv88e6xxx_port_ptp_read(chip, ps->port_id,
> +				      MV88E6XXX_PORT_PTP_DEP_STS,
> +				      departure_block,
> +				      ARRAY_SIZE(departure_block));
> +	mutex_unlock(&chip->reg_lock);
> +
> +	if (err)
> +		goto free_and_clear_skb;
> +
> +	if (departure_block[0] & MV88E6XXX_PTP_TS_VALID) {

You can avoid the IfOk anti-pattern here.  Make the test for !VALID
and move the 'else' block up.

> +		struct skb_shared_hwtstamps shhwtstamps;
> +		u64 ns;
> +		u32 time_raw;
> +		u16 status;
> +
> +		/* We have the timestamp; go ahead and clear valid now */
> +		mutex_lock(&chip->reg_lock);
> +		mv88e6xxx_port_ptp_write(chip, ps->port_id,
> +					 MV88E6XXX_PORT_PTP_DEP_STS, 0);
> +		mutex_unlock(&chip->reg_lock);
> +
> +		status = departure_block[0] &
> +				MV88E6XXX_PTP_TS_STATUS_MASK;
> +		if (status != MV88E6XXX_PTP_TS_STATUS_NORMAL) {
> +			dev_warn(chip->dev, "p%d: tx timestamp overrun\n",
> +				 ps->port_id);
> +			goto free_and_clear_skb;
> +		}
> +
> +		if (departure_block[3] != tmp_seq_id) {
> +			dev_warn(chip->dev, "p%d: unexpected sequence id\n",
> +				 ps->port_id);
> +			goto free_and_clear_skb;
> +		}
> +
> +		memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> +		time_raw = ((u32)departure_block[2] << 16) |
> +			   departure_block[1];
> +		ns = timecounter_cyc2time(&chip->tstamp_tc, time_raw);
> +		shhwtstamps.hwtstamp = ns_to_ktime(ns);
> +
> +		dev_dbg(chip->dev,
> +			"p%d: txtstamp %llx status 0x%04x skb ID 0x%04x hw ID 0x%04x\n",
> +			ps->port_id, ktime_to_ns(shhwtstamps.hwtstamp),
> +			departure_block[0], tmp_seq_id, departure_block[3]);
> +
> +		/* skb_complete_tx_timestamp() will free up the client to make
> +		 * another timestamp-able transmit. We have to be ready for it
> +		 * -- by clearing the ps->tx_skb "flag" -- beforehand.
> +		 */
> +
> +		ps->tx_skb = NULL;
> +		clear_bit_unlock(MV88E6XXX_HWTSTAMP_TX_IN_PROGRESS, &ps->state);
> +
> +		skb_complete_tx_timestamp(tmp_skb, &shhwtstamps);
> +
> +	} else {
> +		if (time_is_before_jiffies(
> +			    tmp_tstamp_start + TX_TSTAMP_TIMEOUT)) {
> +			dev_warn(chip->dev, "p%d: clearing tx timestamp hang\n",
> +				 ps->port_id);
> +			goto free_and_clear_skb;
> +		}
> +
> +		/* The timestamp should be available quickly, while getting it
> +		 * is high priority and time bounded to only 10ms. A poll is
> +		 * warranted and this is the nicest way to realize it in a work
> +		 * item.
> +		 */
> +		queue_work(system_highpri_wq, &ps->tx_tstamp_work);
> +	}
> +
> +	return;
> +
> +free_and_clear_skb:
> +	ps->tx_skb = NULL;
> +	clear_bit_unlock(MV88E6XXX_HWTSTAMP_TX_IN_PROGRESS, &ps->state);
> +
> +	dev_kfree_skb_any(tmp_skb);
> +}
> +
> +void mv88e6xxx_port_txtstamp(struct dsa_switch *ds, int port,
> +			     struct sk_buff *clone, unsigned int type)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +	struct mv88e6xxx_port_hwtstamp *ps = &chip->port_hwtstamp[port];
> +
> +	if (!chip->info->ptp_support)
> +		return;
> +
> +	if (port < 0 || port >= mv88e6xxx_num_ports(chip))
> +		goto out;

This test is duplicated in mv88e6xxx_should_tstamp().

> +	if (unlikely(skb_shinfo(clone)->tx_flags & SKBTX_HW_TSTAMP) &&
> +	    mv88e6xxx_should_tstamp(chip, port, clone, type)) {

Please avoid the IfOk anti-pattern here as well.

> +		__be16 *seq_ptr = (__be16 *)(_get_ptp_header(clone, type) +
> +					     OFF_PTP_SEQUENCE_ID);
> +
> +		if (!test_and_set_bit_lock(MV88E6XXX_HWTSTAMP_TX_IN_PROGRESS,
> +					   &ps->state)) {
> +			ps->tx_skb = clone;
> +			ps->tx_tstamp_start = jiffies;
> +			ps->tx_seq_id = be16_to_cpup(seq_ptr);
> +
> +			/* Fetching the timestamp is high-priority work because
> +			 * 802.1AS bounds the time for a response.
> +			 *
> +			 * No need to check result of queue_work(). ps->tx_skb
> +			 * check ensures work item is not pending (it may be
> +			 * waiting to exit)
> +			 */
> +			queue_work(system_highpri_wq, &ps->tx_tstamp_work);
> +			return;
> +		}
> +
> +		/* Otherwise we're already in progress... */
> +		dev_dbg(chip->dev,
> +			"p%d: tx timestamp already in progress, discarding",
> +			port);
> +	}
> +
> +out:
> +	/* We don't need it after all. */
> +	kfree_skb(clone);

How about moving this logic should into the caller, letting the tx
callback return a code that tells whether the clone was accepted or
not?

> +}

Thanks,
Richard
