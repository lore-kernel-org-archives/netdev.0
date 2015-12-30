From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict
 synchronization of link_up and speed
Date: Wed, 30 Dec 2015 10:49:16 +0800
Message-ID: <5683462C.3020801@gmail.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
	<1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
	<1451356326-2919-3-git-send-email-zyjzyj2000@gmail.com>
	<87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Viswanathan, Ven \(Wind River\)" <venkat.viswanathan@windriver.com>,
	"Shteinbock,
	Boris \(Wind River\)" <boris.shteinbock@windriver.com>, "Bourg,
	Vincent \(Wind River\)" <vincent.bourg@windriver.com>
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
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/30/2015 12:18 AM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>> Behalf Of zyjzyj2000@gmail.com
>> Sent: Monday, December 28, 2015 6:32 PM
>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny,
>> Carolyn; Skidmore, Donald C; Allan, Bruce W; Ronciak, John; Williams, Mitch
>> A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; e1000-
>> devel@lists.sourceforge.net
>> Cc: Viswanathan, Ven (Wind River); Shteinbock, Boris (Wind River); Bourg,
>> Vincent (Wind River)
>> Subject: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization of
>> link_up and speed
>>
>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>
>> When the X540 NIC acts as a slave of some virtual NICs, it is very
>> important to synchronize link_up and link_speed, such as a bonding
>> driver in 802.3ad mode. When X540 NIC acts as an independent interface,
>> it is not necessary to synchronize link_up and link_speed. That is,
>> the time span between link_up and link_speed is acceptable.
> What exactly do you mean by "time span between link_up and link_speed"?

In the previous mail, I show you some ethtool logs. In these logs, there 
is some
time with NIC up while speed is unknown. I think this "some time" is 
time span between
link_up and link_speed. Please see the previous mail for details.

> Where is it you think the de-synchronization occurs?

When a NIC interface acts as a slave, a flag "IFF_SLAVE" is set in 
netdevice struct.
Before we enter this function, we check IFF_SLAVE flag. If this flag is 
set, we continue to check
link_speed. If not, this function is executed whether this link_speed is 
unknown or not.

>
>> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>> ---
>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 ++++++++-
>> 1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index ace21b9..1bb6056 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -6436,8 +6436,15 @@ static void ixgbe_watchdog_link_is_up(struct
>> ixgbe_adapter *adapter)
>> 	 * time. To X540 NIC, there is a time span between link_up and
>> 	 * link_speed. As such, only continue if link_up and link_speed are
>> 	 * ready to X540 NIC.
>> +	 * The time span between link_up and link_speed is very important
>> +	 * when the X540 NIC acts as a slave in some virtual NICs, such as
>> +	 * a bonding driver in 802.3ad mode. When X540 NIC acts as an
>> +	 * independent interface, it is not necessary to synchronize link_up
>> +	 * and link_speed.
>> +	 * In the end, not continue if (X540 NIC && SLAVE && link_speed
>> UNKNOWN)
> This is a patch on top of your previous patch which I don't think was applied,
> so this is not going to apply cleanly.
>
>> 	 */
>> -	if (hw->mac.type == ixgbe_mac_X540)
>> +	if ((hw->mac.type == ixgbe_mac_X540) &&
>> +	    (netdev->flags & IFF_SLAVE))
>> 		if (link_speed == IXGBE_LINK_SPEED_UNKNOWN)
>> 			return;
> If you were to enter ixgbe_watchdog_link_is_up() with unknown speed, then I would
> assume that you also have a dmesg that shows:
> "NIC Link is Up unknown speed"
>
> by the interface you use in the bond?
Sure. There is a dmesg log from the customer.
"
...
2015-10-05T06:14:34.350 controller-0 kernel: info bonding: bond0: link 
status definitely up for interface eth0, 0 Mbps full duplex.
...
"

Thanks a lot.
Zhu Yanjun
>
> Thanks,
> Emil
>


------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
