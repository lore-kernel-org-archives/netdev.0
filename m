From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] bonding: reset the slave's mtu when its be changed
Date: Sun, 12 Jan 2014 13:18:26 +0800
Message-ID: <52D225A2.3070208@huawei.com>
References: <52CFDA63.8070601@huawei.com> <20140110121932.GC4132@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:54210 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbaALFSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 00:18:48 -0500
In-Reply-To: <20140110121932.GC4132@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/10 20:19, Veaceslav Falico wrote:
> On Fri, Jan 10, 2014 at 07:32:51PM +0800, Ding Tianhong wrote:
>> All slave should have the same mtu with mastet's, and the bond do it when
>> enslave the slave, but the user could change the slave's mtu, it will cause
>> the master and slave have different mtu, althrough in AB mode, it does not
>> matter if the slave is not the current slave, but in other mode, it is incorrect,
>> so reset the slave's mtu like the master set.
> 
> Why "net"? It's not a bugfix, it's a feature, and really discussable.
> 
> Also, wrt the actual change - why do you think it's incorrect for slaves in
> bonding mode other than AB to have different MTU values? I don't see any
> reason for it, from the top of the head.
> 

Ok, I will test more situation for every mode when slave's mtu changed, I am not sure
what will happened yet, if some links was interrupt, I thinks it is a bug. 

>>
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 21 ++++++++++-----------
>> 1 file changed, 10 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 398e299..e7b5bcf 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2882,18 +2882,17 @@ static int bond_slave_netdev_event(unsigned long event,
>>          */
>>         break;
>>     case NETDEV_CHANGEMTU:
>> -        /*
>> -         * TODO: Should slaves be allowed to
>> -         * independently alter their MTU?  For
>> -         * an active-backup bond, slaves need
>> -         * not be the same type of device, so
>> -         * MTUs may vary.  For other modes,
>> -         * slaves arguably should have the
>> -         * same MTUs. To do this, we'd need to
>> -         * take over the slave's change_mtu
>> -         * function for the duration of their
>> -         * servitude.
>> +        /* All slave should have the same mtu
>> +         * as master.
>>          */
>> +        if (slave->dev->mtu != bond->dev->mtu) {
> 
> If we've got the event then it means it was changed to something different.
> No need to verify.
> 
>> +            int res;
>> +            slave->original_mtu = slave->dev->mtu;
> 
> If we're refusing to apply the *new* mtu, then why should we save it as the
> original? The original_mtu is the mtu that the slave had before it was
> enslaved.
> 
the bond always save the slave's old mtu and set new one, so I did it again,
pls miss it, I think we should forbidden to change the mtu.


>> +            res = dev_set_mtu(slave->dev, bond->dev->mtu);
>> +            if (res)
>> +                pr_debug("Error %d calling dev_set_mtu for slave %s\n",
>> +                     res, slave->dev->name);
>> +        }
> 
> Also, bonding should be vocal about changing forcibly the mtu - otherwise
> we'd end up with silently dropping the changes:
> 
> ifconfig eth0 mtu 9000
> echo $?
> -> 0
> ifconfig eth0
> MTU: 1500
> 
> or something like that, it will pass it up, refusing changes:
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index e06c445..0b36045 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2846,19 +2846,8 @@ static int bond_slave_netdev_event(unsigned long event,
>           */
>          break;
>      case NETDEV_CHANGEMTU:
> -        /*
> -         * TODO: Should slaves be allowed to
> -         * independently alter their MTU?  For
> -         * an active-backup bond, slaves need
> -         * not be the same type of device, so
> -         * MTUs may vary.  For other modes,
> -         * slaves arguably should have the
> -         * same MTUs. To do this, we'd need to
> -         * take over the slave's change_mtu
> -         * function for the duration of their
> -         * servitude.
> -         */
> -        break;
> +        /* don't permit slaves to change their MTU */
> +        return NOTIFY_BAD;
>      case NETDEV_CHANGENAME:
>          /*
>           * TODO: handle changing the primary's name
> 
>>         break;
>>     case NETDEV_CHANGENAME:
>>         /*
>> -- 
>> 1.8.0
>>

Yes, no problem.

Regards
Ding

>>
> 
> .
> 
