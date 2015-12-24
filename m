From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] ixgbe: force to synchronize
 reporting "link on" and getting speed and duplex
Date: Thu, 24 Dec 2015 10:27:39 +0800
Message-ID: <567B581B.6080608@gmail.com>
References: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
 <87618083B2453E4A8714035B62D67992504EB551@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Viswanathan, Ven (Wind River)" <venkat.viswanathan@windriver.com>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"Bourg, Vincent (Wind River)" <vincent.bourg@windriver.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34158 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbbLXC1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 21:27:49 -0500
Received: by mail-pf0-f171.google.com with SMTP id e65so8633284pfe.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 18:27:48 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D67992504EB551@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2015 11:59 PM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>> Behalf Of zyjzyj2000@gmail.com
>> Sent: Tuesday, December 22, 2015 10:47 PM
>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
>> Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak, John; Williams, Mitch
>> A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; e1000-
>> devel@lists.sourceforge.net
>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River); Bourg,
>> Vincent (Wind River)
>> Subject: [Intel-wired-lan] [PATCH 1/1] ixgbe: force to synchronize
>> reporting "link on" and getting speed and duplex
>>
>> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>>
>> In X540 NIC, there is a time span between reporting "link on" and
>> getting the speed and duplex. To a bonding driver in 802.3ad mode,
>> this time span will make it not work well if the time span is big
>> enough. The big time span will make bonding driver change the state of
>> the slave device to up while the speed and duplex of the slave device
>> can not be gotten. Later the bonding driver will not have change to
>> get the speed and duplex of the slave device. The speed and duplex of
>> the slave device are important to a bonding driver in 802.3ad mode.
>>
>> To 82599_SFP NIC and other kinds of NICs, this problem does
>> not exist. As such, it is necessary for X540 to report"link on" when
>> the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
>>
>> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>> ---
>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 +++++++++++++++-
>> 1 file changed, 15 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index aed8d02..cb9d310 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -6479,7 +6479,21 @@ static void ixgbe_watchdog_link_is_up(struct
>> ixgbe_adapter *adapter)
>> 	       (flow_rx ? "RX" :
>> 	       (flow_tx ? "TX" : "None"))));
>>
>> -	netif_carrier_on(netdev);
>> +	/*
>> +	 * In X540 NIC, there is a time span between reporting "link on"
>> +	 * and getting the speed and duplex. To a bonding driver in 802.3ad
>> +	 * mode, this time span will make it not work well if the time span
>> +	 * is big enough. To 82599_SFP NIC and other kinds of NICs, this
>> +	 * problem does not exist. As such, it is better for X540 to report
>> +	 * "link on" when the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
>> +	 */
>> +	if ((hw->mac.type == ixgbe_mac_X540) &&
>> +	    (link_speed != IXGBE_LINK_SPEED_UNKNOWN)) {
>> +		netif_carrier_on(netdev);
>> +	} else {
>> +		netif_carrier_on(netdev);
>> +	}
>> +
>> 	ixgbe_check_vf_rate_limit(adapter);
>>
>> 	/* enable transmits */
>> --
>> 1.7.9.5
> NAK
>
> I have already submitted a patch that will address the issue with bonding reporting
> unknown speed (in /proc/bonding/bondX) after the link is established due to link flaps:
> http://patchwork.ozlabs.org/patch/552485/
>
> The bonding driver gets the speed from ethtool and this is where the reporting needs
> to be fixed. The issue is that the bonding driver polls for netif_carrier_ok() at a
> certain rate and as such will not be able to detect rapid link changes.
Thanks for your reply. The root cause is different from my problem. My 
problem is that
"link up" is prior to "speed and duplex". That is, the physical NIC 
reports "link up" while
the speed is unknown at the same time. We can run "ethtool ethx" to 
confirm it.

Any way, thanks a lot.

Zhu Yanjun
>
> If there is a case where link_speed is unknown when entering this function it's probably
> better to just bail rather than have this hack around the netif_carrier_on() especially
> after the driver already reported link status change. Rapid link changes can occur between
> link partners and not just for X540.
>
> Thanks,
> Emil
>
