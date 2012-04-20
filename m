From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 01/19] net: Implement register_net_sysctl.
Date: Fri, 20 Apr 2012 01:11:51 -0700
Message-ID: <m1obqmakl4.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
	<m162cvia3s.fsf@fess.ebiederm.org> <4F90F3AB.7050600@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo\@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39192 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab2DTIHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 04:07:54 -0400
In-Reply-To: <4F90F3AB.7050600@parallels.com> (Pavel Emelyanov's message of
	"Fri, 20 Apr 2012 09:27:07 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@parallels.com> writes:

>> @@ -117,6 +117,13 @@ struct ctl_table_header *register_net_sysctl_rotable(const
>>  }
>>  EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
>>  
>> +struct ctl_table_header *register_net_sysctl(struct net *net,
>> +	const char *path, struct ctl_table *table)
>> +{
>> +	return __register_sysctl_table(&net->sysctls, path, table);
>
> Eric, am I right, that after this all sysctl-s registered in init_net will
> not be even visible in the non-init net namespaces?

Yes.

> If I'm not mistaken, before this all non-virtualized, i.e. "global" sysctls
> were read-only in sub net namespaces and that solved lots of problems for us.

Nope.  There are only 4 sysctls that were both global and read only, and
coincidentally I shoved them all into the initial network namespace in
patch 4.

So this part of the discussion really belongs about patch 4 but whatever.

In principle I don't mind the technique of sysctls that are writable
in the initial network namespace and readable everywhere else.  I hate
the name register_net_sysctl_rotable because it suggests that every
sysctl in the table will all be read-only or something like that.

In practice I think where we are at with converting and looking at
sysctls is disaster.

- People complain and want bad hacks so they can avoid writing to
  sysctls in containers but don't seem to work on the clean solutions.

- It is not discoverable which sysctls are per network namespace.

- We have only made a grand total 4 sysctls (in 3 tables) writable
  in the initial network namespace readable everywhere else.

So I think the best path forward is to just shove all sysctls that
aren't per network namespace into the initial network namespace so that
it is abundantly clear that they are not per network namespace, and
the fix the sysctls that people care about to be per network namespace.

I do admit their is actual interest in fixing some of the non-converted
netfliter sysctls.  So my perception of the situation may be wrong, but
right now I honestly think we have been too clever and no one knows what
is going on or cares enough to pay detailed attention.

Eric
