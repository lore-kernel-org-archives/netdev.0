From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3 1/3] net: dsa: mv88e6xxx: add debugfs interface for
 VTU
Date: Tue, 07 Jul 2015 09:11:30 -0700
Message-ID: <559BFA32.8010004@roeck-us.net>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1436148893-14379-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20150707020818.GB5540@lunn.ch> <1165322565.210276.1436284349938.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:58720 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310AbbGGQLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 12:11:35 -0400
In-Reply-To: <1165322565.210276.1436284349938.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2015 08:52 AM, Vivien Didelot wrote:
> Hi Andrew,
>
> On Jul 6, 2015, at 10:08 PM, Andrew Lunn andrew@lunn.ch wrote:
>
>>> +static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
>>> +				  struct mv88e6xxx_vtu_entry *entry)
>>> +{
>>> +	int ret, i;
>>> +
>>> +	ret = _mv88e6xxx_vtu_wait(ds);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +
>>> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
>>> +				   vid & GLOBAL_VTU_VID_MASK);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +
>>> +	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_GET_NEXT);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +
>>> +	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +
>>> +	entry->vid = ret & GLOBAL_VTU_VID_MASK;
>>> +	entry->valid = !!(ret & GLOBAL_VTU_VID_VALID);
>>> +
>>> +	if (entry->valid) {
>>> +		/* Ports 0-3, offsets 0, 4, 8, 12 */
>>> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3);
>>> +		if (ret < 0)
>>> +			return ret;
>>> +
>>> +		for (i = 0; i < 4; ++i)
>>> +			entry->tags[i] = (ret >> (i * 4)) & 3;
>>> +
>>> +		/* Ports 4-6, offsets 0, 4, 8 */
>>> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7);
>>> +		if (ret < 0)
>>> +			return ret;
>>> +
>>> +		for (i = 4; i < 7; ++i)
>>> +			entry->tags[i] = (ret >> ((i - 4) * 4)) & 3;
>>
>> Hi Vivien
>>
>> It looks like you still have up to 7 ports, rather than use
>> ps->num_ports. I have a ten port switch i would like to use VLANs with
>> :-)
>>
>>> +
>>> +		if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
>>> +		    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
>>> +			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
>>> +						  GLOBAL_VTU_FID);
>>> +			if (ret < 0)
>>> +				return ret;
>>> +
>>> +			entry->fid = ret & GLOBAL_VTU_FID_MASK;
>>> +
>>> +			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
>>> +						  GLOBAL_VTU_SID);
>>> +			if (ret < 0)
>>> +				return ret;
>>> +
>>> +			entry->sid = ret & GLOBAL_VTU_SID_MASK;
>>> +		} else {
>>> +			entry->fid = 0;
>>> +			entry->sid = 0;
>>> +		}
>>> +	}
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
>>> +				    struct mv88e6xxx_vtu_entry *entry)
>>> +{
>>> +	u16 data = 0;
>>> +	int ret, i;
>>> +
>>> +	ret = _mv88e6xxx_vtu_wait(ds);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +
>>> +	if (entry->valid) {
>>> +		/* Set Data Register, ports 0-3, offsets 0, 4, 8, 12 */
>>> +		for (data = i = 0; i < 4; ++i)
>>> +			data |= entry->tags[i] << (i * 4);
>>> +		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3,
>>> +					   data);
>>> +		if (ret < 0)
>>> +			return ret;
>>> +
>>> +		/* Set Data Register, ports 4-6, offsets 0, 4, 8 */
>>> +		for (data = 0, i = 4; i < 7; ++i)
>>> +			data |= entry->tags[i] << ((i - 4) * 4);
>>> +		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7,
>>> +					   data);
>>
>> Same again here.
>>
>>       Andrew
>
> Indeed, I intentionally kept it as is, since the 88E6352 datasheet is not
> really clear about this. I see that the register 0x09 (called
> GLOBAL_VTU_DATA_8_11 in mv88e6xxx.h) only contains VID priority related bits in
> 15:12, in my case. As bits 11:0 are reserved, I suspect that the offsets of
> Member TagP7, Member TagP8 and Member TagP9 are respectively 0, 4 and 8 for
> you. Can you confirm? If so, I'll make that generic with these values.
>

For 6152 and 6185: Port 7 is in bit 12:15 of GLOBAL_VTU_DATA_4_7, port 8 and 9
are in register 9, bit 0:3 and 4:7.

Guenter
