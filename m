From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: ipv6: add tokenized interface identifier
 support
Date: Thu, 04 Apr 2013 18:48:45 +0200
Message-ID: <515DAEED.1010605@redhat.com>
References: <1365086258-4512-1-git-send-email-dborkman@redhat.com> <1365086258-4512-2-git-send-email-dborkman@redhat.com> <515DAA6E.1050407@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762906Ab3DDQsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 12:48:53 -0400
In-Reply-To: <515DAA6E.1050407@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2013 06:29 PM, YOSHIFUJI Hideaki wrote:
> Daniel Borkmann wrote:
>> This patch adds support for tokenized IIDs, that allow for
>> administrators to assign well-known host-part addresses to
>> nodes whilst still obtaining global network prefix from
>> Router Advertisements. It is currently in IETF RFC draft
>> status [1]:
>>
>>    The primary target for such support is server platforms
>>    where addresses are usually manually configured, rather
>>    than using DHCPv6 or SLAAC. By using tokenised identifiers,
>>    hosts can still determine their network prefix by use of
>>    SLAAC, but more readily be automatically renumbered should
>>    their network prefix change.
>>
>>   [1] http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02
>>
>> The implementation is partially based on top of Mark K.
>> Thompson's proof of concept. Successfully tested by myself.
>>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
[...]
>>   		if (pinfo->prefix_len == 64) {
>>   			memcpy(&addr, &pinfo->prefix, 8);
>> -			if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
>> -			    ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
>> +
>> +			if (!ipv6_addr_any(&in6_dev->token)) {
>> +				read_lock_bh(&in6_dev->lock);
>> +				memcpy(addr.s6_addr + 8,
>> +				       in6_dev->token.s6_addr + 8, 8);
>> +				read_unlock_bh(&in6_dev->lock);
>> +			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
>> +				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
>>   				in6_dev_put(in6_dev);
>>   				return;
>>   			}
> 
> Why not initialize token by interface-identifier and then allow
> users to "override"?

Sure this would simplify this part above ...

... maybe I'm wrong, but then, probably, if someone changes the netdev's
hw address during runtime, we could not keep track of that anymore as
dynamically done in e.g. ipv6_generate_eui64(), since we've already done
the token init at an earlier point in time, no?

With the current patch, we would have a clear separation of both concepts
like ``either you use token iids, or you don't''.
