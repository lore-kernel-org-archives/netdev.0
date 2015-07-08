From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Add support for Marvell
 88E6320 and 88E6321
Date: Wed, 8 Jul 2015 16:52:34 +0200
Message-ID: <20150708145234.GB32208@lunn.ch>
References: <1436326695-18666-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"Aleksey S. Kazantsev" <ioctl@yandex.ru>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436326695-18666-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 07, 2015 at 08:38:15PM -0700, Guenter Roeck wrote:
> From: "Aleksey S. Kazantsev" <ioctl@yandex.ru>
> 
> MV88E6320 and MV88E6321 are largely compatible to MV886352,
> but are members of a different chip family.
> 
> Signed-off-by: Aleksey S. Kazantsev <ioctl@yandex.ru>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

One thing we might want to consider, is moving the temperate sensor
code into mv88e6xxx. It seems likely future devices will also have the
same sensor, so moving it to the shared code would make sense. We can
then keep all mv88e6xxx_XXXX_family() stuff in a single file.

I don't see this as a blocker for this patchset, but now might be the
right time to do this.

      Andrew


> ---
>  drivers/net/dsa/Kconfig     |  6 +++---
>  drivers/net/dsa/mv88e6352.c | 31 +++++++++++++++++++++++++------
>  drivers/net/dsa/mv88e6xxx.c | 42 ++++++++++++++++++++++++++++++------------
>  drivers/net/dsa/mv88e6xxx.h |  8 +++++++-
>  4 files changed, 65 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
> index 7ad0a4d8e475..4c483d937481 100644
> --- a/drivers/net/dsa/Kconfig
> +++ b/drivers/net/dsa/Kconfig
> @@ -46,13 +46,13 @@ config NET_DSA_MV88E6171
>  	  ethernet switches chips.
>  
>  config NET_DSA_MV88E6352
> -	tristate "Marvell 88E6172/88E6176/88E6352 ethernet switch chip support"
> +	tristate "Marvell 88E6172/6176/6320/6321/6352 ethernet switch chip support"
>  	depends on NET_DSA
>  	select NET_DSA_MV88E6XXX
>  	select NET_DSA_TAG_EDSA
>  	---help---
> -	  This enables support for the Marvell 88E6172, 88E6176 and 88E6352
> -	  ethernet switch chips.
> +	  This enables support for the Marvell 88E6172, 88E6176, 88E6320,
> +	  88E6321 and 88E6352 ethernet switch chips.
>  
>  config NET_DSA_BCM_SF2
>  	tristate "Broadcom Starfighter 2 Ethernet switch support"
> diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
> index 632815c10a40..cfece5ae9d5f 100644
> --- a/drivers/net/dsa/mv88e6352.c
> +++ b/drivers/net/dsa/mv88e6352.c
> @@ -36,6 +36,18 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
>  			return "Marvell 88E6172";
>  		if ((ret & 0xfff0) == PORT_SWITCH_ID_6176)
>  			return "Marvell 88E6176";
> +		if (ret == PORT_SWITCH_ID_6320_A1)
> +			return "Marvell 88E6320 (A1)";
> +		if (ret == PORT_SWITCH_ID_6320_A2)
> +			return "Marvell 88e6320 (A2)";
> +		if ((ret & 0xfff0) == PORT_SWITCH_ID_6320)
> +			return "Marvell 88E6320";
> +		if (ret == PORT_SWITCH_ID_6321_A1)
> +			return "Marvell 88E6321 (A1)";
> +		if (ret == PORT_SWITCH_ID_6321_A2)
> +			return "Marvell 88e6321 (A2)";
> +		if ((ret & 0xfff0) == PORT_SWITCH_ID_6321)
> +			return "Marvell 88E6321";
>  		if (ret == PORT_SWITCH_ID_6352_A0)
>  			return "Marvell 88E6352 (A0)";
>  		if (ret == PORT_SWITCH_ID_6352_A1)
> @@ -84,11 +96,12 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
>  
>  static int mv88e6352_get_temp(struct dsa_switch *ds, int *temp)
>  {
> +	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
>  	int ret;
>  
>  	*temp = 0;
>  
> -	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 27);
> +	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 27);
>  	if (ret < 0)
>  		return ret;
>  
> @@ -99,11 +112,12 @@ static int mv88e6352_get_temp(struct dsa_switch *ds, int *temp)
>  
>  static int mv88e6352_get_temp_limit(struct dsa_switch *ds, int *temp)
>  {
> +	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
>  	int ret;
>  
>  	*temp = 0;
>  
> -	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 26);
> +	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
>  	if (ret < 0)
>  		return ret;
>  
> @@ -114,23 +128,25 @@ static int mv88e6352_get_temp_limit(struct dsa_switch *ds, int *temp)
>  
>  static int mv88e6352_set_temp_limit(struct dsa_switch *ds, int temp)
>  {
> +	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
>  	int ret;
>  
> -	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 26);
> +	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
>  	if (ret < 0)
>  		return ret;
>  	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
> -	return mv88e6xxx_phy_page_write(ds, 0, 6, 26,
> +	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
>  					(ret & 0xe0ff) | (temp << 8));
>  }
>  
>  static int mv88e6352_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
>  {
> +	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
>  	int ret;
>  
>  	*alarm = false;
>  
> -	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 26);
> +	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
>  	if (ret < 0)
>  		return ret;
>  
> @@ -394,5 +410,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
>  	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
>  };
>  
> -MODULE_ALIAS("platform:mv88e6352");
>  MODULE_ALIAS("platform:mv88e6172");
> +MODULE_ALIAS("platform:mv88e6176");
> +MODULE_ALIAS("platform:mv88e6320");
> +MODULE_ALIAS("platform:mv88e6321");
> +MODULE_ALIAS("platform:mv88e6352");
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index fd8547c2b79d..f394e4d4d9e0 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -517,6 +517,18 @@ static bool mv88e6xxx_6185_family(struct dsa_switch *ds)
>  	return false;
>  }
>  
> +bool mv88e6xxx_6320_family(struct dsa_switch *ds)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +
> +	switch (ps->id) {
> +	case PORT_SWITCH_ID_6320:
> +	case PORT_SWITCH_ID_6321:
> +		return true;
> +	}
> +	return false;
> +}
> +
>  static bool mv88e6xxx_6351_family(struct dsa_switch *ds)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> @@ -565,7 +577,7 @@ static int _mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
>  {
>  	int ret;
>  
> -	if (mv88e6xxx_6352_family(ds))
> +	if (mv88e6xxx_6320_family(ds) || mv88e6xxx_6352_family(ds))
>  		port = (port + 1) << 5;
>  
>  	/* Snapshot the hardware statistics counters for this port. */
> @@ -1377,7 +1389,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
>  	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
> -	    mv88e6xxx_6065_family(ds)) {
> +	    mv88e6xxx_6065_family(ds) || mv88e6xxx_6320_family(ds)) {
>  		/* MAC Forcing register: don't force link, speed,
>  		 * duplex or flow control state to any particular
>  		 * values on physical ports, but force the CPU port
> @@ -1423,7 +1435,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
>  	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
> -	    mv88e6xxx_6185_family(ds))
> +	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6320_family(ds))
>  		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
>  		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
>  		PORT_CONTROL_STATE_FORWARDING;
> @@ -1431,7 +1443,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
>  			reg |= PORT_CONTROL_DSA_TAG;
>  		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
> -		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds)) {
> +		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> +		    mv88e6xxx_6320_family(ds)) {
>  			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
>  				reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
>  			else
> @@ -1441,14 +1454,15 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
>  		    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
> -		    mv88e6xxx_6185_family(ds)) {
> +		    mv88e6xxx_6185_family(ds) || mv88e6xxx_6320_family(ds)) {
>  			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
>  				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
>  		}
>  	}
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> -	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds)) {
> +	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
> +	    mv88e6xxx_6320_family(ds)) {
>  		if (ds->dsa_port_mask & (1 << port))
>  			reg |= PORT_CONTROL_FRAME_MODE_DSA;
>  		if (port == dsa_upstream_port(ds))
> @@ -1473,11 +1487,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  	reg = 0;
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> -	    mv88e6xxx_6095_family(ds))
> +	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6320_family(ds))
>  		reg = PORT_CONTROL_2_MAP_DA;
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
> -	    mv88e6xxx_6165_family(ds))
> +	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6320_family(ds))
>  		reg |= PORT_CONTROL_2_JUMBO_10240;
>  
>  	if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds)) {
> @@ -1514,7 +1528,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  		goto abort;
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
> -	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds)) {
> +	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> +	    mv88e6xxx_6320_family(ds)) {
>  		/* Do not limit the period of time that this port can
>  		 * be paused for by the remote end or the period of
>  		 * time that this port can pause the remote end.
> @@ -1564,7 +1579,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> -	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds)) {
> +	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
> +	    mv88e6xxx_6320_family(ds)) {
>  		/* Rate Control: disable ingress rate limiting. */
>  		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
>  					   PORT_RATE_CONTROL, 0x0001);
> @@ -1976,7 +1992,8 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
>  			  (i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
> -	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds)) {
> +	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> +	    mv88e6xxx_6320_family(ds)) {
>  		/* Send all frames with destination addresses matching
>  		 * 01:80:c2:00:00:2x to the CPU port.
>  		 */
> @@ -1995,7 +2012,8 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
>  
>  	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>  	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
> -	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds)) {
> +	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
> +	    mv88e6xxx_6320_family(ds)) {
>  		/* Disable ingress rate limiting by resetting all
>  		 * ingress rate limit registers to their initial
>  		 * state.
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index a650b2656de9..64786cb89a93 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -89,7 +89,12 @@
>  #define PORT_SWITCH_ID_6182	0x1a60
>  #define PORT_SWITCH_ID_6185	0x1a70
>  #define PORT_SWITCH_ID_6240	0x2400
> -#define PORT_SWITCH_ID_6320	0x1250
> +#define PORT_SWITCH_ID_6320	0x1150
> +#define PORT_SWITCH_ID_6320_A1	0x1151
> +#define PORT_SWITCH_ID_6320_A2	0x1152
> +#define PORT_SWITCH_ID_6321	0x3100
> +#define PORT_SWITCH_ID_6321_A1	0x3101
> +#define PORT_SWITCH_ID_6321_A2	0x3102
>  #define PORT_SWITCH_ID_6350	0x3710
>  #define PORT_SWITCH_ID_6351	0x3750
>  #define PORT_SWITCH_ID_6352	0x3520
> @@ -410,6 +415,7 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
>  int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
>  int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
>  			     int reg, int val);
> +bool mv88e6xxx_6320_family(struct dsa_switch *ds);
>  extern struct dsa_switch_driver mv88e6131_switch_driver;
>  extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
>  extern struct dsa_switch_driver mv88e6352_switch_driver;
> -- 
> 2.1.0
> 
