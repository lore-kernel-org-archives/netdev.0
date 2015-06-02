From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Mon, 01 Jun 2015 23:50:22 -0700
Message-ID: <556D522E.90607@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vivien,

On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> This commit implements the port_vlan_add and port_vlan_del functions in
> the dsa_switch_driver structure for Marvell 88E6xxx compatible switches.
>
> This allows to access a switch VLAN Table Unit, and thus define VLANs
> from standard userspace commands such as "bridge vlan".
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---

[ ... ]

> +
> +int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
> +			    u16 bridge_flags)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	struct mv88e6xxx_vtu_entry entry = { 0 };
> +	int prev_vid = vid ? vid - 1 : 4095;
> +	int i, ret;
> +
> +	/* Bringing an interface up adds it to the VLAN 0. Ignore this. */
> +	if (!vid)
> +		return 0;
> +

Me puzzled ;-). I brought this and the fid question up before.
No idea if my e-mail got lost or what happened.

Can you explain why we don't need a configuration for vlan 0 ?

> +	/* The DSA port-based VLAN setup reserves FID 0 to DSA_MAX_PORTS;
> +	 * we will use the next FIDs for 802.1q;
> +	 * thus, forbid the last DSA_MAX_PORTS VLANs.
> +	 */
> +	if (vid > 4095 - DSA_MAX_PORTS)
> +		return -EINVAL;
> +
> +	mutex_lock(&ps->smi_mutex);
> +	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
> +	if (ret < 0)
> +		goto unlock;
> +
> +	/* If the VLAN does not exist, re-initialize the entry for addition */
> +	if (entry.vid != vid || !entry.valid) {
> +		memset(&entry, 0, sizeof(entry));
> +		entry.valid = true;
> +		entry.vid = vid;
> +		entry.fid = DSA_MAX_PORTS + vid;

I brought this up before. No idea if my e-mail got lost or what happened.

We use a fid per port, and a fid per bridge group. With VLANs, this is completely
ignored, ahd there is only a single fid per vlan for the entire switch.

Either per-port fids are unnecessary as well, or something is wrong here,
or I am missing something. Can you explain why we only need a single fid
per vlan, even if we have multiple bridge groups and the same vlan is
configured in all of them ?

Thanks,
Guenter
