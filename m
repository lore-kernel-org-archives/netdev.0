From: Neil Brown <neilb@suse.de>
Subject: Re: Oops in 2.6.22.1: skb_copy_and_csum_datagram_iovec()
Date: Wed, 5 Sep 2007 13:50:21 +0100
Message-ID: <18142.42509.447265.575323@notabene.brown>
References: <46CB453B.5040005@redhat.com>
	<E1INkpM-00007x-00@gondolin.me.apana.org.au>
	<18142.39804.387020.852675@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	cebbert@redhat.com (Chuck Ebbert), netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48090 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753713AbXIEMuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 08:50:23 -0400
In-Reply-To: message from Neil Brown on Wednesday September 5
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday September 5, neilb@suse.de wrote:
> On Wednesday August 22, herbert@gondor.apana.org.au wrote:
> > Chuck Ebbert <cebbert@redhat.com> wrote:
> > > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=253290
> > > 
> > > 18:57:54 osama kernel:  [<c05be67f>] kernel_recvmsg+0x31/0x40
> > > 18:57:54 osama kernel:  [<e0bc52d4>] svc_udp_recvfrom+0x114/0x368 [sunrpc]
> > 
> > svc_udp_recvfrom is calling kernel_recvmsg with iov == NULL.
> 
> iov == NULL used to work.
> 
> I think it stopped working at 
>    commit 759e5d006462d53fb708daa8284b4ad909415da1
> 
> Previously, as len==0, MSG_TRUNC would get set, so copy_only would get
> set, so skb_copy_datagram_iovec would get called, and that handles a
> len of 0.
> 
> Now, skb_copy_and_csum_datagram_iovec gets called unless
> skb_csum_unnecessary(skb), which now kills us.

Actually, the new code is broken for more reasons than that.
In core/datagram.c, the comment for skb_copy_and_csum_datagram_iovec,
it says:
 *	Caller _must_ check that skb will fit to this iovec.

but udp_recvmsg doesn't.

It seems to try:
	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
		if (udp_lib_checksum_complete(skb))
			goto csum_copy_err;
	}

	if (skb_csum_unnecessary(skb))
		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
					      msg->msg_iov, copied       );

so it doesn't call skb_copy_datagram_iovec if "copied < ulen".

However earlier there is:
	ulen = skb->len - sizeof(struct udphdr);
	copied = len;
	if (copied > ulen)
		copied = ulen;

so if the 'len' (of the iovec) is too small, we end up with "copied == ulen", 

so udp_lib_checksum_complete doesn't get called....


> 
> We could 'fix' it by making skb_copy_and_csum_datagram_iovec just
> return if len==0, or don't call it from udp_recvmsg in that case.
> 

So the latter of these is needed.

NeilBrown
