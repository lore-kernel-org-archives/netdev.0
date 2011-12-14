From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [PATCH net-next] igb: reset PHY after recovering
 from PHY power down
Date: Wed, 14 Dec 2011 14:55:31 +0900
Message-ID: <4EE83A53.2030202@jp.fujitsu.com>
References: <4ECDB76F.1090104@jp.fujitsu.com>
	<EDC0E76513226749BFBC9C3FB031318F01832E2C5C@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "davem@davemloft.net" <davem@davemloft.net>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F01832E2C5C@orsmsx508.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

(2011/11/29 2:57), Wyborny, Carolyn wrote:
> 
> 
>> -----Original Message-----
>> From: Koki Sanagi [mailto:sanagi.koki@jp.fujitsu.com]
>> Sent: Wednesday, November 23, 2011 7:18 PM
>> To: netdev@vger.kernel.org; Kirsher, Jeffrey T; Brandeburg, Jesse;
>> Allan, Bruce W; Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V;
>> Waskiewicz Jr, Peter P; Duyck, Alexander H; Ronciak, John; e1000-
>> devel@lists.sourceforge.net
>> Cc: davem@davemloft.net
>> Subject: [PATCH net-next] igb: reset PHY after recovering from PHY power
>> down
>>
>> According to 82576_Datasheet.pdf, PHY setting is lost after PHY power
>> down.
>> So resetting PHY is needed when recovering from PHY power down to set a
>> default
>> setting to PHY register.
>>
>> Owing to this lack, NIC doesn't link up in some rare situation.
>> The situation I encountered is following.
>>
>>
>> 1.Both ports connect to switch.
>> +---------+           +--------+
>> |         |-----------|        |
>> | 82576NS |           | switch |
>> |         |-----------|        |
>> +---------+           +--------+
>>
>> 2.Detach both cables from switch.
>> +---------+           +--------+
>> |         |-------    |        |
>> | 82576NS |           | switch |
>> |         |-------    |        |
>> +---------+           +--------+
>>
>> 3.Detach one cable from one port.
>> +---------+           +--------+
>> |         |-------    |        |
>> | 82576NS |           | switch |
>> |         |           |        |
>> +---------+           +--------+
>>
>> 4.Attach that cable to the other port.(It means connecting directly each
>> port)
>> +---------+           +--------+
>> |         |-------+   |        |
>> | 82576NS |       |   | switch |
>> |         |-------+   |        |
>> +---------+           +--------+
>>
>> As a result, NIC doesn't link up sometimes.
>>
>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> ---
>> drivers/net/ethernet/intel/igb/igb_main.c |    1 +
>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>> b/drivers/net/ethernet/intel/igb/igb_main.c
>> index bd9b30e..4d4f065 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -2496,6 +2496,7 @@ static int igb_open(struct net_device *netdev)
>> 		goto err_setup_rx;
>>
>> 	igb_power_up_link(adapter);
>> +	igb_reset_phy(hw);
>>
>> 	/* before we allocate an interrupt, we must be ready to handle it.
>> 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
> 
> Hello,
> 
> This seems reasonable, however it would only cover cases where igb_open is being called.  It would be better to integrate the phy_reset call into igb_power_up_link, so that's the default. I can provide an alternate by end of the week.
> 

When will the alternate be provided ?

In addition, more general problem which this lack of reset causes is found.

Two machine have 82576NS and each NIC is connected directly each other.

+--------+                           +--------+
|        |                           |        |
|        +-------+           +-------+        |
|        |       |           |       |        |
|machineA|82576NS|-----------|82576NS|machineB|
|        |       |           |       |        |
|        +-------+           +-------+        |
|        |                           |        |
+--------+                           +--------+

When attaching and detaching a cable repeatedly on one side port,
that side port becomes not link up.

This is also fixed by adding resetting phy.

Thanks,
Koki Sanagi

> Thanks,
> 
> Carolyn
> 
> Carolyn Wyborny
> Linux Development
> LAN Access Division
> Intel Corporation
> 
> 
> 
> 



------------------------------------------------------------------------------
Cloud Computing - Latest Buzzword or a Glimpse of the Future?
This paper surveys cloud computing today: What are the benefits? 
Why are businesses embracing it? What are its payoffs and pitfalls?
http://www.accelacomm.com/jaw/sdnl/114/51425149/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
