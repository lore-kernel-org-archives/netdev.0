From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 4/4] fib_trie: Remove leaf_info
Date: Wed, 25 Feb 2015 15:09:02 -0800
Message-ID: <54EE560E.8050504@redhat.com>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190625.1747.49993.stgit@ahduyck-vm-fedora20> <alpine.LFD.2.11.1502252341500.2970@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbbBYXJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 18:09:12 -0500
In-Reply-To: <alpine.LFD.2.11.1502252341500.2970@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/25/2015 02:29 PM, Julian Anastasov wrote:
> 	Hello,
>
> On Wed, 25 Feb 2015, Alexander Duyck wrote:
>
>> -static void insert_leaf_info(struct tnode *l, struct leaf_info *new)
>> +static void fib_insert_alias(struct tnode *l, struct fib_alias *fa,
>> +			     struct fib_alias *new)
>>   {
>> -	struct hlist_head *head = &l->list;
>> -	struct leaf_info *li, *last = NULL;
>> +	if (fa) {
>> +		hlist_add_before_rcu(&new->fa_list, &fa->fa_list);
>> +	} else {
>> +		struct fib_alias *last;
>>   
>> -	hlist_for_each_entry(li, head, hlist) {
>> -		if (new->slen < li->slen)
>> -			break;
>> -		last = li;
>> -	}
>> +		hlist_for_each_entry(last, &l->leaf, fa_list) {
>> +			if (new->fa_slen < last->fa_slen)
>> +				break;
> 	If there is some fa in list with higher fa_slen
> fib_find_alias will always stop the loop and come with
> fa != NULL, so above 'if...break' is not needed, we are
> always going to add at tail when fa is NULL.

Actually fib_find_alias will return NULL in the case that there was a 
hole in which the suffix length does not exist.

So for example if we have a suffix length of 8 and one of 10 and we are 
adding a suffix length of 9 then fib_find_alias will return NULL and we 
need to walk though the list and find the hole we are supposed to drop 
the suffix in.

>
>> +			fa = last;
>> +		}
>>   
>> -	if (last)
>> -		hlist_add_behind_rcu(&new->hlist, &last->hlist);
>> -	else
>> -		hlist_add_head_rcu(&new->hlist, head);
>> +		if (fa)
>> +			hlist_add_behind_rcu(&new->fa_list, &fa->fa_list);
>> +		else
>> +			hlist_add_head_rcu(&new->fa_list, &l->leaf);
>> +	}
>>   
>> @@ -1187,7 +1127,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>>   		fa_match = NULL;
>>   		fa_first = fa;
>>   		hlist_for_each_entry_from(fa, fa_list) {
>> -			if (fa->fa_tos != tos)
>> +			if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
> 	'fa->fa_slen == slen' check is also needed in the
> above 'if' that is not present in the patch:
>
> if (fa && fa->fa_slen == slen && fa->fa_tos == tos &&
>      fa->fa_info->fib_priority == fi->fib_priority) {
>
> 	Without such check we may wrongly enter the 'if'
> when fa->fa_slen > slen and to get some error, to
> replace the wrong fa or to append after it.

Actually we don't need it because fib_find_alias will return NULL if the 
slen value doesn't match.

>> +	hlist_for_each_entry_rcu(fa, &n->leaf, fa_list) {
>> +		struct fib_info *fi = fa->fa_info;
>> +		int nhsel, err;
>>   
>> -			if (((key ^ n->key) >> fa->fa_slen) &&
>> -			    ((BITS_PER_LONG > KEYLENGTH) ||
>> -			     (fa->fa_slen != KEYLENGTH)))
>> -				continue;
>> -			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
>> -				continue;
>> -			if (fi->fib_dead)
>> +		if (((key ^ n->key) >= (1ul << fa->fa_slen)) &&
>> +		    ((BITS_PER_LONG > KEYLENGTH) || (fa->fa_slen != KEYLENGTH)))
>>   				continue;
> 	lshift 32 for 32-bit int has the same side effects, so
> BITS_PER_LONG is not needed.

I'll submit a v2 just to clean up the first few patches so that they 
correctly use the 1ul w/ left shift instead of performing a right shift 
on the key value.

>
> 	Both left and right shift get same result on 64-bit:
>
> # ./a 32
> 7
> 7
>
> #include <stdio.h>
> #include <stdlib.h>
>
> int main (int argc, char *argv[])
> {
>          unsigned int a = 7;
>
>          printf("%u\n", a >> atoi(argv[1]));
>          printf("%u\n", a << atoi(argv[1]));
>          return 0;
> }
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

Why are you showing me an example with a 32b int when I am using a 
long?  For x86 a 32b shift on a 32b value is undefined so we need to 
compare the suffix length to the KEYLENGTH.  For 64b a long value can be 
shifted up to 63 bits and still be a defined value.  That is why I use 
"1ul" as the value being shifted and then also perform the check for 
KEYLENGTH vs BITS_PER_LONG in order to determine if I still need the 
check for fa_slen != KEYLENGTH.

- Alex
