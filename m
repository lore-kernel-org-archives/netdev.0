From: =?UTF-8?B?TWFydGluIE1PS1JFSsWg?= <mmokrejs@ribosome.natur.cuni.cz>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0:	(sk_lock-AF_PACKET){--..},
 at: [<c1279838>]	sock_setsockopt+0x12b/0x4a4
Date: Fri, 30 Jan 2009 18:17:49 +0100
Message-ID: <4983363D.1050904@ribosome.natur.cuni.cz>
References: <20090130124947.GA6886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, vegard.nossum@gmail.com,
	a.p.zijlstra@chello.nl, jarkao2@gmail.com, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ribosome.natur.cuni.cz ([195.113.57.20]:44592 "EHLO
	ribosome.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbZA3RRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 12:17:55 -0500
In-Reply-To: <20090130124947.GA6886@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch works for me.
Thanks
M.

Herbert Xu wrote:
> On Fri, Jan 30, 2009 at 05:12:50PM +1100, Herbert Xu wrote:
>> Well, doing the copy under sk_lock is pretty common through all
>> protocols.  So I think it'd be safer to change the other path,
>> which is doing the odd thing here, i.e., ->mmap() grabbing the
>> socket lock while holding mmap_sem.
>>
>> In fact, it would appear that we don't really need the socket lock
>> in ->mmap() since it only needs to ensure that pg_vec* doesn't
>> get yanked or changed.  So this patch should work:
>>
>> packet: Avoid lock_sock in mmap handler
> 
> Dave pointed out that a spin lock is illegal for this purpose
> as vm_insert_page can do a GFP_KERNEL allocation.  So I've added
> a mutex for this.
> 
> I've also widened the critical section in packet_set_ring since
> we need the mapped check to be within it.
> 
> packet: Avoid lock_sock in mmap handler
> 
> As the mmap handler gets called under mmap_sem, and we may grab
> mmap_sem elsewhere under the socket lock to access user data, we
> should avoid grabbing the socket lock in the mmap handler.
> 
> Since the only thing we care about in the mmap handler is for
> pg_vec* to be invariant, i.e., to exclude packet_set_ring, we
> can achieve this by simply using sk_receive_queue.lock.
> 
> I resisted the temptation to create a new spin lock because the
> mmap path isn't exactly common.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 5f94db2..9454d4a 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -77,6 +77,7 @@
>  #include <linux/poll.h>
>  #include <linux/module.h>
>  #include <linux/init.h>
> +#include <linux/mutex.h>
>  
>  #ifdef CONFIG_INET
>  #include <net/inet_common.h>
> @@ -175,6 +176,7 @@ struct packet_sock {
>  #endif
>  	struct packet_type	prot_hook;
>  	spinlock_t		bind_lock;
> +	struct mutex		pg_vec_lock;
>  	unsigned int		running:1,	/* prot_hook is attached*/
>  				auxdata:1,
>  				origdev:1;
> @@ -1069,6 +1071,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
>  	 */
>  
>  	spin_lock_init(&po->bind_lock);
> +	mutex_init(&po->pg_vec_lock);
>  	po->prot_hook.func = packet_rcv;
>  
>  	if (sock->type == SOCK_PACKET)
> @@ -1865,6 +1868,7 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
>  	synchronize_net();
>  
>  	err = -EBUSY;
> +	mutex_lock(&po->pg_vec_lock);
>  	if (closing || atomic_read(&po->mapped) == 0) {
>  		err = 0;
>  #define XC(a, b) ({ __typeof__ ((a)) __t; __t = (a); (a) = (b); __t; })
> @@ -1886,6 +1890,7 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
>  		if (atomic_read(&po->mapped))
>  			printk(KERN_DEBUG "packet_mmap: vma is busy: %d\n", atomic_read(&po->mapped));
>  	}
> +	mutex_unlock(&po->pg_vec_lock);
>  
>  	spin_lock(&po->bind_lock);
>  	if (was_running && !po->running) {
> @@ -1918,7 +1923,7 @@ static int packet_mmap(struct file *file, struct socket *sock, struct vm_area_st
>  
>  	size = vma->vm_end - vma->vm_start;
>  
> -	lock_sock(sk);
> +	mutex_lock(&po->pg_vec_lock);
>  	if (po->pg_vec == NULL)
>  		goto out;
>  	if (size != po->pg_vec_len*po->pg_vec_pages*PAGE_SIZE)
> @@ -1941,7 +1946,7 @@ static int packet_mmap(struct file *file, struct socket *sock, struct vm_area_st
>  	err = 0;
>  
>  out:
> -	release_sock(sk);
> +	mutex_unlock(&po->pg_vec_lock);
>  	return err;
>  }
>  #endif
