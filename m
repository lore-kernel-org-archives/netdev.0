From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/4] net: add IPv4 routing FIB support for
 switchdev
Date: Mon, 02 Mar 2015 11:24:46 -0800
Message-ID: <54F4B8FE.2080903@cumulusnetworks.com>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com> <1425290777-22702-3-git-send-email-sfeldma@gmail.com> <54F4741F.50406@cumulusnetworks.com> <CAE4R7bCdpu+fUZdPJJkNMhxLBBdecdVF9hZFbooKhCWwWL-oXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35537 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbbCBTYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:24:47 -0500
Received: by pabli10 with SMTP id li10so16837677pab.2
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:24:47 -0800 (PST)
In-Reply-To: <CAE4R7bCdpu+fUZdPJJkNMhxLBBdecdVF9hZFbooKhCWwWL-oXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/15, 9:10 AM, Scott Feldman wrote:
> On Mon, Mar 2, 2015 at 6:30 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>    +                     err = netdev_switch_fib_ipv4_add(key, plen, fi,
>>> +                                                        new_fa->fa_tos,
>>> +                                                        cfg->fc_type,
>>> +                                                        tb->tb_id);
>>> +                       if (err && err != -EOPNOTSUPP) {
>>> +                               kmem_cache_free(fn_alias_kmem, new_fa);
>>> +                               goto out;
>>> +                       }
>>> +
>>>                          hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
>>> +
>>>                          alias_free_mem_rcu(fa);
>>>                          fib_release_info(fi_drop);
>>
>> This looks like the replace case: It will need a netdev_switch_fib_ipv4_del
>> for fi_drop ?
> It is the replace case.  No del needed.  Failure to replace in HW
> results in replace not proceeding in SW and err return to user.  So HW
> and SW stay coherent and user can react to failure case.
sure, If your driver can handle it. Am not sure if always doing a 
replace in hw
will work best in all cases. I cant think of a definite testcase right now.

AFAICT it becomes necessary to indicate a replace
for sure in the IPv6 multipath case.

>
>>> @@ -1197,12 +1208,18 @@ int fib_table_insert(struct fib_table *tb, struct
>>> fib_config *cfg)
>>>          new_fa->fa_state = 0;
>>>          new_fa->fa_slen = slen;
>>>    +     /* (Optionally) offload fib entry to switch hardware. */
>>> +       err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
>>> +                                        cfg->fc_type, tb->tb_id);
>>
>> This could be an NLM_F_APPEND case. Would be better for the switchdev API to
>> also take
>> nlflags as argument, to inform the switch driver of replace and append
>> cases.
> No, we can keep it simple.  The ndo add op is used for adds or mods.
> The driver/device will know if operation is a mod vs. add if object
> exists (it's an add if object doesn't exist).

Again, this will become apparent in the ipv6 multipath route case when 
you come to it.
The append flag is required to insert at tail.

Thanks,
Roopa
