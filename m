From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/3] net: dsa: mv88e6xxx: add support to dump VLANs
Date: Fri, 26 Jun 2015 16:10:25 +0200
Message-ID: <20150626141025.GC9469@lunn.ch>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1435095970-18576-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435095970-18576-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 23, 2015 at 05:46:09PM -0400, Vivien Didelot wrote:
> This commit implements the port_vlan_dump function in the
> dsa_switch_driver structure for Marvell 88E6xxx compatible switches.
> 
> This allows to access a switch VLAN Table Unit from standard userspace
> commands such as "bridge vlan show".
> 
> A populated VTU can give the following output:
> 
>     # bridge vlan
>     port	vlan ids
>     swp0	None
>     swp0
>     swp1	None
>     swp1
>     swp2	1000
> 		1200
> 
>     swp2	1000
> 		1200
> 
>     swp3	550 PVID Egress Untagged
> 
>     swp3	550 PVID Egress Untagged
> 
>     swp4	1200
> 
>     swp4	1200
> 
>     br0	None
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  2 ++
>  2 files changed, 46 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 0dce8e8..0d63bf6 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1441,6 +1441,50 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
>  	return 0;
>  }
>  
> +int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port, u16 vid,
> +			     u16 *bridge_flags)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	struct mv88e6xxx_vtu_entry entry = { 0 };
> +	int prev_vid = vid ? vid - 1 : 4095;
> +	int ret;
> +
> +	mutex_lock(&ps->smi_mutex);
> +	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
> +	if (ret < 0)
> +		goto unlock;
> +
> +	if (entry.vid != vid || !entry.valid) {
> +		ret = -ENOENT;
> +		goto unlock;
> +	}
> +
> +	switch (entry.tags[port]) {
> +	case GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED:
> +		*bridge_flags |= BRIDGE_VLAN_INFO_UNTAGGED;
> +		/* fall through... */
> +	case GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED:
> +		break;

A nit pick, but fall through catches people out. Having a fall through
to a break statements seems like a trap for future coders to fall
into. I would replace the comment with a break, and let the compiler
do the optimisation.

   Andrew
