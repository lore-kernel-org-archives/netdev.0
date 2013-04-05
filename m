From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: remove sysfs before removing devices
Date: Sat, 06 Apr 2013 01:29:48 +0200
Message-ID: <515F5E6C.2030009@redhat.com>
References: <1365003993-13181-1-git-send-email-vfalico@redhat.com> <515F4CEF.3030207@redhat.com> <20130405232133.GA19437@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760311Ab3DEXci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 19:32:38 -0400
In-Reply-To: <20130405232133.GA19437@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2013 01:21 AM, Veaceslav Falico wrote:
> On Sat, Apr 06, 2013 at 12:15:11AM +0200, Nikolay Aleksandrov wrote:
>> Hi,
>> Sorry for the late reply but I was travelling this week. In my
>> opinion this
>> fix is wrong because in bond_uninit() (called by rtnl_link_unregister)
>> you have:
>> list_del(&bond->bond_list);
>> which is linked in the bond_net dev_list which is freed by
>> unregister_pernet_subsys.
>
> Yep, you're right, I've hit it recently with the patch applied, and now
> working on it. However, I still think that the idea of the patch is
> correct
> - i.e. to first disable sysfs (especially bonding_masters) and only
>  afterwards to start removing everything else. Or, obviously, to finally
> add normal locking to sysfs functions.
>
> Anyway, this corruption is really rare, so I'll wait for your fix next
> week.
>
Well, there's no need for that because you'll have to iterate over all
"net"s to do it properly. Since we already have code that does it
(unregister_pernet_subsys), my fix is to kill off any "left" bond
devices in bond_net_exit() _after_ destroying the bonding_masters
sysfs entry for that net. This way we preserve the code structure and avoid
duplicating a loop over all nets.
This is the fix we discussed a week ago.
I'd be happy to hear any comments on it before posting :-)

Of course stopping the whole bonding sysfs handling is also an alternative.
