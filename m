From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC PATCH 2/2] SCTP: Convert bind_addr_list locking to RCU
Date: Tue, 11 Sep 2007 10:56:09 -0400
Message-ID: <46E6AC89.8010508@hp.com>
References: <11894535901969-git-send-email-vladislav.yasevich@hp.com> <11894535912570-git-send-email-vladislav.yasevich@hp.com> <20070910220841.GK11801@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:43683 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbXIKO5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 10:57:10 -0400
In-Reply-To: <20070910220841.GK11801@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul

Thanks for review.  I'll leave out the comments about
the ->valid usage since there are the same as the first patch
in the series.

Other questions/responses below...

Paul E. McKenney wrote:
>>
>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>> index 7fc369f..9c7db1f 100644
>> --- a/net/sctp/bind_addr.c
>> +++ b/net/sctp/bind_addr.c
>> @@ -167,7 +167,10 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>>
>>  	INIT_LIST_HEAD(&addr->list);
>>  	INIT_RCU_HEAD(&addr->rcu);
>> -	list_add_tail(&addr->list, &bp->address_list);
>> +
>> +	rcu_read_lock();
>> +	list_add_tail_rcu(&addr->list, &bp->address_list);
>> +	rcu_read_unlock();
> 
> Given the original code, we presumably hold the update-side lock.  If so,
> the rcu_read_lock() and rcu_read_unlock() are (harmlessly) redundant.
> 

Yes, it this case, the writer would already hold the socket lock.  However, I was told during
private review that even writers need to be in rcu critical section.  Looking at the different
users of RCU, it seems there is no consistency, i.e. sometimes writers take the rcu_read_lock()
and sometimes the don't.

Is there a rule of when writer needs to be in rcu critical section?

>>  	SCTP_DBG_OBJCNT_INC(addr);
>>
>>  	return 0;
>> @@ -178,20 +181,23 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>>   */
>>  int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
>>  {
>> -	struct list_head *pos, *temp;
>> -	struct sctp_sockaddr_entry *addr;
>> +	struct sctp_sockaddr_entry *addr, *temp;
>>
>> -	list_for_each_safe(pos, temp, &bp->address_list) {
>> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
>> +	rcu_read_lock_bh();
>> +	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
>>  		if (sctp_cmp_addr_exact(&addr->a, del_addr)) {
>>  			/* Found the exact match. */
>> -			list_del(pos);
>> -			kfree(addr);
>> -			SCTP_DBG_OBJCNT_DEC(addr);
>> -
>> -			return 0;
>> +			addr->valid = 0;
>> +			list_del_rcu(&addr->list);
>> +			break;
>>  		}
>>  	}
>> +	rcu_read_unlock_bh();
> 
> Ditto.
> 
>> +
>> +	if (addr && !addr->valid) {
>> +		call_rcu_bh(&addr->rcu, sctp_local_addr_free);
>> +		SCTP_DBG_OBJCNT_DEC(addr);
>> +	}
>>
>>  	return -EINVAL;
>>  }

>> @@ -325,27 +336,31 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
>>  	union sctp_addr			*addr;
>>  	void 				*addr_buf;
>>  	struct sctp_af			*af;
>> -	struct list_head		*pos;
>>  	int				i;
>>
>> -	list_for_each(pos, &bp->address_list) {
>> -		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
>> +		if (!laddr->valid)
>> +			continue;
> 
> Ditto...
> 
>>  		addr_buf = (union sctp_addr *)addrs;
>>  		for (i = 0; i < addrcnt; i++) {
>>  			addr = (union sctp_addr *)addr_buf;
>>  			af = sctp_get_af_specific(addr->v4.sin_family);
>>  			if (!af)
>> -				return NULL;
>> +				break;
>>
>>  			if (opt->pf->cmp_addr(&laddr->a, addr, opt))
>>  				break;
>>
>>  			addr_buf += af->sockaddr_len;
>>  		}
>> -		if (i == addrcnt)
>> +		if (i == addrcnt) {
>> +			rcu_read_unlock();
> 
> Since rcu_read_unlock() just happened, some other CPU is free to
> free up this data structure.  In a CONFIG_PREEMPT kernel (as well as a
> CONFIG_PREEMPT_RT kernel, for that matter), this task might be preempted
> at this point, and a full grace period might elapse.
> 
> In which case, the following statement returns a pointer to the freelist,
> which is not good.

Hm...  my saving grace here is that this happens under the protection of the
socket lock so the rcu_read_lock is again potentially redundant.  If it wasn't
for that socket lock, the original code would also have the same race. 

> 
>>  			return &laddr->a;
>> +		}
>>  	}
>> +	rcu_read_unlock();
>>
>>  	return NULL;
>>  }

>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index 79856c9..caaa29f 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -1531,7 +1531,7 @@ no_hmac:
>>  	/* Also, add the destination address. */
>>  	if (list_empty(&retval->base.bind_addr.address_list)) {
>>  		sctp_add_bind_addr(&retval->base.bind_addr, &chunk->dest, 1,
>> -				   GFP_ATOMIC);
>> +				GFP_ATOMIC);
>>  	}
>>
>>  	retval->next_tsn = retval->c.initial_tsn;
>> @@ -2613,22 +2613,17 @@ static int sctp_asconf_param_success(struct sctp_association *asoc,
>>
>>  	switch (asconf_param->param_hdr.type) {
>>  	case SCTP_PARAM_ADD_IP:
>> -		sctp_local_bh_disable();
>> -		sctp_write_lock(&asoc->base.addr_lock);
>> -		list_for_each(pos, &bp->address_list) {
>> -			saddr = list_entry(pos, struct sctp_sockaddr_entry, list);
>> +		rcu_read_lock_bh();
>> +		list_for_each_entry_rcu(saddr, &bp->address_list, list) {
>> +			if (!saddr->valid)
>> +				continue;
>>  			if (sctp_cmp_addr_exact(&saddr->a, &addr))
>>  				saddr->use_as_src = 1;
>>  		}
>> -		sctp_write_unlock(&asoc->base.addr_lock);
>> -		sctp_local_bh_enable();
>> +		rcu_read_unlock_bh();
> 
> If you use rcu_read_lock_bh() and rcu_read_unlock_bh() in one read path
> for a given data structure, you need to use them in all the other read
> paths for that data structure.  In addition, you must use call_rcu_bh()
> when deleting the corresponding data elements.
> 
> The normal and the _bh RCU grace periods are unrelated, so mixing them
> for a given RCU-protected data structure is a bad idea.  (Or are these
> somehow two independent data structures?)

It's the same data structure, but update some of its contents in the softirq
context. Thankfully we don't change the list in this case.  As you can see,
the code was calling local_bh_disable() before, so I was trying to preserve
that condition.

This condition also happens under the synchronization of the socket lock, so
rcu may be potentially redundant here.  It might be sufficient to simply
call local_bh_disable() for this particular case.

> 
>>  		break;
>>  	case SCTP_PARAM_DEL_IP:
>> -		sctp_local_bh_disable();
>> -		sctp_write_lock(&asoc->base.addr_lock);
>>  		retval = sctp_del_bind_addr(bp, &addr);
>> -		sctp_write_unlock(&asoc->base.addr_lock);
>> -		sctp_local_bh_enable();

This one is actually the one I worry more about.  If you look close to 
the beginning of this patch at sctp_del_bind_addr(), you'll see that
it also uses BH conventions for it's RCU calls and uses call_rcu_bh()
to free up the entry.

However, given what you said about the grace periods being unrelated, I
am questioning that condition.

I think I'll need 2 version of the del_bind_addr() call, depending on
which list I am cleaning up.

There is a list on the 'endpoint' structure, that we add to and remove from
only in user context.
There is also a list on the 'association' structure, the we add to in user
context, but remove from in BH context only.  I think this one will
need be cleaned up using rcu_read_[un]lock_bh() and call_rcu_bh() calls, while
the first one can use regular rcu calls.  Does that sound generally right?

>>  		list_for_each(pos, &asoc->peer.transport_addr_list) {
>>  			transport = list_entry(pos, struct sctp_transport,
>>  						 transports);
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index a3acf78..35cc30c 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -367,14 +367,10 @@ SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
>>  	if (!bp->port)
>>  		bp->port = inet_sk(sk)->num;
>>
>> -	/* Add the address to the bind address list.  */
>> -	sctp_local_bh_disable();
>> -	sctp_write_lock(&ep->base.addr_lock);
>> -
>> -	/* Use GFP_ATOMIC since BHs are disabled.  */
>> +	/* Add the address to the bind address list.
>> +	 * Use GFP_ATOMIC since BHs will be disabled.
>> +	 */
>>  	ret = sctp_add_bind_addr(bp, addr, 1, GFP_ATOMIC);
>> -	sctp_write_unlock(&ep->base.addr_lock);
>> -	sctp_local_bh_enable();
>>
>>  	/* Copy back into socket for getsockname() use. */
>>  	if (!ret) {
>> @@ -497,7 +493,6 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>>  	void				*addr_buf;
>>  	struct sctp_af			*af;
>>  	struct list_head		*pos;
>> -	struct list_head		*p;
>>  	int 				i;
>>  	int 				retval = 0;
>>
>> @@ -544,14 +539,15 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>>  		if (i < addrcnt)
>>  			continue;
>>
>> -		/* Use the first address in bind addr list of association as
>> -		 * Address Parameter of ASCONF CHUNK.
>> +		/* Use the first valid address in bind addr list of
>> +		 * association as Address Parameter of ASCONF CHUNK.
>>  		 */
>> -		sctp_read_lock(&asoc->base.addr_lock);
>>  		bp = &asoc->base.bind_addr;
>> -		p = bp->address_list.next;
>> -		laddr = list_entry(p, struct sctp_sockaddr_entry, list);
>> -		sctp_read_unlock(&asoc->base.addr_lock);
>> +		rcu_read_lock();
>> +		list_for_each_entry_rcu(laddr, &bp->address_list, list)
>> +			if (laddr->valid)
>> +				break;
>> +		rcu_read_unlock();
> 
> Here you are carrying an RCU-protected data item (*laddr) outside of an
> rcu_read_lock()/rcu_read_unlock() pair.  This is not good -- you need
> to move the rcu_read_unlock() farther down to cover the full extend to
> uses of the laddr pointer.
> 
> Again, RCU is within its rights allowing a grace period to elapse, so
> that past this point, laddr might well point into the freelist.
> 

This is another area, where we may not even need rcu locking, since we
are already holding a socket lock that guarantees that the list will not change.
This was a blind conversion on my part, and I can probably restore the simple
list_entry() dereference there.

<snip the rest, there were no comments>

Thanks a lot
-vlad
