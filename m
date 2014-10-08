From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Thu, 9 Oct 2014 00:03:55 +0200
Message-ID: <BF59E6FF-B3C7-4141-95E7-2EBAB4510B44@suse.de>
References: <1412803407-10621-1-git-send-email-agraf@suse.de> <1412803961.2260.5.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58597 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933110AbaJHWD6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 18:03:58 -0400
In-Reply-To: <1412803961.2260.5.camel@jtkirshe-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> Am 08.10.2014 um 23:32 schrieb Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> 
>> On Wed, 2014-10-08 at 23:23 +0200, Alexander Graf wrote:
>> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
>> address to the VF on reset rather than a random one.
>> 
>> However, that behavioral change also requires igbvf driver changes
>> which can be hard especially when we want to talk to proprietary
>> guest OSs.
>> 
>> Looking at the code previous to the commit in Linux that made igbvf
>> work with empty mac addresses (8d56b6d), we can see that on reset
>> failure the driver will try to generate a new mac address with both
>> the old and the new code.
>> 
>> Furthermore, ixgbe does send reset failure when it detects an empty
>> mac address (35055928c).
>> 
>> So I think it's safe to make igb behave the same. With this patch I
>> can successfully run a Windows 8.1 guest with an empty mac address
>> and an assigned igbvf device that has no mac address set by the host.
>> 
>> If anyone is aware of a guest driver that chokes on NACK returns of
>> VF RESET commands, please speak up.
>> 
>> Signed-off-by: Alexander Graf <agraf@suse.de>
>> ---
>> drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
>> 1 file changed, 6 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>> index cb14bbd..e8c53b6 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -6024,8 +6024,12 @@ static void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
>>    adapter->vf_data[vf].flags |= IGB_VF_FLAG_CTS;
>> 
>>    /* reply to reset with ack and vf mac address */
>> -    msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
>> -    memcpy(addr, vf_mac, ETH_ALEN);
>> +    if (!is_zero_ether_addr(vf_mac)) {
>> +        msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
>> +        memcpy(addr, vf_mac, ETH_ALEN);
> 
> I know we were using memcpy() before, but shouldn't we convert this to
> use the preferred ether_addr_copy()?

Sure, but don't you think a coccinelle script across the intel drivers would be better than single spot changes? ;)

Alex
