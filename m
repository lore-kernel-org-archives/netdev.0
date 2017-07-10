From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [GIT] Networking
Date: Mon, 10 Jul 2017 08:10:02 -0400
Message-ID: <20170710121002.GB21587@oracle.com>
References: <20170708.113644.1272962770645338865.davem@davemloft.net>
 <CA+55aFzocFTX5JR9oG_5uKw-fT6OJUMkD71sypbec7JP=_qwpg@mail.gmail.com>
 <20170709191131.GB22224@oracle.com>
 <20170709.214043.1361767365552001158.davem@davemloft.net>
 <20170710100531.GA14940@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170710100531.GA14940@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (07/10/17 18:05), Herbert Xu wrote:
> 
> Hmm, I can't see the problem in af_alg_accept.  The struct socket
> comes directly from sys_accept() which creates it using sock_alloc.
> 
> So the only thing I can think of is that the memory returned by
> sock_alloc is not zeroed and therefore the WARN_ON is just reading
> garbage.

Then it is odd that this WARN_ON is not triggered for other sockets
(e.g., for TCP sockets), though it happens easily with AF_ALG. 

But it's not sock_alloc() - that function is returning a properly
zeroed ->sk.

The reason that the WARN_ON is triggered is that af_alg_accept() calls
sock_init_data() which does 

   2636         if (sock) {
    :
   2639                 sock->sk        =       sk;


So we can do one of the following:

1. drop the WARN_ON(), which makes true leaks hard to detect
2. change the WARN_ON() to WARN_ON(parent->sk && parent->sk != sk)

#2 assumes that all the refcount book-keeping is being done
correctly (there is the danger that we end up taking 2 refs on the sk) 

--Sowmini
