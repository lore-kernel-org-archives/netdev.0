From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] netns: fix net_generic() "id - 1" bloat
Date: Mon, 5 Dec 2016 12:49:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0234CCB@AcuExch.aculab.com>
References: <20161202012132.GD31170@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xemul@openvz.org" <xemul@openvz.org>
To: 'Alexey Dobriyan' <adobriyan@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:54957 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbcLEMts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 07:49:48 -0500
In-Reply-To: <20161202012132.GD31170@avx2>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan
> Sent: 02 December 2016 01:22
> net_generic() function is both a) inline and b) used ~600 times.
> 
> It has the following code inside
> 
> 		...
> 	ptr = ng->ptr[id - 1];
> 		...
> 
> "id" is never compile time constant so compiler is forced to subtract 1.
> And those decrements or LEA [r32 - 1] instructions add up.
> 
> We also start id'ing from 1 to catch bugs where pernet sybsystem id
> is not initialized and 0. This is quite pointless idea (nothing will
> work or immediate interference with first registered subsystem) in
> general but it hints what needs to be done for code size reduction.
> 
> Namely, overlaying allocation of pointer array and fixed part of
> structure in the beginning and using usual base-0 addressing.
> 
> Ids are just cookies, their exact values do not matter, so lets start
> with 3 on x86_64.
...
>  struct net_generic {
> -	struct {
> -		unsigned int len;
> -		struct rcu_head rcu;
> -	} s;
> -
> -	void *ptr[0];
> +	union {
> +		struct {
> +			unsigned int len;
> +			struct rcu_head rcu;
> +		} s;
> +
> +		void *ptr[0];
> +	};
>  };

That union is an accident waiting to happen.
What might work is to offset the Ids by
(offsetof(struct net_generic, ptr)/sizeof (void *)) instead of by 1.
The subtract from the offset will then counter the structure offset
- which is what you are trying to achieve.

	David.
