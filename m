From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Wed, 13 Oct 2010 11:19:47 +0000
Message-ID: <20101013111946.GA9529@ff.dom.local>
References: <20101012.130520.48517464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, hans.schillstrom@ericsson.com,
	daniel.lezcano@free.fr, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52041 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769Ab0JMLTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 07:19:54 -0400
Received: by bwz15 with SMTP id 15so3085655bwz.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 04:19:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101012.130520.48517464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-10-12 22:05, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 08 Oct 2010 10:32:40 -0700
> 
>> It is just dealing with not flushing the entire routing cache, just the
>> routes that have expired.  Which prevents one network namespace from
>> flushing it's routes and DOS'ing another.
> 
> That's a very indirect and obfuscated way of handling it.
> 
> And I still don't know why we let the first contiguous set of expired
> entries in the chain get freed outside of the lock, and the rest
> inside the lock.  That really isn't explained by anything I've read.
> 
> How about we just do exactly what's intended, and with no ifdefs?
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
...
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0755aa4..6ad730c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -712,13 +712,14 @@ static inline int rt_is_expired(struct rtable *rth)
>   * Can be called by a softirq or a process.
>   * In the later case, we want to be reschedule if necessary
>   */
> -static void rt_do_flush(int process_context)
> +static void rt_do_flush(struct net *net, int process_context)
>  {
>  	unsigned int i;
>  	struct rtable *rth, *next;
> -	struct rtable * tail;
>  
>  	for (i = 0; i <= rt_hash_mask; i++) {
> +		struct rtable *list, **pprev;

Isn't "list = NULL" needed here?

Jarek P.

...
> +				rth->dst.rt_next = list;
> +				list = rth;
> +			} else
> +				pprev = &rth->dst.rt_next;
> +
> +			rth = next;
...
