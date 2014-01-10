From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Fri, 10 Jan 2014 08:44:33 +0100
Message-ID: <20140110074433.GA26273@redhat.com>
References: <52CE8604.3010804@huawei.com>
 <20140109114636.GF5786@redhat.com>
 <52CE94DE.5030305@huawei.com>
 <20140109123019.GM5786@redhat.com>
 <52CF751D.1020200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944AbaAJHrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 02:47:36 -0500
Content-Disposition: inline
In-Reply-To: <52CF751D.1020200@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 12:20:45PM +0800, Ding Tianhong wrote:
>On 2014/1/9 20:30, Veaceslav Falico wrote:
>> On Thu, Jan 09, 2014 at 08:23:58PM +0800, Ding Tianhong wrote:
>>> On 2014/1/9 19:46, Veaceslav Falico wrote:
>>>> On Thu, Jan 09, 2014 at 07:20:36PM +0800, Ding Tianhong wrote:
>>>>> If the primary_slave's name changed, but the bond->prams.primay w=
as
>>>>> still using the old name, it is conflict with the meaning of the
>>>>> primary, so update the primary when the slave change its name.
>>>>
>>>> Nope, the bonding parameter, which is set by the user, shouldn't c=
hange
>>>> because of an interface name change.
>>>>
>>> Yes, I know what you mean, but it is not bug fix, just make it more=
 better,
>>> do not you feel it strange that the primary was different with prim=
ary_slave's name?
>>
>> Yep, that's an issue - that's why there is the TODO. We shouldn't, t=
hough,
>> change the primary param, but rather check if the slave (that change=
d name)
>> is (already not) eligible for primary_slave.
>>
>
>Ok=EF=BC=8CSo=EF=BC=8Csummarize your and my opinion, I think there are=
 two ways to fix this:
>
>1. just like my patch said.

No, the primary string is user-set, and it should *not* be changed by
kernel.

>2. check if the primary is not the primary_slave, make the primary_sla=
ve =3D NULL, this means
>   the primary_slave is no valid.

Check the slave that changed name - if it's the primary slave, remove i=
t,
and see if we need to select the new active slave. If it's not the prim=
ray
slave, and we don't have one - select it as a new primary and, again, s=
ee
if we need to select a new active slave.

>3. ?? did you have any better ideas?
>
>Regards
>Ding
>
>>>
>>> Regards
>>> Ding
>>>
>>>
>>>>>
>>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>>> ---
>>>>> drivers/net/bonding/bond_main.c | 14 ++++++++++++--
>>>>> 1 file changed, 12 insertions(+), 2 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bondin=
g/bond_main.c
>>>>> index e06c445..de646e2 100644
>>>>> --- a/drivers/net/bonding/bond_main.c
>>>>> +++ b/drivers/net/bonding/bond_main.c
>>>>> @@ -2860,9 +2860,19 @@ static int bond_slave_netdev_event(unsigne=
d long event,
>>>>>          */
>>>>>         break;
>>>>>     case NETDEV_CHANGENAME:
>>>>> -        /*
>>>>> -         * TODO: handle changing the primary's name
>>>>> +        /* if the primary's name changed,
>>>>> +         * save the new name for primary.
>>>>>          */
>>>>> +        if (USES_PRIMARY(bond->params.mode) &&
>>>>> +            bond->params.primary[0]) {
>>>>> +            if (bond->primary_slave &&
>>>>> +                strcmp(bond->params.primary,
>>>>> +                   bond->primary_slave->dev->name)) {
>>>>> +                strncpy(bond->params.primary,
>>>>> +                    bond->primary_slave->dev->name,
>>>>> +                    IFNAMSIZ);
>>>>> +            }
>>>>> +        }
>>>>>         break;
>>>>>     case NETDEV_FEAT_CHANGE:
>>>>>         bond_compute_features(bond);
>>>>> --
>>>>> 1.8.0
>>>>>
>>>>>
>>>>
>>>>
>>>
>>>
>>
>> .
>>
>
>
