From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] net/mlx5_core: Support MANAGE_PAGES and QUERY_PAGES firmware
 command changes
Date: Thu, 15 Aug 2013 12:18:15 +0300
Message-ID: <520C9CD7.1090400@mellanox.com>
References: <1376491608-3759-1-git-send-email-moshel@mellanox.com> <20130815.014837.1103024579636450520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <moshel@mellanox.com>, <netdev@vger.kernel.org>,
	<roland@kernel.org>, <eli@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:35819 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751439Ab3HOJSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 05:18:23 -0400
In-Reply-To: <20130815.014837.1103024579636450520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/08/2013 11:48, David Miller wrote:
> From: Moshe Lazer <moshel@mellanox.com>
> Date: Wed, 14 Aug 2013 17:46:48 +0300
>
>> In the previous QUERY_PAGES command version we used one command to get the
>> required amount of boot, init and post init pages.  The new version uses the
>> op_mod field to specify whether the query is for the required amount of boot,
>> init or post init pages. In addition the output field size for the required
>> amount of pages increased from 16 to 32 bits.
>>
>> In MANAGE_PAGES command the input_num_entries and output_num_entries fields
>> sizes changed from 16 to 32 bits and the PAS tables offset changed to 0x10.
>>
>> In the pages request event the num_pages field also changed to 32 bits.
>>
>> In the HCA-capabilities-layout the size and location of max_qp_mcg field has
>> been changed to support 24 bits.
>>
>> This patch isn't compatible with firmware versions < 5; however, it  turns out that the
>> first GA firmware we will publish will not support previous versions so this should be OK.
>>
>> Signed-off-by: Moshe Lazer <moshel@mellanox.com>
>> Signed-off-by: Eli Cohen <eli@mellanox.com>
> You're going to have to explain a few things before I'm even going to consider
> applying this.

Dave, sure, see below:

> What tree are you targetting 'net' or 'net-next'?
>
> Next, does this break things for people using older firmware?
>
> I don't see anything that verifies that the firmware is of a version
> that uses the command data structures you're changing in this patch.
>
> If you're not checking, this is terrible, and I find it utterly
> unacceptable.
>
> You can't just go "oh the latest firmware uses this new layout, so
> we don't have to consider what the older firmware wants."
>

YES, this is for net (3.11), sorry for the missing label in the [PATCH] 
brackets part.

The mlx5 driver serves new hardware, of an HCA called ConnectIB for 
which there was no GA firmware release yet, 3.11 is the first upstream 
release that supports that HW.

So in that respect, for those users having firmware with Command IF Rev 
< 5, the patch doesn't let them work, HOWEVER, they will get warning 
from mlx5_cmd_init() which is called by the IB driver (who does 
mlx5_dev_init() --> mlx5_cmd_init()) that the command revision isn't 
supported and hence will realize the firmware needs to be upgraded, see 
this code snippet:

cmd->cmdif_rev = ioread32be(&dev->iseg->cmdif_rev_fw_sub) >> 16;
if (cmd->cmdif_rev > CMD_IF_REV) {
     dev_err(&dev->pdev->dev, "driver does not support command interface 
version.[..]

The related code is present in the mlx5_core driver which is serving as 
library for the IB driver and future transport (e.g Ethernet) drivers.

This commit fixes an issue (bug) which we find in testing done on the 
code/firmware used for the initial merge, xxit happens, indeed. All in 
all, we understand that moving forward, after the initial FW GA or the 
release of 3.11, we will have to maintain FW/driver compatibility.

Or.
