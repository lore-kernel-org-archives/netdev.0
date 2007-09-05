From: Neil Brown <neilb@suse.de>
Subject: Re: Oops in 2.6.22.1: skb_copy_and_csum_datagram_iovec()
Date: Wed, 5 Sep 2007 13:05:16 +0100
Message-ID: <18142.39804.387020.852675@notabene.brown>
References: <46CB453B.5040005@redhat.com>
	<E1INkpM-00007x-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com (Chuck Ebbert), netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44927 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbXIEMFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 08:05:19 -0400
In-Reply-To: message from Herbert Xu on Wednesday August 22
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday August 22, herbert@gondor.apana.org.au wrote:
> Chuck Ebbert <cebbert@redhat.com> wrote:
> > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=253290
> > 
> > 18:57:54 osama kernel:  [<c05be67f>] kernel_recvmsg+0x31/0x40
> > 18:57:54 osama kernel:  [<e0bc52d4>] svc_udp_recvfrom+0x114/0x368 [sunrpc]
> 
> svc_udp_recvfrom is calling kernel_recvmsg with iov == NULL.

iov == NULL used to work.

I think it stopped working at 
   commit 759e5d006462d53fb708daa8284b4ad909415da1

Previously, as len==0, MSG_TRUNC would get set, so copy_only would get
set, so skb_copy_datagram_iovec would get called, and that handles a
len of 0.

Now, skb_copy_and_csum_datagram_iovec gets called unless
skb_csum_unnecessary(skb), which now kills us.

We could 'fix' it by making skb_copy_and_csum_datagram_iovec just
return if len==0, or don't call it from udp_recvmsg in that case.

The reason that I call kernel_recvmsg with iov == NULL is that I want
to collect the source/dest addresses of the packet, but I don't want
to actually read the data - I want to just get a reference to the skb
(to avoid needless copy where possible) later.
So I call kernel_recvmsg with MSG_PEEK, and don't bother with an
iovec.

I guess a could send an empty iovec rather than a NULL, but it used to
work.... 

NeilBrown
