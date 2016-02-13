From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: mv88e6xxx: check hardware VLAN in
 use
Date: Sat, 13 Feb 2016 23:08:49 +0300
Message-ID: <56BF8D51.5010108@cogentembedded.com>
References: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1455296981-27998-4-git-send-email-vivien.didelot@savoirfairelinux.com>
 <56BF731F.8000008@cogentembedded.com> <87mvr44cbh.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33529 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbcBMUIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 15:08:54 -0500
Received: by mail-lb0-f174.google.com with SMTP id x4so61370280lbm.0
        for <netdev@vger.kernel.org>; Sat, 13 Feb 2016 12:08:53 -0800 (PST)
In-Reply-To: <87mvr44cbh.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2016 10:53 PM, Vivien Didelot wrote:

>>> The DSA drivers now have access to the VLAN prepare phase and the bridge
>>> net_device. It is easier to check for overlapping bridges from within
>>> the driver. Thus add such check in mv88e6xxx_port_vlan_prepare.
>>>
>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>> ---
>>>    drivers/net/dsa/mv88e6xxx.c | 64 +++++++++++++++++++++++++++++++++++++++++++++
>>>    1 file changed, 64 insertions(+)
>>>
>>> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
>>> index 2e515e8..685dcb0 100644
>>> --- a/drivers/net/dsa/mv88e6xxx.c
>>> +++ b/drivers/net/dsa/mv88e6xxx.c
>>> @@ -1471,14 +1471,78 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
>>>    	return 0;
>>>    }
>>>
>>> +static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
>>> +					u16 vid_begin, u16 vid_end)
>>> +{
>>> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>>> +	struct mv88e6xxx_vtu_stu_entry vlan;
>>> +	int i, err;
>>> +
>>> +	if (!vid_begin)
>>> +		return -EOPNOTSUPP;
>>> +
>>> +	mutex_lock(&ps->smi_mutex);
>>> +
>>> +	err = _mv88e6xxx_vtu_vid_write(ds, vid_begin - 1);
>>> +	if (err)
>>> +		goto unlock;
>>> +
>>> +	do {
>>> +		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
>>> +		if (err)
>>> +			goto unlock;
>>
>>      Why are you not using *break*?
>
> I use goto for explicit error handling, and break for expected flow.

    Thought you'd say so. :-)
    I still think *break* is preferable...

>>> +
>>> +		if (!vlan.valid)
>>> +			break;
>>> +
>>> +		if (vlan.vid > vid_end)
>>> +			break;
>>> +
>>> +		for (i = 0; i < ps->num_ports; ++i) {
>>> +			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
>>> +				continue;
>>> +
>>> +			if (vlan.data[i] ==
>>> +			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
>>> +				continue;
>>> +
>>> +			if (ps->ports[i].bridge_dev ==
>>> +			    ps->ports[port].bridge_dev)
>>> +				break; /* same bridge, check next VLAN */
>>> +
>>> +			netdev_warn(ds->ports[port],
>>> +				    "hardware VLAN %d already used by %s\n",
>>> +				    vlan.vid,
>>> +				    netdev_name(ps->ports[i].bridge_dev));
>>> +			err = -EOPNOTSUPP;
>>> +			goto unlock;
>>> +		}
>>
>>      Why not *break*?
>
> Because here it would only break the for loop, and not the while loop.

    Oops, I overlooked the *for* loop. Sorry about that.

>>
>>> +	} while (vlan.vid < vid_end);
>>> +
>>> +unlock:
>>> +	mutex_unlock(&ps->smi_mutex);
>>> +
>>> +	return err;
>>> +}
>>> +
>> [...]
>
> Thanks,
> -v

MBR, Sergei
