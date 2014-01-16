From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH-next v2] netfilter: don't use module_init/exit in core
 IPV4 code
Date: Thu, 16 Jan 2014 14:38:10 -0500
Message-ID: <52D83522.9070902@windriver.com>
References: <1389638147-30399-1-git-send-email-paul.gortmaker@windriver.com> <1389819427-20199-1-git-send-email-paul.gortmaker@windriver.com> <20140116192613.GA23133@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41908 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbaAPTiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:38:07 -0500
In-Reply-To: <20140116192613.GA23133@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-16 02:26 PM, Benjamin Poirier wrote:
> On 2014/01/15 15:57, Paul Gortmaker wrote:
>> The file net/ipv4/netfilter.o is created based on whether
>> CONFIG_NETFILTER is set.  However that is defined as a bool, and
>> hence this file with the core netfilter hooks will never be
>> modular.  So using module_init as an alias for __initcall can be
>> somewhat misleading.
>>
>> Fix this up now, so that we can relocate module_init from
>> init.h into module.h in the future.  If we don't do this, we'd
>> have to add module.h to obviously non-modular code, and that
>> would be a worse thing.  Also add an inclusion of init.h, as
>> that was previously implicit here in the netfilter.c file.
>>
>> Note that direct use of __initcall is discouraged, vs. one
>> of the priority categorized subgroups.  As __initcall gets
>> mapped onto device_initcall, our use of subsys_initcall (which
>> seems to make sense for netfilter code) will thus change this
>> registration from level 6-device to level 4-subsys (i.e. slightly
>> earlier).  However no observable impact of that small difference
>> has been observed during testing, or is expected. (i.e. the
>> location of the netfilter messages in dmesg remains unchanged
>> with respect to all the other surrounding messages.)
>>
>> As for the module_exit, rather than replace it with __exitcall,
>> we simply remove it, since it appears only UML does anything
>> with those, and even for UML, there is no relevant cleanup
>> to be done here.
>>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> ---
>>
>> [v2: Drop __exitcall stuff completely, as per Eric's suggestion
>>  given for patch at  http://patchwork.ozlabs.org/patch/311164/ ]
>>
>>  net/ipv4/netfilter.c | 9 +--------
>>  1 file changed, 1 insertion(+), 8 deletions(-)
>>
>> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
>> index c3e0adea9c27..31abf9636ba7 100644
>> --- a/net/ipv4/netfilter.c
>> +++ b/net/ipv4/netfilter.c
>> @@ -197,11 +197,4 @@ static int __init ipv4_netfilter_init(void)
>>  {
>>  	return nf_register_afinfo(&nf_ip_afinfo);
>>  }
>> -
>> -static void __exit ipv4_netfilter_fini(void)
>> -{
>> -	nf_unregister_afinfo(&nf_ip_afinfo);
>> -}
>> -
>> -module_init(ipv4_netfilter_init);
>> -module_exit(ipv4_netfilter_fini);
>> +device_initcall(ipv4_netfilter_init);
> 
> device_ vs. subsys_initcall changed from v1 of the patch and no longer
> matches the description I think.

Thanks for spotting that ; not sure how I fat fingered that
during the exitcall removal.  Trying to rush things I guess.

P.
--

> 
>> -- 
>> 1.8.5.2
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
