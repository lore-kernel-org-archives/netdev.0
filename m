From: Patrick McHardy <kaber@trash.net>
Subject: Re: net-sched 01/05: add dynamically sized qdisc class hash helpers
Date: Thu, 03 Jul 2008 14:16:40 +0200
Message-ID: <486CC328.5070107@trash.net>
References: <20080703121824.GA2559@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35539 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757415AbYGCM1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:27:53 -0400
In-Reply-To: <20080703121824.GA2559@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
>> +static inline void *qdisc_class_find(struct Qdisc_class_hash *hash, u32 id)
>>     
>
> Why not Qdisc_class_common *?
>   

I originally didn't use container_of but simply required
Qdisc_class_common to be the first element of the
class struct, this is a remnant of that. I'll change it,
thanks.

>> +void qdisc_class_hash_grow(struct Qdisc *sch, struct Qdisc_class_hash *clhash)
>> +{
>> +	struct Qdisc_class_common *cl;
>> +	struct hlist_node *n, *next;
>> +	struct hlist_head *nhash, *ohash;
>> +	unsigned int nsize, nmask, osize;
>> +	unsigned int i, h;
>> +
>> +	/* Rehash when load factor exceeds 0.75 */
>> +	if (clhash->hashelems * 4 <= clhash->hashsize * 3)
>>     
>
> With current init hashsize == 4 this will trigger after adding: 4th,
> 7th, 13th,... class. Maybe we could start with something higher?
>   

We could, but I don't think it makes any difference, for those
small numbers the rehashing is really cheap.

>> +		return;
>> +	nsize = clhash->hashsize * 2;
>> +	nmask = nsize - 1;
>> +	nhash = qdisc_class_hash_alloc(nsize);
>> +	if (nhash == NULL)
>> +		return;
>> +
>> +	ohash = clhash->hash;
>> +	osize = clhash->hashsize;
>> +
>> +	sch_tree_lock(sch);
>> +	for (i = 0; i < osize; i++) {
>> +		hlist_for_each_entry_safe(cl, n, next, &ohash[i], hnode) {
>> +			h = qdisc_class_hash(cl->classid, nmask);
>> +			hlist_add_head(&cl->hnode, &nhash[h]);
>>     
>
> With a large number of classes and changes this could probably give
> noticable delays, so maybe there would be reasonable to add a
> possibility of user defined, ungrowable hashsize as well?

I don't think its really going to be noticable (the numbers are not
*that* large), but I'll try to get some numbers.


