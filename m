From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 1/3] lwtunnel: autoload of lwt modules
Date: Mon, 15 Feb 2016 16:22:08 +0000
Message-ID: <56C1FB30.8090005@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
 <1455550923-23673-2-git-send-email-rshearma@brocade.com>
 <20160215170232.5f73b111@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:20006 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751088AbcBOQWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 11:22:25 -0500
In-Reply-To: <20160215170232.5f73b111@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/16 16:02, Jiri Benc wrote:
> On Mon, 15 Feb 2016 15:42:01 +0000, Robert Shearman wrote:
>> +static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
>> +{
>> +	switch (encap_type) {
>> +	case LWTUNNEL_ENCAP_MPLS:
>> +		return "LWTUNNEL_ENCAP_MPLS";
>> +	case LWTUNNEL_ENCAP_IP:
>> +		return "LWTUNNEL_ENCAP_IP";
>> +	case LWTUNNEL_ENCAP_ILA:
>> +		return "LWTUNNEL_ENCAP_ILA";
>> +	case LWTUNNEL_ENCAP_IP6:
>> +		return "LWTUNNEL_ENCAP_IP6";
>> +	case LWTUNNEL_ENCAP_NONE:
>> +	case __LWTUNNEL_ENCAP_MAX:
>> +		/* should not have got here */
>> +		break;
>> +	}
>> +	WARN_ON(1);
>> +	return "LWTUNNEL_ENCAP_NONE";
>> +}
>> +
>> +#endif /* CONFIG_MODULES */
>> +
>>   struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
>>   {
>>   	struct lwtunnel_state *lws;
>> @@ -85,6 +109,14 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
>>   	ret = -EOPNOTSUPP;
>>   	rcu_read_lock();
>>   	ops = rcu_dereference(lwtun_encaps[encap_type]);
>> +#ifdef CONFIG_MODULES
>> +	if (!ops) {
>> +		rcu_read_unlock();
>> +		request_module("rtnl-lwt-%s", lwtunnel_encap_str(encap_type));
>
> Why the repeating of "lwt"/"LWTUNNEL" and the unnecessary "ENCAP"?
> Wouldn't be lwtunnel_encap_str returning just "MPLS" or "ILA" enough?
> I don't have any strong preference here, it just looks weird to me.
> Maybe there's a reason.

Yeah, it's the C preprocessor. MODULE_ALIAS_RTNL_LWT includes the string 
for the encap type in the module alias, and since the LWT encap types 
are defined as enums this is symbolic name. I can't see any way of 
getting the preprocessor to convert 
MODULE_ALIAS_RTNL_LWT(LWTUNNEL_ENCAP_MPLS) into "rtnl-lwt-MPLS", but I'm 
open to suggestions.

I could just drop the "lwt-" bit of the alias string given that it's 
included in the name of the enum values.

> Also, this doesn't affect IP lwtunnels, i.e. LWTUNNEL_ENCAP_IP and
> LWTUNNEL_ENCAP_IP6. Should we just return NULL from lwtunnel_encap_str
> in such cases (plus unknown encap_type) and WARN on the NULL here?

True, but I figured that it was cleaner for the lwtunnel infra to not 
assume whether how those modules are implemented. If you disagree, then 
I can change to doing as you suggest.

Thanks,
Rob
