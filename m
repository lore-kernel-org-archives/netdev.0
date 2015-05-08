From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump via
 switchdev_port_obj ops.
Date: Fri, 8 May 2015 13:58:46 -0700
Message-ID: <CAE4R7bBVnC1aLerVR8r0-tpVwk6-P++RCRVKdEgpJDfsYX363g@mail.gmail.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>
	<554AA530.7000702@mojatatu.com>
	<554AED2F.80006@intel.com>
	<554CA674.8040905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33184 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167AbbEHU6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 16:58:47 -0400
Received: by qkx62 with SMTP id 62so56440955qkx.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 13:58:46 -0700 (PDT)
In-Reply-To: <554CA674.8040905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 5:05 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/07/15 00:42, Samudrala, Sridhar wrote:
>>
>>
>>
>> On 5/6/2015 4:35 PM, Jamal Hadi Salim wrote:
>>>
>>> On 05/06/15 17:54, Sridhar Samudrala wrote:
>
>
>>> So i raised this earlier. DaveM also chimed in - but it seems still
>>> in there.
>>> i havent been following the discussion and i may have missed
>>> the agreement to keep the new IDs. Could we not just have used netlink
>>>  IDs (as opposed to a new SWITCHDEV_OBJ_PORT_FDB id)?
>>
>>
>> I think you are referring to switch port attributes.  See Scott's
>> response here on
>> using netlink IDs for attributes.
>> http://thread.gmane.org/gmane.linux.network/357694/focus=357921
>>
>> This patch is adding 'fdb' as new switch port object.  It is similar to
>> other
>> objects like 'VLAN' and 'FIB' that are added by Scott's patches.
>
>
> Sorry I missed it - but I am not making sense of Scott's answer.
> The danger of adding these visible APIs is it would be too late
> to take them out once they hit the wild (Dave's famous "the horse
> has left the barn" or look at Jiri's netconf presentation). I hate
> to do this but taking longer to discuss these issues is important.
>
> I will agree that we need some common id to represent the grouping
> of the fdb entries - i will contend using netlink verb-nouns is
> sufficient. Example: RTM_NEWNEIGH is clearly refering to a
> modify or create on an fdb.
> The other issue is how to define optionality.
> So lets start with the fdb object:
> While i would agree they are common, Vlans are optional in an fdb
> entry. The only two items that must be present for an fdb entry are a
> dstmac address and an egress port.
> some low end switches dont do vlans. Therefore there are two IDs
> that must always be present:
>
> The object id for a port is the ifindex.
> The object id for a mac address is NDA_LLADDR
>
> The object id for a vlan is NDA_VLAN
> Then there are of course a gazillion other features which may
> be one-of such as the fdb partition id in the netgear switch Ben was
> playing.
>
> I understand the earlier arguement of not needing to have
> multiple parsings of the same thing. But providing parseable
> options means never having to change what the object struct
> looks like. Just provide a scatter list of pointers to the
> different netlink attr-val pairs so it doesnt need to be
> re-parsed.
>
> Otherwise we are re-inventing things and start to look like
> vendor SDKs.

Bottom line is netlink is not great for in-kernel driver APIs.  Look
at the fdb and bridge_set/get/dellink ndo ops in netdevice.h to see
what kind of horse already left the barn.  It's a swayback nag blind
in one eye and deaf in the other eye.  The problems are:

1) Inconsistent call arguments, some strange mix of parsed and raw
netlink attrs.  This make it impossible to provide generic wrappers to
handle higher-level operations such as the prepare-commit transaction
model.

2) Netlink attr parsing/policy checks are now split/duplicated between
core code and driver code.  Parsing/policy checks should be done in
one place: the core code.

3) Driver dumps ops duplicate the netlink skb building (see recent
patch to fix MULTI flag usage and how it touched every driver).  This
skb building should be in core code, not in each driver.

4) netlink-based APIs are hard to call from kernel context where no
netlink msgs exists.  For example, consider the task of flushing FDBs
from the device.  Today, we'd need to synthesis netlink message to
call into ndo_fdb_del to delete the FDB entry.

5) In some cases, there is a lot of processing done on the netlink msg
before the call into the driver, and we don't want to duplicate all of
that processing again in each driver.  For example, consider the IPv4
fib API.  A netlink msg originates the call into the driver, but the
actual arguments of the call into the driver are packaged quite
differently than the originating netlink msg.   This call to the
driver is made inline deep down in the logic of fib processing.

6) There are some switchdev attrs that don't originate as netlink
msgs.  Example is STP state.  That's an internal call from the bridge
driver.

Don't get me wrong: I love netlink for user-space/kernel APIs.  But
for in-kernel APIs it's awkward and we want a clean API for switchdev.

-scott
