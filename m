From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 10/10] mlxsw: spectrum_router: Don't abort on
 l3mdev rules
Date: Mon, 13 Mar 2017 09:37:19 -0600
Message-ID: <767ac543-e089-56f7-a94e-e8627e57c14b@cumulusnetworks.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-10-git-send-email-jiri@resnulli.us>
 <7ba7c3ca-f9ba-0ee1-7b56-f139bc4e1fc4@cumulusnetworks.com>
 <20170313152225.GA8034@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34430 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdCMPhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:37:21 -0400
Received: by mail-pf0-f169.google.com with SMTP id v190so70658182pfb.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:37:20 -0700 (PDT)
In-Reply-To: <20170313152225.GA8034@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 9:22 AM, Ido Schimmel wrote:
> On Mon, Mar 13, 2017 at 08:59:11AM -0600, David Ahern wrote:
>> On 3/13/17 1:38 AM, Jiri Pirko wrote:
>>> From: Ido Schimmel <idosch@mellanox.com>
>>>
>>> Now that port netdevs can be enslaved to a VRF master we need to make
>>> sure the device's routing tables won't be flushed upon the insertion of
>>> a l3mdev rule.
>>>
>>> Note that we assume the notified l3mdev rule is a simple rule as used by
>>> the VRF master. We don't check for the presence of other selectors such
>>> as 'iif' and 'oif'.
>>>
>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>>> index de54382..fa73ee2 100644
>>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>>> @@ -2552,7 +2552,8 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
>>>  		break;
>>>  	case FIB_EVENT_RULE_ADD: /* fall through */
>>>  	case FIB_EVENT_RULE_DEL:
>>> -		if (!fib_work->fr_info.rule->def)
>>> +		if (!fib_work->fr_info.rule->def &&
>>> +		    !fib_work->fr_info.rule->l3mdev)
>>>  			mlxsw_sp_router_fib4_abort(mlxsw_sp);
>>>  		fib_rule_put(fib_work->fr_info.rule);
>>>  		break;
>>>
>>
>> You do not want to abort if the default rules are re-ordered. For
>> example, the rule for the local table is moved from priority 0 to just
>> before the main. ie., from this order:
> 
> Are you aware of configurations employing the VRF device and leaving the
> rule for the local table at priority 0?

There is no explicit requirement to re-order, but as I mentioned in one
of the switchdev calls you can get false hits on the local table when
the lookup really should have gone to the VRF table. IMO, best practice
for VRF is to move the the local table rule after the l3mdev / per-VRF
FIB rules.
