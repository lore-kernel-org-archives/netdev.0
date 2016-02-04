From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: bonding reports interface up with 0 Mbps
Date: Thu, 4 Feb 2016 10:56:09 +0800
Message-ID: <56B2BDC9.6020305@gmail.com>
References: <87618083B2453E4A8714035B62D6799250524233@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33871 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131AbcBDCzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 21:55:42 -0500
Received: by mail-pf0-f170.google.com with SMTP id o185so27984382pfb.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 18:55:42 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D6799250524233@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Emil

Thanks for your hard work.

With kernel 3.14, NETDEV_CHANGELOWERSTATE is not introduced. my user 
still confronted
"bond_mii_monitor: bond0: link status definitely up for interface eth1, 
0 Mbps full duplex".

How to explain it?

Would you like to make tests with kernel 3.14?

Thanks a lot.

Zhu Yanjun

On 02/04/2016 07:10 AM, Tantilov, Emil S wrote:
> We are seeing an occasional issue where the bonding driver may report interface up with 0 Mbps:
> bond0: link status definitely up for interface eth0, 0 Mbps full duplex
>
> So far in all the failed traces I have collected this happens on NETDEV_CHANGELOWERSTATE event:
>
> <...>-20533 [000] .... 81811.041241: ixgbe_service_task: eth1: NIC Link is Up 10 Gbps, Flow Control: RX/TX
> <...>-20533 [000] .... 81811.041257: ixgbe_check_vf_rate_limit <-ixgbe_service_task
> <...>-20533 [000] .... 81811.041272: ixgbe_ping_all_vfs <-ixgbe_service_task
> kworker/u48:0-7503  [010] .... 81811.041345: ixgbe_get_stats64 <-dev_get_stats
> kworker/u48:0-7503  [010] .... 81811.041393: bond_netdev_event: eth1: event: 1b
> kworker/u48:0-7503  [010] .... 81811.041394: bond_netdev_event: eth1: IFF_SLAVE
> kworker/u48:0-7503  [010] .... 81811.041395: bond_netdev_event: eth1: slave->speed = ffffffff
> <...>-20533 [000] .... 81811.041407: ixgbe_ptp_overflow_check <-ixgbe_service_task
> kworker/u48:0-7503  [010] .... 81811.041407: bond_mii_monitor: bond0: link status definitely up for interface eth1, 0 Mbps full duplex
>
> As a proof of concept I added NETDEV_CHANGELOWERSTATE in bond_slave_netdev_event() along with NETDEV_UP/CHANGE:
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 56b5605..a9dac4c 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3014,6 +3014,7 @@ static int bond_slave_netdev_event(unsigned long event,
>   		break;
>   	case NETDEV_UP:
>   	case NETDEV_CHANGE:
> +	case NETDEV_CHANGELOWERSTATE:
>   		bond_update_speed_duplex(slave);
>   		if (BOND_MODE(bond) == BOND_MODE_8023AD)
>   			bond_3ad_adapter_speed_duplex_changed(slave);
>
> With this change I have not seen 0 Mbps reported by the bonding driver (around 12 hour test up to this point
> vs. 2-3 hours otherwise). Although I suppose it could also be some sort of race/timing issue with bond_mii_monitor().
>
> This test is with current bonding driver from net-next (top commit 03d84a5f83).
>
> The bond is configured as such:
>
> mode = 802.3ad
> lacp_rate = fast
> miimon = 100
> xmit_hash_policy = layer3+4
>
> I should note that the speed is reported correctly in /proc/net/bonding/bond0 once the bond0 interface is up,
> so this seems to be just an issue with the initial detection of the speed. At least from what I have seen so far.
>
> Thanks,
> Emil
>
>
