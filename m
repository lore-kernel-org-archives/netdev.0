From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Fri, 28 Nov 2014 20:37:34 +0000
Message-ID: <20141128203733.GD29748@ZenIV.linux.org.uk>
References: <5478CC27.9040705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55768 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaK1Uhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 15:37:38 -0500
Content-Disposition: inline
In-Reply-To: <5478CC27.9040705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner wrote:
> Hi,
> 
> I saw there are tun updates on Dave's queue but none seemed to handle this.
> 
> I can't use current net-next
> (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
> because tun got clogged somehow. Bisected down to:

Umm...  In host, presumably?

> And net/core/datagram.c, skb_copy_datagram_from_iter():
>         if (copy > 0) {
>                 int ret;
>                 if (copy > len)
>                         copy = len;
>                 ret = copy_from_iter(skb->data + offset, copy, from);
>                 if (ret != copy) {
>                         pr_err("%d ret=%d copy=%d offset=%d
> len=%d\n", __LINE__, ret, copy, offset, len);
>                         goto fault;
>                 }
> 
> 
> I get, for tun interfaces:
> [   75.435552] 506 ret=80 copy=90 offset=0 len=90
> [   75.435563] tun: 1124 0 -14           (null)
> [   75.499528] 506 ret=80 copy=90 offset=0 len=90
> [   75.499540] tun: 1124 0 -14           (null)
> 
> These were 1 drop on 1 interface each
> 
> And for tap interfaces:
> [  301.982639] 506 ret=80 copy=90 offset=0 len=90
> [  301.982649] tun: 1124 0 -14           (null)
> [  301.988625] 506 ret=80 copy=90 offset=0 len=90
> [  301.988635] tun: 1124 0 -14           (null)
> [  301.994762] 506 ret=80 copy=90 offset=0 len=90
> [  301.994773] tun: 1124 0 -14           (null)
> [  302.229962] 506 ret=332 copy=342 offset=0 len=342
> [  302.229972] tun: 1124 0 -14           (null)
> [  302.230621] 506 ret=332 copy=342 offset=0 len=342
> [  302.230627] tun: 1124 0 -14           (null)
> [  302.239065] 506 ret=332 copy=342 offset=0 len=342
> [  302.239071] tun: 1124 0 -14           (null)
> 
> It's returning 10 bytes less than the expected... ideas?

Could you print vnet_hdr_sz and sizeof(gso) right after that
copy_from_iter(&gso, ...)?
