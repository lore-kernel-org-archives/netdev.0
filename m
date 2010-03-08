From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 8 Mar 2010 16:09:57 -0500
Message-ID: <20100308210957.GH23634@hmsreliant.think-freely.org>
References: <20100308200315.GE23634@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45305 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755140Ab0CHVKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 16:10:04 -0500
Content-Disposition: inline
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 08, 2010 at 12:48:38PM -0800, Stephens, Allan wrote:
> Hi there:
> 
> There are a couple of problems with this patch that need to be resolved
> before it can be applied to the upstream kernel.
> 
> 1) Neil's replacement of the htohl() call with the equivalent
> htonl()/ntohl() calls, while well intentioned, was done without
> understanding why the htohl() calls were put there in the first place.
I'd love to hear what those reasons are.  You're formating on-the-wire data to
an endianness defined by the receiving entity.  I'm hard pressed to imagine a
reason why thats sane.

> In addition, the TIPC specification that he used to justify some of his
> decisions is out-dated, and doesn't reflect the latest version of the
> TIPC protocol.  (I'll discuss this further in a follow-up email.)
> 
Please, point out a more recent spec.  The one I referenced is the most recent
publically available spec that I can find. although again, I'm hard pressed to
believe that the spec has changed to include a requirement to send data in
receiver byte order.

> 2) Neil's alteration of the memcpy() in the subscription cancelation
> routine is simply wrong.  The pieces of the data structure that he
> claims are local are not local, and must be checked to ensure that the
> cancellation is done properly.
> 

The origional memcmp checks sizeof(tipc_subscr) bytes of each entry in the
array.  tipc_subscr is defined as:
struct tipc_subscr {
        struct tipc_name_seq seq;       /* name sequence of interest */
        __u32 timeout;                  /* subscription duration (in ms) */
        __u32 filter;                   /* bitmask of filter options */
        char usr_handle[8];             /* available for subscriber use */
};

In subscr_subscribe (from which we also call subscr_cancel), we allocate new
entries for that list, only fillingout the seq.type, seq.lower, seq.upper,
timeout and filter.  So if anyone locally changes usr_handle (which I see
several places that do), the memcmp won't match up properly.  Additionally, I'm
hard pressed to believe (and this would be supported by the section of the spec
that I referenced), timeout, and filter also don't bear on the uniqueness of the
subscriber Id.  Of course a subsequent version of the spec might have changed
that, But if it is, please point it out to me.

> I'm also surprised to see that this patch was immediately applied to
> net-2.6.  First, there was no opportunity given for people to comment on
> the patch.  Secondly, I would have expected this patch to be applied to
> net-next-2.6, since the functionality being changed here (at least the
> first part of it) is more like a feature enhancement than a bug fix.  Am
> I misunderstanding the process being followed here?  If so, please
> explain ...
> 
I'll let David Comment of this, since the destination tree is his final
decision.

Neil

> Regards,
> Al
> 
> > -----Original Message-----
> > From: Neil Horman [mailto:nhorman@tuxdriver.com] 
> > Sent: Monday, March 08, 2010 3:03 PM
> > To: netdev@vger.kernel.org
> > Cc: Stephens, Allan; davem@davemloft.net; nhorman@tuxdriver.com
> > Subject: [PATCH] tipc: fix endianness on tipc subscriber messages
> > 
> > Remove htohl implementation from tipc
> > 
> > I was working on forward porting the downstream commits for 
> > TIPC and ran accross this one:
> > http://tipc.cslab.ericsson.net/cgi-bin/gitweb.cgi?p=people/all
> > an/tipc.git;a=commitdiff;h=894279b9437b63cbb02405ad5b8e033b51e4e31e
> > 
> > I was going to just take it, when I looked closer and noted 
> > what it was doing.
> > This is basically a routine to byte swap fields of data in 
> > sent/received packets for tipc, dependent upon the receivers 
> > guessed endianness of the peer when a connection is 
> > established.  Asside from just seeming silly to me, it 
> > appears to violate the latest RFC draft for tipc:
> > http://tipc.sourceforge.net/doc/draft-spec-tipc-02.txt
> > Which, according to section 4.2 and 4.3.3, requires that all 
> > fields of all commands be sent in network byte order.  So 
> > instead of just taking this patch, instead I'm removing the 
> > htohl function and replacing the calls with calls to ntohl in 
> > the rx path and htonl in the send path.
> > 
> > As part of this fix, I'm also changing the subscr_cancel 
> > function, which searches the list of subscribers, using a 
> > memcmp of the entire subscriber list, for the entry to tear 
> > down.  unfortunately it memcmps the entire tipc_subscr 
> > structure which has several bits that are private to the 
> > local side, so nothing will ever match.  section 5.2 of the 
> > draft spec indicates the <type,upper,lower> tuple should 
> > uniquely identify a subscriber, so convert subscr_cancel to 
> > just match on those fields (properly endian swapped).
> > 
> > I've tested this using the tipc test suite, and its passed 
> > without issue.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: Allan Stephens <allan.stephens@windriver.com>
> > 
> > 
> >  subscr.c |   57 
> > ++++++++++++++++++++++-----------------------------------
> >  subscr.h |    2 --
> >  2 files changed, 22 insertions(+), 37 deletions(-)
> > 
> > diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c index 
> > ac91f0d..ff123e5 100644
> > --- a/net/tipc/subscr.c
> > +++ b/net/tipc/subscr.c
> > @@ -76,19 +76,6 @@ struct top_srv {
> >  static struct top_srv topsrv = { 0 };
> >  
> >  /**
> > - * htohl - convert value to endianness used by destination
> > - * @in: value to convert
> > - * @swap: non-zero if endianness must be reversed
> > - *
> > - * Returns converted value
> > - */
> > -
> > -static u32 htohl(u32 in, int swap)
> > -{
> > -	return swap ? swab32(in) : in;
> > -}
> > -
> > -/**
> >   * subscr_send_event - send a message containing a 
> > tipc_event to the subscriber
> >   *
> >   * Note: Must not hold subscriber's server port lock, since 
> > tipc_send() will @@ -107,11 +94,11 @@ static void 
> > subscr_send_event(struct subscription *sub,
> >  	msg_sect.iov_base = (void *)&sub->evt;
> >  	msg_sect.iov_len = sizeof(struct tipc_event);
> >  
> > -	sub->evt.event = htohl(event, sub->swap);
> > -	sub->evt.found_lower = htohl(found_lower, sub->swap);
> > -	sub->evt.found_upper = htohl(found_upper, sub->swap);
> > -	sub->evt.port.ref = htohl(port_ref, sub->swap);
> > -	sub->evt.port.node = htohl(node, sub->swap);
> > +	sub->evt.event = htonl(event);
> > +	sub->evt.found_lower = htonl(found_lower);
> > +	sub->evt.found_upper = htonl(found_upper);
> > +	sub->evt.port.ref = htonl(port_ref);
> > +	sub->evt.port.node = htonl(node);
> >  	tipc_send(sub->server_ref, 1, &msg_sect);  }
> >  
> > @@ -287,16 +274,23 @@ static void subscr_cancel(struct 
> > tipc_subscr *s,  {
> >  	struct subscription *sub;
> >  	struct subscription *sub_temp;
> > +	__u32 type, lower, upper;
> >  	int found = 0;
> >  
> >  	/* Find first matching subscription, exit if not found */
> >  
> > +	type = ntohl(s->seq.type);
> > +	lower = ntohl(s->seq.lower);
> > +	upper = ntohl(s->seq.upper);
> > +
> >  	list_for_each_entry_safe(sub, sub_temp, 
> > &subscriber->subscription_list,
> >  				 subscription_list) {
> > -		if (!memcmp(s, &sub->evt.s, sizeof(struct 
> > tipc_subscr))) {
> > -			found = 1;
> > -			break;
> > -		}
> > +			if ((type == sub->seq.type) &&
> > +			    (lower == sub->seq.lower) &&
> > +			    (upper == sub->seq.upper)) {
> > +				found = 1;
> > +				break;
> > +			}
> >  	}
> >  	if (!found)
> >  		return;
> > @@ -325,16 +319,10 @@ static struct subscription 
> > *subscr_subscribe(struct tipc_subscr *s,
> >  					     struct subscriber 
> > *subscriber)  {
> >  	struct subscription *sub;
> > -	int swap;
> > -
> > -	/* Determine subscriber's endianness */
> > -
> > -	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
> >  
> >  	/* Detect & process a subscription cancellation request */
> >  
> > -	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
> > -		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
> > +	if (ntohl(s->filter) & TIPC_SUB_CANCEL) {
> >  		subscr_cancel(s, subscriber);
> >  		return NULL;
> >  	}
> > @@ -359,11 +347,11 @@ static struct subscription 
> > *subscr_subscribe(struct tipc_subscr *s,
> >  
> >  	/* Initialize subscription object */
> >  
> > -	sub->seq.type = htohl(s->seq.type, swap);
> > -	sub->seq.lower = htohl(s->seq.lower, swap);
> > -	sub->seq.upper = htohl(s->seq.upper, swap);
> > -	sub->timeout = htohl(s->timeout, swap);
> > -	sub->filter = htohl(s->filter, swap);
> > +	sub->seq.type = ntohl(s->seq.type);
> > +	sub->seq.lower = ntohl(s->seq.lower);
> > +	sub->seq.upper = ntohl(s->seq.upper);
> > +	sub->timeout = ntohl(s->timeout);
> > +	sub->filter = ntohl(s->filter);
> >  	if ((!(sub->filter & TIPC_SUB_PORTS) ==
> >  	     !(sub->filter & TIPC_SUB_SERVICE)) ||
> >  	    (sub->seq.lower > sub->seq.upper)) { @@ -376,7 
> > +364,6 @@ static struct subscription *subscr_subscribe(struct 
> > tipc_subscr *s,
> >  	INIT_LIST_HEAD(&sub->nameseq_list);
> >  	list_add(&sub->subscription_list, 
> > &subscriber->subscription_list);
> >  	sub->server_ref = subscriber->port_ref;
> > -	sub->swap = swap;
> >  	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
> >  	atomic_inc(&topsrv.subscription_count);
> >  	if (sub->timeout != TIPC_WAIT_FOREVER) { diff --git 
> > a/net/tipc/subscr.h b/net/tipc/subscr.h index 45d89bf..c20f496 100644
> > --- a/net/tipc/subscr.h
> > +++ b/net/tipc/subscr.h
> > @@ -53,7 +53,6 @@ typedef void (*tipc_subscr_event) (struct 
> > subscription *sub,
> >   * @nameseq_list: adjacent subscriptions in name sequence's 
> > subscription list
> >   * @subscription_list: adjacent subscriptions in 
> > subscriber's subscription list
> >   * @server_ref: object reference of server port associated 
> > with subscription
> > - * @swap: indicates if subscriber uses opposite endianness 
> > in its messages
> >   * @evt: template for events generated by subscription
> >   */
> >  
> > @@ -66,7 +65,6 @@ struct subscription {
> >  	struct list_head nameseq_list;
> >  	struct list_head subscription_list;
> >  	u32 server_ref;
> > -	int swap;
> >  	struct tipc_event evt;
> >  };
> >  
> > 
> 
