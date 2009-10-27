From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] fib_hash: improve route deletion scaling on
 interface drop with lots of interfaces
Date: Mon, 26 Oct 2009 17:17:49 -0700 (PDT)
Message-ID: <20091026.171749.106971240.davem@davemloft.net>
References: <20091027000302.GA3141@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@lhnet.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59816
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755019AbZJ0AR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 20:17:26 -0400
In-Reply-To: <20091027000302.GA3141@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@lhnet.ca>
Date: Mon, 26 Oct 2009 20:03:02 -0400

> Below is a patch to improve the scaling of interface destruction in 
> fib_hash.  The general idea is to tie the fib_alias structure into a 
> list off of net_device and walk that list during a fib_flush() caused 
> by an interface drop.  This makes the resulting flush only have to walk 
> the number of routes attached to an interface rather than the number of 
> routes attached to all interfaces at the expense of a couple of additional 
> pointers in struct fib_alias.
> 
> This patch is against Linus' tree.  I'll post against net-next after a 
> bit more testing and feedback.  With 20,000 interfaces & routes, interface 
> deletion time improves from 53s to 40s.  Note that this is with other changes 
> applied to improve sysfs and procfs scaling, as otherwise those are the 
> bottleneck.  Next up in the network code is rt_cache_flush().  Comments?

On a real router adding and removing routes is happening a lot
whereas interface changes are rare.  You're making a more common
operation more expensive for the sake of a less common one.

> @@ -128,18 +128,19 @@ void fib_select_default(struct net *net,
>  		tb->tb_select_default(tb, flp, res);
>  }
>  
> -static void fib_flush(struct net *net)
> +static void fib_flush(struct net_device *dev)
>  {
>  	int flushed = 0;
>  	struct fib_table *tb;
>  	struct hlist_node *node;
>  	struct hlist_head *head;
>  	unsigned int h;
> +	struct net *net = dev_net(dev);
>  

Please put local variable lines that are longer at the beginning of
the list of variable declarations at the top of a function, not the
other way around which stands out like a sore thumb and looks ugly.
