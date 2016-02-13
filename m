From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: mv88e6xxx: check hardware VLAN in
 use
Date: Sat, 13 Feb 2016 21:17:03 +0300
Message-ID: <56BF731F.8000008@cogentembedded.com>
References: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1455296981-27998-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455296981-27998-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/12/2016 8:09 PM, Vivien Didelot wrote:

> The DSA drivers now have access to the VLAN prepare phase and the bridge
> net_device. It is easier to check for overlapping bridges from within
> the driver. Thus add such check in mv88e6xxx_port_vlan_prepare.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 64 +++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 64 insertions(+)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 2e515e8..685dcb0 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1471,14 +1471,78 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
>   	return 0;
>   }
>
> +static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
> +					u16 vid_begin, u16 vid_end)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	struct mv88e6xxx_vtu_stu_entry vlan;
> +	int i, err;
> +
> +	if (!vid_begin)
> +		return -EOPNOTSUPP;
> +
> +	mutex_lock(&ps->smi_mutex);
> +
> +	err = _mv88e6xxx_vtu_vid_write(ds, vid_begin - 1);
> +	if (err)
> +		goto unlock;
> +
> +	do {
> +		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
> +		if (err)
> +			goto unlock;

    Why are you not using *break*?

> +
> +		if (!vlan.valid)
> +			break;
> +
> +		if (vlan.vid > vid_end)
> +			break;
> +
> +		for (i = 0; i < ps->num_ports; ++i) {
> +			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
> +				continue;
> +
> +			if (vlan.data[i] ==
> +			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
> +				continue;
> +
> +			if (ps->ports[i].bridge_dev ==
> +			    ps->ports[port].bridge_dev)
> +				break; /* same bridge, check next VLAN */
> +
> +			netdev_warn(ds->ports[port],
> +				    "hardware VLAN %d already used by %s\n",
> +				    vlan.vid,
> +				    netdev_name(ps->ports[i].bridge_dev));
> +			err = -EOPNOTSUPP;
> +			goto unlock;
> +		}

    Why not *break*?

> +	} while (vlan.vid < vid_end);
> +
> +unlock:
> +	mutex_unlock(&ps->smi_mutex);
> +
> +	return err;
> +}
> +
[...]

MBR, Sergei
