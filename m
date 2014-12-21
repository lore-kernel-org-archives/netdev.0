From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: avoid re-entry of bond_release
Date: Sun, 21 Dec 2014 10:01:36 +0800
Message-ID: <54962A00.6080005@huawei.com>
References: <1418979417-28867-1-git-send-email-wen.gang.wang@oracle.com> <20141219151157.GD22253@gospo>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25383 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbaLUCCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 21:02:00 -0500
In-Reply-To: <20141219151157.GD22253@gospo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/19 23:11, Andy Gospodarek wrote:
> On Fri, Dec 19, 2014 at 04:56:57PM +0800, Wengang Wang wrote:
>> If bond_release is run against an interface which is already detached from
>> it's master, then there is an error message shown like
>> 	"<master name> cannot release <slave name>".
>>
>> The call path is:
>> 	bond_do_ioctl()
>> 		bond_release()
>> 			__bond_release_one()
>>
>> Though it does not really harm, the message the message is misleading.
>> This patch tries to avoid the message.
>>
>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 184c434..4a71bbd 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3256,7 +3256,10 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
>>  		break;
>>  	case BOND_RELEASE_OLD:
>>  	case SIOCBONDRELEASE:
>> -		res = bond_release(bond_dev, slave_dev);
>> +		if (slave_dev->flags & IFF_SLAVE)
>> +			res = bond_release(bond_dev, slave_dev);
>> +		else
>> +			res = 0;
> 
> Functionally this patch is fine, but I would prefer that you simply
> change the check in __bond_release_one to not be so noisy.  There is a
> check[1] in bond_enslave to see if a slave is already in a bond and that
> just prints a message of netdev_dbg (rather than netdev_err) and it
> seems that would be appropriate for this type of message.
> 
> [1] from bond_enslave():
> 
>         /* already enslaved */
>         if (slave_dev->flags & IFF_SLAVE) {
>                 netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
>                 return -EBUSY;
>         }
> 
> 
>>  		break;
>>  	case BOND_SETHWADDR_OLD:
>>  	case SIOCBONDSETHWADDR:
>> -- 

agree ,use netdev_dbg looks more better and enough.

Ding

>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
