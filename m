From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [PATCH] negative dev use in /proc/net/rose_neigh
Date: Tue, 30 Sep 2008 23:44:55 +0200
Message-ID: <48E29DD7.803@free.fr>
References: <200809282156.39466.bpidoux@free.fr> <20080930.073213.60770455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:43028 "EHLO smtp4-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbYI3W4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 18:56:32 -0400
In-Reply-To: <20080930.073213.60770455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I slightly disagree. The patch actually prevents use counter to become 
underflowed (starting with 65535 then 65534 etc...)
The patch makes sure that use never becomes less than 0.
This may prevent further problems.

However I agree that the real reason of the bug is still unknown.
It must be hidden in the very obscure loop (at least for me).
Here is the original code :

void rose_kill_by_neigh( struct rose_neigh *neigh)
{
	struct sock *s;
	struct hlist_node *node;

	spin_lock_bh(&rose_list_lock);
	sk_for_each(s,node,&rose_list) {
		struct rose_sock *rose = rose_sk(s);

		if (rose->neighbour == neigh) {
			rose_disconnect(s, ENETUNREACH, ROSE_OUT_OF_ORDER, 0);
			rose->neighbour->use--;
			rose->neighbour = NULL;
		}
	}
	spin_unlock_bh(&rose_list_lock);
}

I suspect that the bug was unravelled when we added more than one 
neighbour per route. The protocole accepts three, but this was not much 
used during the early days since the density of radio stations on the 
network was not big (only one node station per destination address 
usually). The network is now denser with Internet links.

However, I don't understand why the test

if (rose->neighbour == neigh)

does not work, for
rose->neighbour = NULL;
should prevent next comparison to be valid and thus instruction
rose->neighbour->use--; not executed.

I have seen that a problem with sk_for_each() macro was identified a 
while ago into ax25 code. The problem here could be similar ?


Bernard




David Miller wrote:
> From: Bernard Pidoux <bpidoux@free.fr>
> Date: Sun, 28 Sep 2008 21:56:38 +0200
> 
>> I propose the following patch to avoid use counter underflow.
>> However a KERN_WARNING message could be better instead of KERN_ERR.
> 
> I don't see any large value in adding this patch right now.
> At best it's a new BUG check, it doesn't actually fix the
> problem.  I'd rather apply a fix :-)
> 
> 
