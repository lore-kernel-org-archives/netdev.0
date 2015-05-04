From: Ying Xue <ying.xue@windriver.com>
Subject: Re: Netlink socket leaks
Date: Mon, 4 May 2015 18:09:18 +0800
Message-ID: <5547454E.1070106@windriver.com>
References: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com> <CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com> <20150503000428.GA16211@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrey Wagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47005 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbbEDKKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 06:10:51 -0400
In-Reply-To: <20150503000428.GA16211@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2015 08:04 AM, Herbert Xu wrote:
> On Sat, May 02, 2015 at 02:31:09AM +0300, Andrey Wagin wrote:
>>
>> A socket leaks if it is released by sk_release_kernel(). The problem
>> is that netlink_insert() and netlink_remove() is called when a socket
>> has different values of sk->sk_net.
> 
> I think we simply need to revert
> c243d7e20996254f89c28d4838b5feca735c030d.
> 
> ---8<---
> Subject: Revert "net: kernel socket should be released in init_net namespace"
> 
> This reverts commit c243d7e20996254f89c28d4838b5feca735c030d.
> 
> That patch is solving a non-existant problem while creating a
> real problem.  Just because a socket is allocated in the init
> name space doesn't mean that it gets hashed in the init name space.
> 
> When we unhash it the name space must be the same as the one
> we had when we hashed it.  So this patch is completely bogus
> and causes socket leaks.
> 

Herbert, thanks for the fix.

Reverting commit c243d7e20996254f89c28d4838b5feca735c030d is absolutely a
correct decision now.

Actually my initial purpose of creating the commit is because inserting tipc
socket into its rhashtable happens in socket creation, and deleting the socket
from its rhashtable occurs in socket release. Without the commit, the creation
of tipc kernel internal socket happens in init_net context, but the socket
release occurs in the current namespace. More importantly, tipc allocates
different rhashtables for different namespaces. Therefore, tipc kernel internal
sockets created init_net would be inserted into init_net's rhashtable, but they
would be removed from current namespace's rhashtable when deleting them. As a
result, tipc kernel sockets are leaked as they are unable to be found in current
namespace's rhashtable. But as the commit can guarantee that both creation and
deletion of tipc kernel internal socket always happens in the current namespace,
leaking tipc socket can be avoided.

However, I did not realize that hashing of inet sockets usually occurs in
bind(), and unashing is in release(). As The former context is current
namespace, and the latter is init_net. the socket leak happens on netlink sockets.

Currently as for tipc kernel sockets, even your patch is involved, the leak
would never happen on tipc sockets because tipc uses __sock_create() instead of
sock_create_kern() to create its kernel sockets.

Until now, I believe that it's safe for all kinds of kernel sockets together
with your patch.

However, when I reviewed your patch, I found that moving netlink socket's
namespace back and forth is unnecessary for us at all. Instead it artificially
increases the complexity of netlink code. Therefore, I create the following
patch to avoid it, please review it:

http://patchwork.ozlabs.org/patch/467535/

Thanks,
Ying

> Reported-by: Andrey Wagin <avagin@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index e891bcf..292f422 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1474,8 +1474,8 @@ void sk_release_kernel(struct sock *sk)
>  		return;
>  
>  	sock_hold(sk);
> -	sock_net_set(sk, get_net(&init_net));
>  	sock_release(sk->sk_socket);
> +	sock_net_set(sk, get_net(&init_net));
>  	sock_put(sk);
>  }
>  EXPORT_SYMBOL(sk_release_kernel);
> 
