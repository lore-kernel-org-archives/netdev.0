From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 2/4] net: add IPv4 routing FIB support for switchdev
Date: Mon, 2 Mar 2015 09:10:28 -0800
Message-ID: <CAE4R7bCdpu+fUZdPJJkNMhxLBBdecdVF9hZFbooKhCWwWL-oXw@mail.gmail.com>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com>
	<1425290777-22702-3-git-send-email-sfeldma@gmail.com>
	<54F4741F.50406@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:35880 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098AbbCBRK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:10:28 -0500
Received: by qcxn11 with SMTP id n11so3608157qcx.3
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 09:10:28 -0800 (PST)
In-Reply-To: <54F4741F.50406@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 6:30 AM, roopa <roopa@cumulusnetworks.com> wrote:
> On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>   +                     err = netdev_switch_fib_ipv4_add(key, plen, fi,
>> +                                                        new_fa->fa_tos,
>> +                                                        cfg->fc_type,
>> +                                                        tb->tb_id);
>> +                       if (err && err != -EOPNOTSUPP) {
>> +                               kmem_cache_free(fn_alias_kmem, new_fa);
>> +                               goto out;
>> +                       }
>> +
>>                         hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
>> +
>>                         alias_free_mem_rcu(fa);
>>                         fib_release_info(fi_drop);
>
>
> This looks like the replace case: It will need a netdev_switch_fib_ipv4_del
> for fi_drop ?

It is the replace case.  No del needed.  Failure to replace in HW
results in replace not proceeding in SW and err return to user.  So HW
and SW stay coherent and user can react to failure case.

>>
>> @@ -1197,12 +1208,18 @@ int fib_table_insert(struct fib_table *tb, struct
>> fib_config *cfg)
>>         new_fa->fa_state = 0;
>>         new_fa->fa_slen = slen;
>>   +     /* (Optionally) offload fib entry to switch hardware. */
>> +       err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
>> +                                        cfg->fc_type, tb->tb_id);
>
>
> This could be an NLM_F_APPEND case. Would be better for the switchdev API to
> also take
> nlflags as argument, to inform the switch driver of replace and append
> cases.

No, we can keep it simple.  The ndo add op is used for adds or mods.
The driver/device will know if operation is a mod vs. add if object
exists (it's an add if object doesn't exist).

>> +       /* Recusively search from fib_dev down until we find
>> +        * a sw port dev.  (A sw port dev supports
>> +        * ndo_switch_parent_id_get).
>> +        */
>> +
>> +       if (ops->ndo_switch_parent_id_get)
>> +               return dev;
>
>
> Maybe we can just check for NETIF_F_HW_SWITCH_OFFLOAD here ?
> similar to netdev_switch_port_bridge_newlink/dellink

Probably, yes.

-scott
