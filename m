From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/3] net: dsa: mv88e6xxx: add debugfs interface for VTU
Date: Fri, 26 Jun 2015 16:04:34 +0200
Message-ID: <20150626140434.GB9469@lunn.ch>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1435095970-18576-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58335 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbbFZOKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 10:10:38 -0400
Content-Disposition: inline
In-Reply-To: <1435095970-18576-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 05:46:08PM -0400, Vivien Didelot wrote:
> Implement the Get Next operation for the VLAN Table Unit, and a "vtu"
> debugfs file to dump the hardware VLANs.
> 
> A populated VTU can look like this:
> 
>     # cat /sys/kernel/debug/dsa0/vtu
>     VID  FID  SID  P0 P1 P2 P3 P4 P5 P6
>     550  562  0    x  x  x  u  x  t  x
>     1000 1012 0    x  x  t  x  x  t  x
>     1200 1212 0    x  x  t  x  t  t  x


Hi Vivien

Could you make this more generic and make use of ps->num_ports? Not
all switches have 7 ports.

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 138 ++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  24 ++++++++
>  2 files changed, 162 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 8c130c0..0dce8e8 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1366,6 +1366,81 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
>  	}
>  }
>  
> +static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
> +{
> +	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_VTU_OP,
> +			       GLOBAL_VTU_OP_BUSY);
> +}
> +
> +static int _mv88e6xxx_vtu_cmd(struct dsa_switch *ds, u16 op)
> +{
> +	int ret;
> +
> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_OP, op);
> +	if (ret < 0)
> +		return ret;
> +
> +	return _mv88e6xxx_vtu_wait(ds);
> +}
> +
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
> +
> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_FID);
> +		if (ret < 0)
> +			return ret;
> +
> +		entry->fid = ret & GLOBAL_VTU_FID_MASK;
> +
> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_SID);
> +		if (ret < 0)
> +			return ret;
> +
> +		entry->sid = ret & GLOBAL_VTU_SID_MASK;

As you point out in the header file, not all switches have FID and
VID. A quick look at DSDT suggests for both FID and SID:

DEV_88E6097_FAMILY | DEV_88E6165_FAMILY | DEV_88E6351_FAMILY | DEV_88E6352_FAMILY

Please limit access to these registers to just these families.

> +	}
> +
> +	return 0;
> +}
> +
>  static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> @@ -1739,6 +1814,66 @@ static const struct file_operations mv88e6xxx_atu_fops = {
>  	.owner  = THIS_MODULE,
>  };
>  
> +static int mv88e6xxx_vtu_show(struct seq_file *s, void *p)
> +{
> +	struct dsa_switch *ds = s->private;
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	int vid = 0xfff; /* find the first or lowest VID */
> +	int ret = 0;
> +	int port;
> +
> +	seq_puts(s, "VID  FID  SID  P0 P1 P2 P3 P4 P5 P6\n");
> +	mutex_lock(&ps->smi_mutex);
> +
> +	do {
> +		struct mv88e6xxx_vtu_entry next = { 0 };
> +
> +		ret = _mv88e6xxx_vtu_getnext(ds, vid, &next);
> +		if (ret < 0)
> +			goto unlock;
> +
> +		if (!next.valid)
> +			break;
> +
> +		seq_printf(s, "%-4d %-4d %-2d ", next.vid, next.fid, next.sid);
> +		for (port = 0; port < 7; ++port) {
> +			u8 tag = next.tags[port];
> +
> +			if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED)
> +				seq_puts(s, "  -");
> +			else if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
> +				seq_puts(s, "  u");
> +			else if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED)
> +				seq_puts(s, "  t");
> +			else if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
> +				seq_puts(s, "  x");
> +			else
> +				seq_puts(s, "  ?"); /* unlikely */

Maybe use a switch statememt?

Thanks
	Andrew
