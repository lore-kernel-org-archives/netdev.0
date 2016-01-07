From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 14:22:02 +0800
Message-ID: <568E040A.5010604@gmail.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com
To: emil.s.tantilov@intel.com, mkubecek@suse.cz,
	jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34055 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbcAGGWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 01:22:11 -0500
Received: by mail-io0-f177.google.com with SMTP id 1so195510166ion.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 22:22:11 -0800 (PST)
In-Reply-To: <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Emil

Would you like to help me to make tests with this patch?
If the root cause is not the time span, I will make a new patch for this.

Thanks a lot.
Zhu Yanjun

On 01/07/2016 02:15 PM, zyjzyj2000@gmail.com wrote:
> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>
> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
> there is a time span between NIC up state and getting speed and duplex.
> As such, sometimes a slave in 802.3ad mode is in up state without
> speed and duplex. This will make bonding in 802.3ad mode can not
> work well.
> To make bonding driver be compatible with more NICs, it is
> necessary to restrict the up state in 802.3ad mode.
>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> ---
>   drivers/net/bonding/bond_main.c |   11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 09f8a48..7df8af5 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1991,6 +1991,17 @@ static int bond_miimon_inspect(struct bonding *bond)
>   
>   		link_state = bond_check_dev_link(bond, slave->dev, 0);
>   
> +		if ((BMSR_LSTATUS == link_state) &&
> +		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
> +			rtnl_lock();
> +			bond_update_speed_duplex(slave);
> +			rtnl_unlock();
> +			if ((slave->speed == SPEED_UNKNOWN) ||
> +			    (slave->duplex == DUPLEX_UNKNOWN)) {
> +				link_state = 0;
> +				netdev_info(bond->dev, "In 802.3ad mode, it is not enough to up without speed and duplex");
> +			}
> +		}
>   		switch (slave->link) {
>   		case BOND_LINK_UP:
>   			if (link_state)
