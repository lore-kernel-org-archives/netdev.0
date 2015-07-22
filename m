From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 22 Jul 2015 12:30:19 -0700
Message-ID: <55AFEF4B.6070702@cumulusnetworks.com>
References: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com> <20150722122309.GB968@pox.localdomain> <20150722.104926.1502608671575195516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33527 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbGVTaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 15:30:22 -0400
Received: by pdbnt7 with SMTP id nt7so72436315pdb.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 12:30:21 -0700 (PDT)
In-Reply-To: <20150722.104926.1502608671575195516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/15, 10:49 AM, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 22 Jul 2015 14:23:09 +0200
>
>> On 07/22/15 at 12:10am, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> seen with CONFIG_IPV6 disabled. Wrap the code
>>> around IS_ENABLED(CONFIG_IPV6)
>>>
>>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> We need the same for CONFIG_INET=n in inet_fib_lookup_dev:
>>
>> /home/tgraf/dev/linux/net-next/include/net/route.h:122: undefined reference to `ip_route_output_flow'
>>
>> Is it worth returning EAFNOSUPPORT instead of ENODEV in these
>> cases?  Something like this:
>>
>>>   }
>>> +#else
>>> +static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
>>> +{
>>   +	return ERR_PTR(-EAFNOSUPPORT);
>>> +}
>>> +#endif
>> And then IS_ERR() in mpls_route_add()?
> Also IS_ENABLED() _DOES NOT_ work, what if MPLS is 'y' and IPV6 is 'm'?
>
> You can't reache the modular symbol from statically built code.
>
> What a mess.
>
Sorry about that, I was looking at other examples where this is done.
For ipvlan, CONFIG_IPVLAN depends on CONFIG_INET and CONFIG_INET6 and I
don't see any additional checks in the driver.
I am wondering if I should submit a patch that does the same for 
MPLS_ROUTING (I am trying to avoid that though).

diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index 5c467ef..2b28615 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -24,6 +24,8 @@ config NET_MPLS_GSO

  config MPLS_ROUTING
         tristate "MPLS: routing support"
+       depends on INET
+       depends on IPV6
         ---help---
          Add support for forwarding of mpls packets.


Or I will rework the original patch in a different way.
This was introduced by my below commit. Please revert the below commit 
if there is no easy way to make it work
with MPLS_ROUTING = 'y' and IPV6 = 'm'. I will resubmit the patch. Thanks.


commit 01faef2cebae02685e2bcfc9bbee8416d5ec19fc
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Tue Jul 21 09:16:24 2015 -0700

     mpls: make RTA_OIF optional

     If user did not specify an oif, try and get it from the via address.
     If failed to get device, return with -ENODEV.
