From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC v3 PATCH 2/21] SCTP: Convert bind_addr_list locking to RCU
Date: Thu, 13 Sep 2007 14:15:42 -0400
Message-ID: <46E97E4E.6090505@hp.com>
References: <46E85344.1030402@hp.com>	 <11896310224146-git-send-email-vladislav.yasevich@hp.com>	 <20070912223352.GJ9830@linux.vnet.ibm.com> <1189706346.2748.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:35319 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbXIMSQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 14:16:35 -0400
In-Reply-To: <1189706346.2748.20.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sridhar

Sridhar Samudrala wrote:
> 
> looks good to me too. some minor typos and some comments on
> RCU usage comments inline.
> 
> Also, I guess we can remove the sctp_[read/write]_[un]lock macros
> from sctp.h now that you removed the all the users of rwlocks
> in SCTP

Ok.  I guess I pull them.

> 
> Thanks
> Sridhar
>>> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>>> ---
>>>  include/net/sctp/structs.h |    7 +--
>>>  net/sctp/associola.c       |   14 +-----
>>>  net/sctp/bind_addr.c       |   68 ++++++++++++++++++++----------
>>>  net/sctp/endpointola.c     |   27 +++---------
>>>  net/sctp/ipv6.c            |   12 ++---
>>>  net/sctp/protocol.c        |   25 ++++-------
>>>  net/sctp/sm_make_chunk.c   |   18 +++-----
>>>  net/sctp/socket.c          |   98 ++++++++++++-------------------------------
>>>  8 files changed, 106 insertions(+), 163 deletions(-)
>>>
>>>
>>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>>> index 7fc369f..d16055f 100644
>>> --- a/net/sctp/bind_addr.c
>>> +++ b/net/sctp/bind_addr.c
>>> @@ -167,7 +167,11 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>>>
>>>  	INIT_LIST_HEAD(&addr->list);
>>>  	INIT_RCU_HEAD(&addr->rcu);
>>> -	list_add_tail(&addr->list, &bp->address_list);
>>> +
>>> +	/* We always hold a socket lock when calling this function,
>>> +	 * so rcu_read_lock is not needed.
>>> +	 */
>>> +	list_add_tail_rcu(&addr->list, &bp->address_list);
> 
> I am little confused with the comment above.
> Isn't this an update-side of RCU. If so, this should be protected
> by a spin-lock or a mutex rather than rcu_read_lock().
> 

Yes, the comment is confusing.  I put it there because I removed the rcu_read_lock() that
was also taken in prior version of the patch.  The comment should really say, that since
the socket is held, we don't need another synchronizing spin lock in this case.

>>>  	SCTP_DBG_OBJCNT_INC(addr);
>>>
>>>  	return 0;
>>> @@ -176,23 +180,35 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>>>  /* Delete an address from the bind address list in the SCTP_bind_addr
>>>   * structure.
>>>   */
>>> -int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
>>> +int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr,
>>> +			void (*rcu_call)(struct rcu_head *head,
>>> +					 void (*func)(struct rcu_head *head)))
>>>  {
>>> -	struct list_head *pos, *temp;
>>> -	struct sctp_sockaddr_entry *addr;
>>> +	struct sctp_sockaddr_entry *addr, *temp;
>>>
>>> -	list_for_each_safe(pos, temp, &bp->address_list) {
>>> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
>>> +	/* We hold the socket lock when calling this function, so
>>> +	 * rcu_read_lock is not needed.
>>> +	 */
> 
> Same as above. This is also an update-side of RCU protected 
> by socket lock.

Same reason.  Prior versions used rcu_spin_lock and I was just making a note that
that not needed.  I'll remove.

> 
>>> +	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
>>>  		if (sctp_cmp_addr_exact(&addr->a, del_addr)) {
>>>  			/* Found the exact match. */
>>> -			list_del(pos);
>>> -			kfree(addr);
>>> -			SCTP_DBG_OBJCNT_DEC(addr);
>>> -
>>> -			return 0;
>>> +			addr->valid = 0;
>>> +			list_del_rcu(&addr->list);
>>> +			break;
>>>  		}
>>>  	}
>>>
>>> +	/* Call the rcu callback provided in the args.  This function is
>>> +	 * called by both BH packet processing and user side socket option
>>> +	 * processing, but it works on different lists in those 2 contexts.
>>> +	 * Each context provides it's own callback, whether call_rc_bh()
> s/call_rc_bh/call_rcu_bh

yep.

> 
>>> +	 * or call_rcu(), to make sure that we wait an for appropriate time.
> s/an for/for an

yep.  fat fingered...

>>> @@ -295,20 +285,17 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
>>>  int sctp_endpoint_is_peeled_off(struct sctp_endpoint *ep,
>>>  				const union sctp_addr *paddr)
>>>  {
>>> -	struct list_head *pos;
>>>  	struct sctp_sockaddr_entry *addr;
>>>  	struct sctp_bind_addr *bp;
>>>
>>> -	sctp_read_lock(&ep->base.addr_lock);
>>>  	bp = &ep->base.bind_addr;
>>> -	list_for_each(pos, &bp->address_list) {
>>> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
>>> -		if (sctp_has_association(&addr->a, paddr)) {
>>> -			sctp_read_unlock(&ep->base.addr_lock);
>>> +	/* This function is called whith the socket lock held,
> s/whith/with

ok


Thanks
-vlad

