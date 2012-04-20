From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next 01/19] net: Implement register_net_sysctl.
Date: Fri, 20 Apr 2012 12:45:07 +0400
Message-ID: <4F912213.8050507@parallels.com>
References: <m1aa27ia6h.fsf@fess.ebiederm.org> <m162cvia3s.fsf@fess.ebiederm.org> <4F90F3AB.7050600@parallels.com> <m1obqmakl4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29542 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128Ab2DTIp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 04:45:29 -0400
In-Reply-To: <m1obqmakl4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2012 12:11 PM, Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
>>> @@ -117,6 +117,13 @@ struct ctl_table_header *register_net_sysctl_rotable(const
>>>  }
>>>  EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
>>>  
>>> +struct ctl_table_header *register_net_sysctl(struct net *net,
>>> +	const char *path, struct ctl_table *table)
>>> +{
>>> +	return __register_sysctl_table(&net->sysctls, path, table);
>>
>> Eric, am I right, that after this all sysctl-s registered in init_net will
>> not be even visible in the non-init net namespaces?
> 
> Yes.
> 
>> If I'm not mistaken, before this all non-virtualized, i.e. "global" sysctls
>> were read-only in sub net namespaces and that solved lots of problems for us.
> 
> Nope.  There are only 4 sysctls that were both global and read only, and
> coincidentally I shoved them all into the initial network namespace in
> patch 4.

OK, thanks.

> So this part of the discussion really belongs about patch 4 but whatever.
> 
> In principle I don't mind the technique of sysctls that are writable
> in the initial network namespace and readable everywhere else.  I hate
> the name register_net_sysctl_rotable because it suggests that every
> sysctl in the table will all be read-only or something like that.
> 
> In practice I think where we are at with converting and looking at
> sysctls is disaster.
> 
> - People complain and want bad hacks so they can avoid writing to
>   sysctls in containers but don't seem to work on the clean solutions.
> 
> - It is not discoverable which sysctls are per network namespace.
> 
> - We have only made a grand total 4 sysctls (in 3 tables) writable
>   in the initial network namespace readable everywhere else.
> 
> So I think the best path forward is to just shove all sysctls that
> aren't per network namespace into the initial network namespace so that
> it is abundantly clear that they are not per network namespace, and
> the fix the sysctls that people care about to be per network namespace.

Agree.

> I do admit their is actual interest in fixing some of the non-converted
> netfliter sysctls.  So my perception of the situation may be wrong, but
> right now I honestly think we have been too clever and no one knows what
> is going on or cares enough to pay detailed attention.

We constantly see two types of problems with proc files and sysctls.
Various apps fail to work if they cannot do either of two

1. find some sysctl without trying to do anything with it
2. write to some sysctl without checking for the actual result

I don't see the ways of fixing any of the above in the generic way. However
step #1 can be ... work-around-ed by making all non-virtualized sysctls RO
in containers, but this is also not a perfect solution.

> Eric
> 
> .
> 
