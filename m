From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 1/3] net: dsa: mv88e6xxx: add debugfs interface for VTU
Date: Tue, 7 Jul 2015 04:08:18 +0200
Message-ID: <20150707020818.GB5540@lunn.ch>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1436148893-14379-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436148893-14379-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
> +				  struct mv88e6xxx_vtu_entry *entry)
> +{
> +	int ret, i;
> +
> +	ret = _mv88e6xxx_vtu_wait(ds);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
> +				   vid & GLOBAL_VTU_VID_MASK);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_GET_NEXT);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
> +	if (ret < 0)
> +		return ret;
> +
> +	entry->vid = ret & GLOBAL_VTU_VID_MASK;
> +	entry->valid = !!(ret & GLOBAL_VTU_VID_VALID);
> +
> +	if (entry->valid) {
> +		/* Ports 0-3, offsets 0, 4, 8, 12 */
> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3);
> +		if (ret < 0)
> +			return ret;
> +
> +		for (i = 0; i < 4; ++i)
> +			entry->tags[i] = (ret >> (i * 4)) & 3;
> +
> +		/* Ports 4-6, offsets 0, 4, 8 */
> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7);
> +		if (ret < 0)
> +			return ret;
> +
> +		for (i = 4; i < 7; ++i)
> +			entry->tags[i] = (ret >> ((i - 4) * 4)) & 3;

Hi Vivien

It looks like you still have up to 7 ports, rather than use
ps->num_ports. I have a ten port switch i would like to use VLANs with
:-)

> +
> +		if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
> +		    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
> +			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
> +						  GLOBAL_VTU_FID);
> +			if (ret < 0)
> +				return ret;
> +
> +			entry->fid = ret & GLOBAL_VTU_FID_MASK;
> +
> +			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
> +						  GLOBAL_VTU_SID);
> +			if (ret < 0)
> +				return ret;
> +
> +			entry->sid = ret & GLOBAL_VTU_SID_MASK;
> +		} else {
> +			entry->fid = 0;
> +			entry->sid = 0;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
> +				    struct mv88e6xxx_vtu_entry *entry)
> +{
> +	u16 data = 0;
> +	int ret, i;
> +
> +	ret = _mv88e6xxx_vtu_wait(ds);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (entry->valid) {
> +		/* Set Data Register, ports 0-3, offsets 0, 4, 8, 12 */
> +		for (data = i = 0; i < 4; ++i)
> +			data |= entry->tags[i] << (i * 4);
> +		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3,
> +					   data);
> +		if (ret < 0)
> +			return ret;
> +
> +		/* Set Data Register, ports 4-6, offsets 0, 4, 8 */
> +		for (data = 0, i = 4; i < 7; ++i)
> +			data |= entry->tags[i] << ((i - 4) * 4);
> +		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7,
> +					   data);

Same again here.

     Andrew
