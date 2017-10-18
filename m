From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Add fdb/mdb manipulation
Date: Wed, 18 Oct 2017 16:47:02 +0200
Message-ID: <cba8bbb2-7068-c7c9-8ef4-1781a393eb45@egil-hjelmeland.no>
References: <20171018105935.12489-1-privat@egil-hjelmeland.no>
 <20171018105935.12489-3-privat@egil-hjelmeland.no>
 <87mv4o4j3j.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:44322 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752364AbdJROr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 10:47:26 -0400
In-Reply-To: <87mv4o4j3j.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18. okt. 2017 16:38, Vivien Didelot wrote:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> +/* Delete static port from ALR entry, delete entry if last port */
>> +static int lan9303_alr_del_port(struct lan9303 *chip, const u8 *mac,
>> +				int port)
>> +{
>> +	struct lan9303_alr_cache_entry *entr;
>> +
>> +	entr = lan9303_alr_cache_find_mac(chip, mac);
>> +	if (!entr)
>> +		return 0;  /* no static entry found */
>> +		/* Question: Should we delete any learned entry?
>> +		 * { lan9303_alr_set_entry(chip, mac, 0, false); return 0; }
> 
> .port_fdb_del is meant to remove the association between a port and a
> MAC address in a given forwarding database. Deleting any learned entry
> is therefore out of scope of this function.
> 
> Please mark such patchset as RFC next time so that the maintainer knows
> that it is not meant to be applied.
> 
Thanks. And I will keep the RFC remark in mind.

>> +		 */
>> +
>> +	entr->port_map &= ~BIT(port);
>> +	if (entr->port_map == 0) /* zero means its free again */
>> +		eth_zero_addr(&entr->port_map);
>> +	lan9303_alr_set_entry(chip, mac, entr->port_map, entr->stp_override);
>> +	return 0;
>> +}
> 
> ...
> 
>> +static int lan9303_port_fdb_add(struct dsa_switch *ds, int port,
>> +				const unsigned char *addr, u16 vid)
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, addr, vid);
>> +	if (vid)
>> +		return -EOPNOTSUPP;
>> +	return lan9303_alr_add_port(chip, addr, port, false);
>> +}
>> +
>> +static int lan9303_port_fdb_del(struct dsa_switch *ds, int port,
>> +				const unsigned char *addr, u16 vid)
>> +
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	dev_dbg(chip->dev, "%s(%d, %pM, %d)\n", __func__, port, addr, vid);
>> +	if (vid)
>> +		return -EOPNOTSUPP;
>> +	lan9303_alr_del_port(chip, addr, port);
>> +	return 0;
>> +}
> 
> I don't remember, this chip has a single forwarding database for the
> whole switch, is that correct?
> 
Correct.

And the forwarding database (ALR) does not handle VLAN.
VLAN filtering is a separate step, with its own table.

> 
> Thanks,
> 
>          Vivien
> 
