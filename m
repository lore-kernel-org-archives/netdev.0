From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 2/4] fib_trie: Replace plen with slen in leaf_info
Date: Wed, 25 Feb 2015 13:30:44 -0800
Message-ID: <54EE3F04.2000703@redhat.com>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190610.1747.3307.stgit@ahduyck-vm-fedora20> <alpine.LFD.2.11.1502252158580.2970@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755AbbBYVa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 16:30:56 -0500
In-Reply-To: <alpine.LFD.2.11.1502252158580.2970@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/25/2015 01:15 PM, Julian Anastasov wrote:
> 	Hello,
>
> On Wed, 25 Feb 2015, Alexander Duyck wrote:
>
>>   	hlist_for_each_entry_rcu(li, &n->list, hlist) {
>>   		struct fib_alias *fa;
>>   
>> -		if ((key ^ n->key) & li->mask_plen)
>> +		if (((key ^ n->key) >> li->slen) &&
>> +		    ((BITS_PER_LONG > KEYLENGTH) || (li->slen != KEYLENGTH)))
>>   			continue;
> 	The '(BITS_PER_LONG > KEYLENGTH) ||' part is not
> needed because on 64-bit processor we can still use
> 32-bit register (due to 32-bit t_key type) and to get
> undefined (!0) result from rshift with 32. We do not want
> to continue in this case. Is it really working on 64-bit for
> 0.0.0.0/0 ?
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

It is working but that may be due to the fact that gcc decided to place 
the key in a 64b register.

The last patch in the series probably does a better job of addressing 
your concern.  It replaces the shift with a comparison to (1ul << 
fa->fa_slen).  In that case I believe the BITS_PER_LONG check would then 
be appropriate would it not?

- Alex
