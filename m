From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/8] dsa: mv88e6xxx: Kill the REG_READ and REG_WRITE macros
Date: Thu, 14 Apr 2016 10:54:49 -0400
Message-ID: <877fg05jgm.fsf@ketchup.mtl.sfl>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch> <1460591998-20598-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34848 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbcDNOyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 10:54:54 -0400
In-Reply-To: <1460591998-20598-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

<snip>

>  int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
>  {
> +	int ret, err;
>  	int i;
> -	int ret;
>  
>  	for (i = 0; i < 6; i++) {
>  		int j;
>  
>  		/* Write the MAC address byte. */
> -		REG_WRITE(REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
> -			  GLOBAL2_SWITCH_MAC_BUSY | (i << 8) | addr[i]);
> +		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
> +					  GLOBAL2_SWITCH_MAC_BUSY |
> +					  (i << 8) | addr[i]);
> +		if (err)
> +			return err;

Just use the ret variable here.

>  
>  		/* Wait for the write to complete. */
>  		for (j = 0; j < 16; j++) {
> -			ret = REG_READ(REG_GLOBAL2, GLOBAL2_SWITCH_MAC);
> +			ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2,
> +						 GLOBAL2_SWITCH_MAC);
> +			if (ret < 0)
> +				return ret;
> +
> +			if (ret < 0)
> +				return ret;

duplicated condition.

>  			if ((ret & GLOBAL2_SWITCH_MAC_BUSY) == 0)
>  				break;
>  		}

<snip>

> @@ -2697,7 +2732,8 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
>  	ps->ds = ds;
>  	mutex_init(&ps->smi_mutex);
>  
> -	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
> +	ps->id = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, REG_PORT(0),
> +				      PORT_SWITCH_ID) & 0xfff0;

Here you dropped the error checking, and the (maybe unnecessary?) mutex
locking.

>  
>  	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
>  
> @@ -2708,42 +2744,66 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_setup_common);
>  int mv88e6xxx_setup_global(struct dsa_switch *ds)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> -	int ret;
> +	int err;
>  	int i;
>  
>  	/* Set the default address aging time to 5 minutes, and
>  	 * enable address learn messages to be sent to all message
>  	 * ports.
>  	 */
> -	REG_WRITE(REG_GLOBAL, GLOBAL_ATU_CONTROL,
> -		  0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL,
> +				  0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
> +	if (err)
> +		return err;
>  
>  	/* Configure the IP ToS mapping registers. */
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
> +	if (err)
> +		return err;
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
> +	if (err)
> +		return err;
>  
>  	/* Configure the IEEE 802.1p priority mapping register. */
> -	REG_WRITE(REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
> +	if (err)
> +		return err;
>  
>  	/* Send all frames with destination addresses matching
>  	 * 01:80:c2:00:00:0x to the CPU port.
>  	 */
> -	REG_WRITE(REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
> +	if (err)
> +		return err;
>  
>  	/* Ignore removed tag data on doubly tagged packets, disable
>  	 * flow control messages, force flow control priority to the
>  	 * highest, and send all special multicast frames to the CPU
>  	 * port at the highest priority.
>  	 */
> -	REG_WRITE(REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
> -		  0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
> -		  GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
> +				  0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
> +				  GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
> +	if (err)
> +		return err;
>  
>  	/* Program the DSA routing table. */
>  	for (i = 0; i < 32; i++) {
> @@ -2753,23 +2813,35 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
>  		    i != ds->index && i < ds->dst->pd->nr_chips)
>  			nexthop = ds->pd->rtable[i] & 0x1f;
>  
> -		REG_WRITE(REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING,
> -			  GLOBAL2_DEVICE_MAPPING_UPDATE |
> -			  (i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) |
> -			  nexthop);
> +		err = mv88e6xxx_reg_write(
> +			ds, REG_GLOBAL2,
> +			GLOBAL2_DEVICE_MAPPING,
> +			GLOBAL2_DEVICE_MAPPING_UPDATE |
> +			(i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) | nexthop);
> +	if (err)
> +		return err;

Wrong indentation here.

>  	}
>  
>  	/* Clear all trunk masks. */
> -	for (i = 0; i < 8; i++)
> -		REG_WRITE(REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
> -			  0x8000 | (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
> -			  ((1 << ps->num_ports) - 1));
> +	for (i = 0; i < 8; i++) {
> +		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
> +					  0x8000 |
> +					  (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
> +					  ((1 << ps->num_ports) - 1));
> +		if (err)
> +			return err;
> +	}
>  
>  	/* Clear all trunk mappings. */
> -	for (i = 0; i < 16; i++)
> -		REG_WRITE(REG_GLOBAL2, GLOBAL2_TRUNK_MAPPING,
> -			  GLOBAL2_TRUNK_MAPPING_UPDATE |
> -			  (i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
> +	for (i = 0; i < 16; i++) {
> +		err = mv88e6xxx_reg_write(
> +			ds, REG_GLOBAL2,
> +			GLOBAL2_TRUNK_MAPPING,
> +			GLOBAL2_TRUNK_MAPPING_UPDATE |
> +			(i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
> +		if (err)
> +			return err;
> +	}
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> @@ -2777,17 +2849,27 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
>  		/* Send all frames with destination addresses matching
>  		 * 01:80:c2:00:00:2x to the CPU port.
>  		 */
> -		REG_WRITE(REG_GLOBAL2, GLOBAL2_MGMT_EN_2X, 0xffff);
> +		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
> +					  GLOBAL2_MGMT_EN_2X, 0xffff);
> +		if (err)
> +			return err;
>  
>  		/* Initialise cross-chip port VLAN table to reset
>  		 * defaults.
>  		 */
> -		REG_WRITE(REG_GLOBAL2, GLOBAL2_PVT_ADDR, 0x9000);
> +		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
> +					  GLOBAL2_PVT_ADDR, 0x9000);
> +		if (err)
> +			return err;
>  
>  		/* Clear the priority override table. */
> -		for (i = 0; i < 16; i++)
> -			REG_WRITE(REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
> -				  0x8000 | (i << 8));
> +		for (i = 0; i < 16; i++) {
> +			err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
> +						  GLOBAL2_PRIO_OVERRIDE,
> +						  0x8000 | (i << 8));
> +			if (err)
> +				return err;
> +		}
>  	}
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
> @@ -2798,31 +2880,38 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
>  		 * ingress rate limit registers to their initial
>  		 * state.
>  		 */
> -		for (i = 0; i < ps->num_ports; i++)
> -			REG_WRITE(REG_GLOBAL2, GLOBAL2_INGRESS_OP,
> -				  0x9000 | (i << 8));
> +		for (i = 0; i < ps->num_ports; i++) {
> +			err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
> +						  GLOBAL2_INGRESS_OP,
> +						  0x9000 | (i << 8));
> +			if (err)
> +				return err;
> +		}
>  	}
>  
>  	/* Clear the statistics counters for all ports */
> -	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP, GLOBAL_STATS_OP_FLUSH_ALL);
> +	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
> +				  GLOBAL_STATS_OP_FLUSH_ALL);
> +	if (err)
> +		return err;
>  
>  	/* Wait for the flush to complete. */
>  	mutex_lock(&ps->smi_mutex);

This function is ugly. As you are rewriting all read/write access in it,
Please put that mutex_lock at its beginning and use the _mv88e6xxx_reg_*
variant with goto unlock statement instead, so we lock/unlock just once.

> -	ret = _mv88e6xxx_stats_wait(ds);
> -	if (ret < 0)
> +	err = _mv88e6xxx_stats_wait(ds);
> +	if (err < 0)
>  		goto unlock;
>  
>  	/* Clear all ATU entries */
> -	ret = _mv88e6xxx_atu_flush(ds, 0, true);
> -	if (ret < 0)
> +	err = _mv88e6xxx_atu_flush(ds, 0, true);
> +	if (err < 0)
>  		goto unlock;
>  
>  	/* Clear all the VTU and STU entries */
> -	ret = _mv88e6xxx_vtu_stu_flush(ds);
> +	err = _mv88e6xxx_vtu_stu_flush(ds);
>  unlock:
>  	mutex_unlock(&ps->smi_mutex);
>  
> -	return ret;
> +	return err;
>  }
>  EXPORT_SYMBOL_GPL(mv88e6xxx_setup_global);
>  
> @@ -2832,13 +2921,19 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>  	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
>  	struct gpio_desc *gpiod = ps->reset;
>  	unsigned long timeout;
> -	int ret;
> +	int ret, err;
>  	int i;
>  
>  	/* Set all ports to the disabled state. */
>  	for (i = 0; i < ps->num_ports; i++) {
> -		ret = REG_READ(REG_PORT(i), PORT_CONTROL);
> -		REG_WRITE(REG_PORT(i), PORT_CONTROL, ret & 0xfffc);
> +		ret = mv88e6xxx_reg_read(ds, REG_PORT(i), PORT_CONTROL);
> +		if (ret < 0)
> +			return ret;
> +
> +		err = mv88e6xxx_reg_write(ds, REG_PORT(i), PORT_CONTROL,
> +					  ret & 0xfffc);
> +		if (err)
> +			return err;
>  	}
>  
>  	/* Wait for transmit queues to drain. */
> @@ -2857,14 +2952,19 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>  	 * through global registers 0x18 and 0x19.
>  	 */
>  	if (ppu_active)
> -		REG_WRITE(REG_GLOBAL, 0x04, 0xc000);
> +		err = mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x04, 0xc000);
>  	else
> -		REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
> +		err = mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x04, 0xc400);
> +	if (err)
> +		return err;

The ret variable is already there, I'd stick with it instead of adding a
new err variable to the function.

>  
>  	/* Wait up to one second for reset to complete. */
>  	timeout = jiffies + 1 * HZ;
>  	while (time_before(jiffies, timeout)) {
> -		ret = REG_READ(REG_GLOBAL, 0x00);
> +		ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x00);
> +		if (ret < 0)
> +			return ret;
> +
>  		if ((ret & is_reset) == is_reset)
>  			break;
>  		usleep_range(1000, 2000);

This comment is up to you, but as you're adding error conditions to the
function, I'd go with a single mutex_lock/mutex_unlock, use the
_mv88e6xxx_reg_* variants and goto unlock statements here as well.

> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index 739d3ff1bddf..6d1b6207144d 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -554,25 +554,6 @@ extern struct dsa_switch_driver mv88e6123_switch_driver;
>  extern struct dsa_switch_driver mv88e6352_switch_driver;
>  extern struct dsa_switch_driver mv88e6171_switch_driver;
>  
> -#define REG_READ(addr, reg)						\
> -	({								\
> -		int __ret;						\
> -									\
> -		__ret = mv88e6xxx_reg_read(ds, addr, reg);		\
> -		if (__ret < 0)						\
> -			return __ret;					\
> -		__ret;							\
> -	})
> -
> -#define REG_WRITE(addr, reg, val)					\
> -	({								\
> -		int __ret;						\
> -									\
> -		__ret = mv88e6xxx_reg_write(ds, addr, reg, val);	\
> -		if (__ret < 0)						\
> -			return __ret;					\
> -	})
> -
>  /**
>   * mv88e6xxx_module_driver() - Helper macro for registering mv88e6xxx drivers
>   *

I'm 200% for this patch. However it is not related to the rest of the
patchset, which I'm not really OK with yet (still reviewing). As this
needs a respin anyway, can you extract and send it as a single patch? It
applies cleanly to net-next once you remove the mv88e6xxx_module_driver
macro. I'll ack it right away.

Thanks,
Vivien
