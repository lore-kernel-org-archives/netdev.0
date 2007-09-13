From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] veth: Cleanly handle a missing peer_tb argument on creation.
Date: Thu, 13 Sep 2007 10:06:36 +0400
Message-ID: <46E8D36C.3080100@openvz.org>
References: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>	<46E7F466.1060704@openvz.org>	<m1odg89byw.fsf@ebiederm.dsl.xmission.com>	<46E7FC64.5030604@openvz.org> <m1ejh3aosm.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53160 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755238AbXIMGJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 02:09:15 -0400
In-Reply-To: <m1ejh3aosm.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>> Eric W. Biederman wrote:
>>> Pavel Emelyanov <xemul@openvz.org> writes:
>>>
>>>>> +	}
>>>>>  
>>>>> -		tbp = peer_tb;
>>>>> -	} else
>>>>> -		tbp = tb;
>>>> The intention of this part was to get the same parameters for
>>>> peer as for the first device if no "peer" argument was specified
>>>> for ip utility. Does it still work?
>>> I know it is problematic because we try to assign the same name
>>> to both network devices, if we assign a name to the primary
>>> network device.  That can't work.
>> This can - as you can see I reallocate the name lower.
> 
> Hmm. I just see:
> 	if (tbp[IFLA_IFNAME])
> 		nla_strlcpy(ifname, tbp[IFLA_IFNAME], IFNAMSIZ);
> 
> Then lower I see:
> 	if (tb[IFLA_IFNAME])
> 		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
> 
> If (tb == tbp) then dev->name == ifname
> Unless I'm completely misreading that code.

There must be a
        if (strchr(dev->name, '%')) {
                err = dev_alloc_name(dev, dev->name);
                if (err < 0)
                        goto err_alloc_name;
        }
code just before registering the first device.

>>> Beyond that I had some really weird crashes while testing this
>>> piece of code, especially when I did not specify a peer parameter.
>> Can you please give me the exact command that caused an oops.
>> I try simple ip link add type veth and everything is just fine.
> 
> It might have been 64bit specific. 

Maybe. I will try on x86_64.

> What I have in my history is:
> ./ip/ip link add veth23 type veth
> 
> I forget exactly how it failed but as I recall it wasn't as
> nice as an oops.  My memory may be a bit foggy though.
> 
> If I haven't provided a bit enough clue I guess I can go back
> and remove the patch and try to reproduce the failure again.

That would be nice. Thanks.

>>> So it was just easier to avoid the problem with this patch then
>>> to completely root cause it.
>> Let me handle this problem. AFAIR this was one of wishes from 
>> Patrick that we make two equal devices in case peer is not given, 
>> not just the default peer.
> 
> Ok.  I have if we can track down the weird cases I have no problem
> if we handle this.  I think it still might be simpler if just
> copy tb onto peer_tb instead of using tbp.

Well, maybe, but what to copy some region aside if we can use it
as is.

> Eric
> 

