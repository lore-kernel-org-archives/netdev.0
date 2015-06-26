From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/3] net: dsa: mv88e6xxx: add debugfs interface for VTU
Date: Fri, 26 Jun 2015 11:42:38 -0400 (EDT)
Message-ID: <473155649.316793.1435333358566.JavaMail.zimbra@savoirfairelinux.com>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1435095970-18576-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20150626140434.GB9469@lunn.ch> <806756942.307866.1435331071618.JavaMail.zimbra@savoirfairelinux.com> <20150626152344.GI9469@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:53698 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbbFZPml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 11:42:41 -0400
In-Reply-To: <20150626152344.GI9469@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Jun 26, 2015, at 11:23 AM, Andrew Lunn andrew@lunn.ch wrote:

>> >> +static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
>> >> +                  struct mv88e6xxx_vtu_entry *entry)
>> >> +{
>> >> +    int ret, i;
>> >> +
>> >> +    ret = _mv88e6xxx_vtu_wait(ds);
>> >> +    if (ret < 0)
>> >> +        return ret;
>> >> +
>> >> +    ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
>> >> +                   vid & GLOBAL_VTU_VID_MASK);
>> >> +    if (ret < 0)
>> >> +        return ret;
>> >> +
>> >> +    ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_GET_NEXT);
>> >> +    if (ret < 0)
>> >> +        return ret;
>> >> +
>> >> +    ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
>> >> +    if (ret < 0)
>> >> +        return ret;
>> >> +
>> >> +    entry->vid = ret & GLOBAL_VTU_VID_MASK;
>> >> +    entry->valid = !!(ret & GLOBAL_VTU_VID_VALID);
>> >> +
>> >> +    if (entry->valid) {
>> >> +        /* Ports 0-3, offsets 0, 4, 8, 12 */
>> >> +        ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3);
>> >> +        if (ret < 0)
>> >> +            return ret;
>> >> +
>> >> +        for (i = 0; i < 4; ++i)
>> >> +            entry->tags[i] = (ret >> (i * 4)) & 3;
>> >> +
>> >> +        /* Ports 4-6, offsets 0, 4, 8 */
>> >> +        ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7);
>> >> +        if (ret < 0)
>> >> +            return ret;
>> >> +
>> >> +        for (i = 4; i < 7; ++i)
>> >> +            entry->tags[i] = (ret >> ((i - 4) * 4)) & 3;
>> >> +
>> >> +        ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_FID);
>> >> +        if (ret < 0)
>> >> +            return ret;
>> >> +
>> >> +        entry->fid = ret & GLOBAL_VTU_FID_MASK;
>> >> +
>> >> +        ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_SID);
>> >> +        if (ret < 0)
>> >> +            return ret;
>> >> +
>> >> +        entry->sid = ret & GLOBAL_VTU_SID_MASK;
>> > 
>> > As you point out in the header file, not all switches have FID and
>> > VID. A quick look at DSDT suggests for both FID and SID:
>> > 
>> > DEV_88E6097_FAMILY | DEV_88E6165_FAMILY | DEV_88E6351_FAMILY |
>> > DEV_88E6352_FAMILY
>> > 
>> > Please limit access to these registers to just these families.
>> 
>> OK. Thanks for pointing this out. I think you meant SID instead of VID.
> 
> Yes, my error.
> 
>> Would something like the following be correct then?
>> 
>> #define GLOBAL_VTU_FID          0x02    /* 6097 6165 6351 6352 */
>> #define GLOBAL_VTU_SID          0x03    /* 6097 6165 6351 6352 */
> 
> Yes. I've not annotated all #defines, but here there is a clear
> overlap with the MAC address for some chips, so the comment is
> justified.
> 
>>     if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
>>         mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
>>         ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_FID);
>>         if (ret < 0)
>>             return ret;
>> 
>>         entry->fid = ret & GLOBAL_VTU_FID_MASK;
>> 
>>         ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_SID);
>>         if (ret < 0)
>>             return ret;
>> 
>>         entry->sid = ret & GLOBAL_VTU_SID_MASK;
>>     }
> 
> Maybe add an else to set sid and fid to 0?

Sure, done. Thanks for the reviews.

-v
