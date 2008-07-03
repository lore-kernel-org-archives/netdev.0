From: Patrick McHardy <kaber@trash.net>
Subject: Re: net-sched 05/05: sch_htb: use dynamic class hash helpers
Date: Thu, 03 Jul 2008 13:55:58 +0200
Message-ID: <486CBE4E.2050901@trash.net>
References: <20080702213102.GB2476@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34785 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbYGCMHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:07:12 -0400
In-Reply-To: <20080702213102.GB2476@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 07/01/2008 04:34 PM:
>
>   
>> net-sched: sch_htb: use dynamic class hash helpers
>>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>>     
>
> This patch also looks OK too me, except 2 tiny doubts below:
>
>   
>> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
>> index 879f0b6..d5e4fdb 100644
>> --- a/net/sched/sch_htb.c
>> +++ b/net/sched/sch_htb.c
>> @@ -51,7 +51,6 @@
>>      one less than their parent.
>>  */
>>  
>> -#define HTB_HSIZE 16		/* classid hash size */
>>  static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis for speedup */
>>  #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
>>  
>> @@ -72,8 +71,8 @@ enum htb_cmode {
>>  
>>  /* interior & leaf nodes; props specific to leaves are marked L: */
>>  struct htb_class {
>> +	struct Qdisc_class_common common;
>>     
>
> Hmm... isn't this variable name too "common"? Why not something more
> meaningful like: id, node, head, info etc?
>   
I couldn't come up with something better, your
suggestions are also not much more descriptive
in my opinion. I'm also hoping we can put more
stuff in there and so some consolidation later.

> ...
>   
>> @@ -975,13 +957,14 @@ static unsigned int htb_drop(struct Qdisc *sch)
>>  static void htb_reset(struct Qdisc *sch)
>>  {
>>  	struct htb_sched *q = qdisc_priv(sch);
>> -	int i;
>> -
>> -	for (i = 0; i < HTB_HSIZE; i++) {
>> -		struct hlist_node *p;
>> -		struct htb_class *cl;
>> +	struct Qdisc_class_common *clc;
>> +	struct hlist_node *n;
>> +	struct htb_class *cl;
>> +	unsigned int i;
>>  
>> -		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
>> +	for (i = 0; i < q->clhash.hashsize; i++) {
>> +		hlist_for_each_entry(clc, n, &q->clhash.hash[i], hnode) {
>> +			cl = container_of(clc, struct htb_class, common);
>>     
>
> Why not?:
> 		hlist_for_each_entry(cl, n, &q->clhash.hash[i], common.hnode) {
>
> Of course, this is probably a matter of taste, so I don't persist...

Good point, that is nicer. I'll update the patches.
