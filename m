From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Thu, 12 May 2011 11:53:37 -0700
Message-ID: <F9877D83-226B-4C7A-AD01-E9AA441AD1CD@qlogic.com>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1305154448-9687-4-git-send-email-anirban.chakraborty@qlogic.com>
 <1305221242.5214.36.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:35368 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab1ELSxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 14:53:43 -0400
In-Reply-To: <1305221242.5214.36.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 12, 2011, at 10:27 AM, Ben Hutchings wrote:

> On Wed, 2011-05-11 at 15:54 -0700, Anirban Chakraborty wrote:
>> Driver checks if the previous dump has been cleared before taking the dump.
>> It doesn't take the dump if it is not cleared.
>> 
>> Changes from v2:
>> Added lock to protect dump data structures from being mangled while
>> dumping or setting them via ethtool.
> 
> Unfortunately it still seems to be possible for the dump length to
> change between the ethtool core calling qlcnic_get_dump_flag() and
> qlcnic_get_dump_data().

dump length is serialized via the driver lock. dump length is a static entity for a given capture mask
and it can only be changed when there is a different capture mask set in the driver (via calling
set_dump() from ethtool core).
Actual dump size is determined during the initial steps of FW dump which takes the driver lock
to start with. So, I am not sure how the dump length could be changed between the calls to
get_dump_flag and get_dump_data from within the ethtool core without a call to set_dump()
in between.

> 
> So I think qlcnic_get_dump_data() will need to double-check the length
> after taking the internal lock:
> 
> [...]
>> +static int
>> +qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
>> +                       void *buffer)
>> +{
>> +       int i, copy_sz;
>> +       u32 *hdr_ptr, *data;
>> +       struct qlcnic_adapter *adapter = netdev_priv(netdev);
>> +       struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
>> +
>> +       if (qlcnic_api_lock(adapter))
>> +               return -EIO;
> [...]
> 
> 	if (dump->len < fw_dump->tmpl_hdr->size + fw_dump->size) {
> 		qlcnic_api_unlock(adapter);
> 		return -EINVAL;
> 	}
> 
> I'm not sure about the error code... and I'm really not happy about the
> need to check lengths in both the ethtool core and the driver.
I can put the check in here but don't think it is required really.

> 
> Can't you change the function that actually makes a dump to acquire the
> RTNL lock?  (You'll need to do that *before* acquiring the driver's own
> lock.)
We can't do that because the driver lock is taken at much higher level where it does
some hardware specific things even before attempting to take FW dump.

Thanks.
-Anirban



