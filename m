From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] fcoe: correct checking for bonding
Date: Tue, 1 Mar 2011 21:12:21 +0100
Message-ID: <20110301201220.GA2833@psychotron.redhat.com>
References: <20110228133245.GB7096@psychotron.brq.redhat.com>
	<8433.1298913321@death> <4D6BE155.7050109@gmail.com>
	<20110301063710.GD2855@psychotron.redhat.com>
	<4D6D31BA.3000105@gmail.com> <9554.1299002762@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jay Vosburgh <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9554.1299002762@death>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

Tue, Mar 01, 2011 at 07:06:02PM CET, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>Joe Eykholt <joe.eykholt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>>On 2/28/11 10:37 PM, Jiri Pirko wrote:
>>> Mon, Feb 28, 2011 at 06:54:29PM CET, joe.eykholt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>>>> On 2/28/11 9:15 AM, Jay Vosburgh wrote:
>>>>> Jiri Pirko<jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>   wrote:
>>>>>
>>>>>> Check for IFF_BONDING as this flag is set-up for all bonding devices.
>>>>>>
>>>>>> Signed-off-by: Jiri Pirko<jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>>>> ---
>>>>>> drivers/scsi/fcoe/fcoe.c |    4 +---
>>>>>> 1 files changed, 1 insertions(+), 3 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
>>>>>> index 9f9600b..67714a4 100644
>>>>>> --- a/drivers/scsi/fcoe/fcoe.c
>>>>>> +++ b/drivers/scsi/fcoe/fcoe.c
>>>>>> @@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
>>>>>> 	}
>>>>>>
>>>>>> 	/* Do not support for bonding device */
>>>>>> -	if ((netdev->priv_flags&   IFF_MASTER_ALB) ||
>>>>>> -	    (netdev->priv_flags&   IFF_SLAVE_INACTIVE) ||
>>>>>> -	    (netdev->priv_flags&   IFF_MASTER_8023AD)) {
>>>>>> +	if (netdev->priv_flags&   IFF_BONDING) {
>>>>>> 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
>>>>>> 		return -EOPNOTSUPP;
>>>>>> 	}
>>>>>
>>>>> 	Based on past discussions, I believe the intent of the code is
>>>>> to permit FCOE over bonding only for active-backup mode, and possibly
>>>>> for -xor/-rr as well.
>>>>>
>>>>> 	I'm not sure if the slave or the master is what's being tested
>>>>> here, so I'm not sure what the right thing to do is.  I suspect it's the
>>>>> master, as I recall discussion of one configuration involving
>>>>> active-backup mode balancing FCOE traffic over both the active and
>>>>> inactive slaves.  FCOE uses the "orig_dev" logic in __netif_receive_skb
>>>>> to have the packets delivered even on the nominally inactive slave.
>>>>>
>>>>> 	-J
>>>>>
>>>>> ---
>>>>> 	-Jay Vosburgh, IBM Linux Technology Center, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
>>>>
>>>> Right.  That was the intent.  It should work on the physical dev, but probably
>>>> not on the master of the bond.
>>>>
>>>> If you have a master/slave bond for IPv4 between eth1 and eth2, say,
>>>> and they are going to two different DCE (FCoE) switches, presumably on
>>>> different VSANs but with ultimate access to the same disks,
>>>> then you want to split the FCoE traffic in active/active
>>>> mode using separate FCoE instances on eth1 and eth2 even though IP
>>>> is using active/standby on bond0.  This should work.  But, putting fcoe
>>>> on bond0 isn't going to do what you want.
>>>>
>>>> However, it seems like the check above shouldn't be checking
>>>> IFF_SLAVE_INACTIVE.   I can't test this.
>>>
>>> OK. So I guess the right check should be for:
>>> (netdev->priv_flags&  IFF_BONDING&&  netdev->flags&  IFF_MASTER)
>>
>>I think that's OK.  How about just checking for MASTER?
>>When is MASTER going to be set without BONDING?
>
>	One or two other things besides bonding use IFF_MASTER, but
>IFF_BONDING is only for bonding.
>
>>Otherwise I'd add some parens or I might code this as:
>>
>>	if ((netdev->priv_flags & (IFF_BONDING | IFF_MASTER)) ==
>>	    (IFF_BONDING | IFF_MASTER))
>
>	This doesn't work because the flags are kept in different
>places, IFF_MASTER is in flags and IFF_BONDING in priv_flags.

Exactly - I'm going to send corrected patch very soon.

Jirka

>
>	-J
>
>>Which is less clear, I know, but used to generate better code.
>>The compiler might generate the same code these days.
>>Not that this is performance-critical or anything.
>>
>>> This would disable adding all bond devices (like bond0 etc) and allows
>>> to use enslaved physdevs.
>>>
>>> Note that checking for mode is irrelevant here. Mode could be easily
>>> changed later without fcoe knowing that.
>
>	This is also true.
>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
