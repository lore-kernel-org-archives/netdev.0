From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH iptables 3/3] libxt_hashlimit: iptables-restore does not
 work as expected with xt_hashlimit
Date: Fri, 24 Jun 2016 14:24:18 -0400
Message-ID: <576D7AD2.6050107@akamai.com>
References: <20160602001759.GF1644@akamai.com> <20160623102511.GA10493@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:12029 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691AbcFXSYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 14:24:20 -0400
In-Reply-To: <20160623102511.GA10493@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2016 06:25 AM, Pablo Neira Ayuso wrote:
> On Wed, Jun 01, 2016 at 08:17:59PM -0400, Vishwanath Pai wrote:
>> libxt_hashlimit: iptables-restore does not work as expected with xt_hashlimit
>>
>> Add the following iptables rule.
>>
>> $ iptables -A INPUT -m hashlimit --hashlimit-above 200/sec \
>>   --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name hashlimit1 \
>>   --hashlimit-htable-expire 30000 -j DROP
>>
>> $ iptables-save > save.txt
>>
>> Edit save.txt and change the value of --hashlimit-above to 300:
>>
>> -A INPUT -m hashlimit --hashlimit-above 300/sec --hashlimit-burst 5 \
>> --hashlimit-mode srcip --hashlimit-name hashlimit2 \
>> --hashlimit-htable-expire 30000 -j DROP
>>
>> Now restore save.txt
>>
>> $ iptables-restore < save.txt
> 
> In this case, we don't end up with two rules, we actually get one
> single hashlimit rule, given the sequence you provide.
> 
>         $ iptables-save > save.txt
>         ... edit save.txt
>         $ iptables-restore < save.txt
> 

Yes, we end up with just one rule, but the kernel data structure is not
updated. Userspace thinks the value is 300/s but in the kernel it is
still 200/s.

>> Now userspace thinks that the value of --hashlimit-above is 300 but it is
>> actually 200 in the kernel. This happens because when we add multiple
>> hash-limit rules with the same name they will share the same hashtable
>> internally. The kernel module tries to re-use the old hashtable without
>> updating the values.
>>
>> There are multiple problems here:
>> 1) We can add two iptables rules with the same name, but kernel does not
>>    handle this well, one procfs file cannot work with two rules
>> 2) If the second rule has no effect because the hashtable has values from
>>    rule 1
>> 3) hashtable-restore does not work (as described above)
>>
>> To fix this I have made the following design change:
>> 1) If a second rule is added with the same name as an existing rule,
>>    append a number when we create the procfs, for example hashlimit_1,
>>    hashlimit_2 etc
>> 2) Two rules will not share the same hashtable unless they are similar in
>>    every possible way
>> 3) This behavior has to be forced with a new userspace flag:
>>    --hashlimit-ehanced-procfs, if this flag is not passed we default to
>>    the old behavior. This is to make sure we do not break existing scripts
>>    that rely on the existing behavior.
> 
> We discussed this in netdev0.1, and I think we agreed on adding a new
> option, something like --hashlimit-update that would force an update
> to the existing hashlimit internal state (that is identified by the
> hashlimit name).
> 
> I think the problem here is that you may want to update the internal
> state of an existing hashlimit object, and currently this is not
> actually happening.
> 
> With the explicit --hashlimit-update flag, from the kernel we really
> know that the user wants an update.
> 
> Let me know, thanks.
> 

Yes, I believe you had a discussion about this with Josh Hunt. This
patch does add a new option, but it is called -enhanced-procfs instead.
I am open to renaming this to something else. I chose this name because
this patch will affect the names of the procfs files when multiple rules
with the same name exist. This generally does not happen, but is a side
effect of the way we create these files. In the case of restore example
above - we get the call to "hashlimit_mt_check" for the new rule before
the old rule is deleted, so there is a short window where we have two
rules in the kernel with the same name.

Other than that, we are doing exactly what you said, but creating a new
entry in the hashtable instead of updating it. The previous entry will
automatically be removed when the old rule is flushed/deleted.

Users will see this new behavior only if the new option is passed,
otherwise we default to the old behavior. We are also doing this in rev2
so old userspace tools will not be affected.

Thanks,
Vishwanath
