From: Chris Snook <csnook@redhat.com>
Subject: Re: [RFC] per-nic module parameters
Date: Sat, 25 Oct 2008 07:06:23 -0400
Message-ID: <4902FDAF.5060305@redhat.com>
References: <49022B7F.8080809@myri.com> <20081024133920.6588026c@extreme> <20081024210128.GS7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Brice Goglin <brice@myri.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56414 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426AbYJYLHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2008 07:07:24 -0400
In-Reply-To: <20081024210128.GS7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Stephen Hemminger wrote:
>> On Fri, 24 Oct 2008 22:09:35 +0200
>> Brice Goglin <brice@myri.com> wrote:
>>
>>> Hello,
>>>
>>> We're working on making myri10ge module parameters per-nic. It looks
>>> like ixgb already does so with the following macro in ixgb_param.c:
>>>
>>> #define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
>>> #define IXGB_PARAM(X, desc)                                     \
>>>         static int __devinitdata X[IXGB_MAX_NIC+1]              \
>>>                 = IXGB_PARAM_INIT;                              \
>>>         static unsigned int num_##X = 0;                        \
>>>         module_param_array_named(X, X, int, &num_##X, 0);       \
>>>         MODULE_PARM_DESC(X, desc);
>>>
>>> Is this the recommended way to implement per-nic module params? Or
>>> should we do something else?
>> Module parameters are bad. They are device specific and awkward for
>> any general configuration system to deal with. As much as possible,
>> please convert any module parameters to real interfaces like netlink,
>> ethtool, or sysfs.
> 
> I agree in principle.  However, every distribution uses modutils and allows
> default module parameters to be set in the same way.  So it's easy to tell
> customers how to configure module parameters persistently.  The same cannot
> be said for ethtool, unfortunately.

That makes it a distribution problem, maybe something LSB should address.  ixgb 
inherits this code from e1000, which has been around a very, very long time. 
It's still a sin that they didn't strip it out when they derived ixgb from 
e1000, but it's a less severe sin than writing new module parameter code from 
scratch.

Sometimes there are legitimate reasons to use module parameters, but duplicating 
ethtool functionality doesn't qualify.  Those parameters that e1000 still 
carries are there because now that they've documented it and customers are using 
it, they can't ever remove it.  Telling your customers to use ETHTOOL_OPTS if 
their distro has /etc/sysconfig/network-scripts/ifcfg-eth* files, or pre-up if 
their distro has /etc/network/interfaces is not difficult.

Interface consistency is a worthwhile goal, but you're creating a bigger 
consistency problem in the kernel than you're solving in the distributions if 
you do this, and you make it very difficult to ever go back once you realize the 
mistake.

-- Chris
