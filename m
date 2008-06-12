From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Thu, 12 Jun 2008 12:41:12 +0200
Message-ID: <4850FD48.8050309@trash.net>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net> <484AA5D5.10404@trash.net> <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl> <484E4343.5090606@trash.net> <20080611154520.GA9384@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Krzysztof Oledzki <ole@ans.pl>,
	Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36009 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756313AbYFLKlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:41:42 -0400
In-Reply-To: <20080611154520.GA9384@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:
> On Tue, Jun 10, 2008 at 11:02:59AM +0200, Patrick McHardy wrote:
>> Possibly fixes https://bugzilla.redhat.com/show_bug.cgi?id=449315
>> and/or http://bugzilla.kernel.org/show_bug.cgi?id=10875
> 
> One question and one nit below.
> 
>> @@ -570,8 +569,8 @@ static void nf_nat_move_storage(void *new, void *old)
>>  		return;
>>
>>  	spin_lock_bh(&nf_nat_lock);
>> -	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
>>  	new_nat->ct = ct;
>> +	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
> 
> The intent is to ensure that new_nat->ct is initialized before any
> readers can find new_nat, right?  If so, OK.

Correct. Its relying on the smb_wmb() in hlist_replace_rcu(),
but that seems OK.

>> diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
>> index bcc19fa..8a3f8b3 100644
>> --- a/net/netfilter/nf_conntrack_extend.c
>> +++ b/net/netfilter/nf_conntrack_extend.c
>> @@ -59,12 +59,19 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
>>  	if (!*ext)
>>  		return NULL;
>>
>> +	INIT_RCU_HEAD(&(*ext)->rcu);
> 
> Nit: the above is unnecessary.

I think its good style to use explicit initializers without
making assumptions about what exactly they do.

Thanks for the review.

