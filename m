From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH stable<3.19] net: handle null iovec pointer in
 skb_copy_and_csum_datagram_iovec()
Date: Fri, 23 Oct 2015 11:22:19 +0200
Message-ID: <20151023092219.GA10782@bistromath.redhat.com>
References: <20151023084609.585AEA0C18@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Sasha Levin <sasha.levin@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>, Zefan Li <lizefan@huawei.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45127 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbbJWJWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 05:22:24 -0400
Content-Disposition: inline
In-Reply-To: <20151023084609.585AEA0C18@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Michal,

2015-10-23, 10:46:09 +0200, Michal Kubecek wrote:
> Mainline commit 89c22d8c3b27 ("net: Fix skb csum races when peeking")
> backport into pre-3.19 stable kernels introduces a regression causing
> null pointer dererefence in skb_copy_and_csum_datagram_iovec().
> 
> This commit only sets CHECKSUM_UNNECESSARY for non-shared skb, allowing
> udp_recvmsg() to take the "else" branch of if (skb_csum_unnecessary(skb))
> when called with null iovec (and len=0, e.g. when peeking for datagram
> size first). The problem is that unlike skb_copy_and_csum_datagram_msg()
> called in this path since 3.19, skb_copy_and_csum_datagram_iovec() does
> not handle null iov parameter and always dereferences iov->iov_len. This
> is especially harmful when udp_recvmsg() is called in kernel context,
> e.g. from kernel nfsd.
> 
> Band-aid skb_copy_and_csum_datagram_iovec() by testing iov for null and
> only checking the checksum in this case.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---

I ran into this problem too and that was my initial solution to this
problem as well, but actually, we need a more complete fix, like the
one I submitted a few days ago:

http://patchwork.ozlabs.org/patch/530642/

With your solution, userspace can still receive bogus EFAULT, or the
kernel ends up writing data to an unwanted memory location.


Thanks,

-- 
Sabrina
