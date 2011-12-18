From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [PATCH net-next] igb: reset PHY after recovering from PHY power
 down
Date: Mon, 19 Dec 2011 08:59:28 +0900
Message-ID: <4EEE7E60.5030000@jp.fujitsu.com>
References: <4ECDB76F.1090104@jp.fujitsu.com> <9BBC4E0CF881AA4299206E2E1412B626C0CF@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:41170 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab1LSAAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 19:00:17 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 676D33EE0BB
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:00:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A2B345DE62
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:00:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 30F1745DE5E
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:00:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CC1B1DB804D
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:00:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AECC71DB8052
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:00:14 +0900 (JST)
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B626C0CF@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2011/12/17 0:53), Wyborny, Carolyn wrote:
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
> I apologize for the delay in getting back to you.  After a review, I see 
> that the needed change is simpler than I thought at first.  Can you resubmit
> with the igb_reset_phy call being added to the end of the igb_power_up_link 
> function instead of after it in igb_open.  That way, whenever igb_power_link
> is called in the code, it will also execute the igb_reset_phy function which 
> is the complete solution.  Thank you for your work on the igb driver.
> 

Thank you for your reply.

O.K. I'll resubmit it soon.

Thanks!
Koki Sanagi


> Carolyn
> 
> Carolyn Wyborny
> Linux Development
> LAN Access Division
> Intel Corporation
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
