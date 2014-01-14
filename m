From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next v2 1/3] bonding: update the primary slave
 when changing slave's name
Date: Tue, 14 Jan 2014 20:52:02 +0800
Message-ID: <52D532F2.1010509@huawei.com>
References: <52D4FE85.6050101@huawei.com> <20140114105112.GC20066@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:65277 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaANMwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 07:52:42 -0500
In-Reply-To: <20140114105112.GC20066@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/14 18:51, Veaceslav Falico wrote:
> On Tue, Jan 14, 2014 at 05:08:21PM +0800, Ding Tianhong wrote:
>> If the slave's name changed, and the bond params primary is exist,
>> the bond should deal with the situation in two ways:
>>
>> 1) If the slave was the primary slave yet, clean the primary slave
>>   and reselect active slave.
>> 2) If the slave's new name is as same as bond primary, set the slave
>>   as primary slave and reselect active slave.
>>
>> Thanks for Veaceslav's suggestion.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 24 ++++++++++++++++++++++--
>> 1 file changed, 22 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index e06c445..64e25d5 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2860,9 +2860,29 @@ static int bond_slave_netdev_event(unsigned long event,
>>          */
>>         break;
>>     case NETDEV_CHANGENAME:
>> -        /*
>> -         * TODO: handle changing the primary's name
>> +        /* Handle changing the slave's name:
>> +         * 1) If the slave was primary slave,
>> +         * clean the primary slave and reselect
>> +         * active slave.
>> +         * 2) If the slave's new name is same as
>> +         * bond primary, set the slave as primary
>> +         * slave and reselect active slave.
>>          */
>> +        if (slave == bond->primary_slave ||
>> +            !strcmp(bond->params.primary, slave_dev->name)) {
> 
> And if we're in a mode that doesn't use primary, but have the
> params.primary set? Then we'll issue a bond_select_active_slave() in, say,
> 802.3ad mode.
> 
> In the past 24h I've nacked about 5 of your patchsets, with you keeping
> 'quickfixing' them, without getting your time to understand the issues, and
> re-sending them for review.
> 
> I'm not willing to waste my time that uselessly, reviewing patchsets that
> you randomly generate in the hope of getting it right. And given your
> 'good' history - with patchsets that cause regressions and bugs, with
> reverts because of that, with those horrible, meaningless RCU transition
> that is just plainly wrong and *really* hard to fix - I'm going to react as
> Greg KH said in one of his presentations - NAK your patches and make them
> by myself. It will take *a lot* lesser time from my side, and will
> eventually make the code better.
> 
> Thanks for the report, I'll send a patch that fixes it soon.
> 
> Nacked-by: Veaceslav Falico <vfalico@redhat.com>

Maybe I am not in the state all day, always miss here and miss there, sorry for that.

> 
>> +            if (bond->primary_slave) {
>> +                pr_info("%s: Setting primary slave to None.\n",
>> +                    bond->dev->name);
>> +                bond->primary_slave = NULL;
>> +            } else {
>> +                pr_info("%s: Setting %s as primary slave.\n",
>> +                    bond->dev->name, slave_dev->name);
>> +                bond->primary_slave = slave;
>> +            }
>> +            write_lock_bh(&bond->curr_slave_lock);
>> +            bond_select_active_slave(bond);
>> +            write_unlock_bh(&bond->curr_slave_lock);
>> +        }
>>         break;
>>     case NETDEV_FEAT_CHANGE:
>>         bond_compute_features(bond);
>> -- 
>> 1.8.0
>>
>>
> 
> .
> 
