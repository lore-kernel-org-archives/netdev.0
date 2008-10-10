From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation  
	scheme
Date: Fri, 10 Oct 2008 09:30:31 +0100
Message-ID: <1223627431.3618.41.camel@blaa>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com>
	 <1223494499-18732-2-git-send-email-markmc@redhat.com>
	 <200810091155.59731.rusty@rustcorp.com.au>
	 <20081009153035.GA21542@gondor.apana.org.au>
	 <1223574013.13792.23.camel@blaa>  <48EE5AE1.5030002@codemonkey.ws>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56570 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266AbYJJIb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 04:31:28 -0400
In-Reply-To: <48EE5AE1.5030002@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-09 at 14:26 -0500, Anthony Liguori wrote:
> Mark McLoughlin wrote:
> > 
> > Also, including virtio_net_hdr in the data buffer would need another
> > feature flag. Rightly or wrongly, KVM's implementation requires
> > virtio_net_hdr to be the first buffer:
> > 
> >     if (elem.in_num < 1 || elem.in_sg[0].iov_len != sizeof(*hdr)) {
> >         fprintf(stderr, "virtio-net header not in first element\n");
> >         exit(1);
> >     }
> > 
> > i.e. it's part of the ABI ... at least as KVM sees it :-)
> 
> This is actually something that's broken in a nasty way.  Having the 
> header in the first element is not supposed to be part of the ABI but it 
> sort of has to be ATM.
> 
> If an older version of QEMU were to use a newer kernel, and the newer 
> kernel had a larger header size, then if we just made the header be the 
> first X bytes, QEMU has no way of knowing how many bytes that should be. 
>   Instead, the guest actually has to allocate the virtio-net header in 
> such a way that it only presents the size depending on the features that 
> the host supports.  We don't use a simple versioning scheme, so you'd 
> have to check for a combination of features advertised by the host but 
> that's not good enough because the host may disable certain features.
> 
> Perhaps the header size is whatever the longest element that has been 
> commonly negotiated?
> 
> So that's why this aggressive check is here.  Not to necessarily cement 
> this into the ABI but as a way to make someone figure out how to 
> sanitize this all.

Well, features may be orthogonal but they are still added sequentially
to the ABI. So, you would have a kind of implicit ABI versioning, while
still allowing individual selection of features.

e.g. if NET_F_FOO adds "int foo" to the header and then NET_F_BAR adds
"int bar" to the header then if NET_F_FOO is negotiated, the guest
should only send a header with "foo" and if NET_F_FOO|NET_F_BAR or
NET_F_BAR is negotiated, then the guest sends a header with both "foo"
and "bar".

Or put it another way, a host or guest may not implement NET_F_FOO but
knowledge of the "foo" header field is part of the ABI of NET_F_BAR.
That knowledge would be as simple as knowing that the field exists and
that it should be ignored if the feature isn't used.

Cheers,
Mark.

