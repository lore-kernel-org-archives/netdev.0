From: Joe Eykholt <joe.eykholt@gmail.com>
Subject: Re: [Open-FCoE] [PATCH] fcoe: correct checking for bonding
Date: Mon, 28 Feb 2011 09:54:29 -0800
Message-ID: <4D6BE155.7050109@gmail.com>
References: <20110228133245.GB7096@psychotron.brq.redhat.com> <8433.1298913321@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org,
	devel@open-fcoe.org, linux-scsi@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:34569 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab1B1Ryg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 12:54:36 -0500
In-Reply-To: <8433.1298913321@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/28/11 9:15 AM, Jay Vosburgh wrote:
> Jiri Pirko<jpirko@redhat.com>  wrote:
>
>> Check for IFF_BONDING as this flag is set-up for all bonding devices.
>>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>> ---
>> drivers/scsi/fcoe/fcoe.c |    4 +---
>> 1 files changed, 1 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
>> index 9f9600b..67714a4 100644
>> --- a/drivers/scsi/fcoe/fcoe.c
>> +++ b/drivers/scsi/fcoe/fcoe.c
>> @@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
>> 	}
>>
>> 	/* Do not support for bonding device */
>> -	if ((netdev->priv_flags&  IFF_MASTER_ALB) ||
>> -	    (netdev->priv_flags&  IFF_SLAVE_INACTIVE) ||
>> -	    (netdev->priv_flags&  IFF_MASTER_8023AD)) {
>> +	if (netdev->priv_flags&  IFF_BONDING) {
>> 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
>> 		return -EOPNOTSUPP;
>> 	}
>
> 	Based on past discussions, I believe the intent of the code is
> to permit FCOE over bonding only for active-backup mode, and possibly
> for -xor/-rr as well.
>
> 	I'm not sure if the slave or the master is what's being tested
> here, so I'm not sure what the right thing to do is.  I suspect it's the
> master, as I recall discussion of one configuration involving
> active-backup mode balancing FCOE traffic over both the active and
> inactive slaves.  FCOE uses the "orig_dev" logic in __netif_receive_skb
> to have the packets delivered even on the nominally inactive slave.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

Right.  That was the intent.  It should work on the physical dev, but probably
not on the master of the bond.

If you have a master/slave bond for IPv4 between eth1 and eth2, say,
and they are going to two different DCE (FCoE) switches, presumably on
different VSANs but with ultimate access to the same disks,
then you want to split the FCoE traffic in active/active
mode using separate FCoE instances on eth1 and eth2 even though IP
is using active/standby on bond0.  This should work.  But, putting fcoe
on bond0 isn't going to do what you want.

However, it seems like the check above shouldn't be checking
IFF_SLAVE_INACTIVE.   I can't test this.

	Joe

