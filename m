From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation  
 scheme
Date: Thu, 09 Oct 2008 14:26:25 -0500
Message-ID: <48EE5AE1.5030002@codemonkey.ws>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com>	 <1223494499-18732-2-git-send-email-markmc@redhat.com>	 <200810091155.59731.rusty@rustcorp.com.au>	 <20081009153035.GA21542@gondor.apana.org.au> <1223574013.13792.23.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:38971 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbYJIT0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:26:32 -0400
Received: by gxk9 with SMTP id 9so529756gxk.13
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2008 12:26:31 -0700 (PDT)
In-Reply-To: <1223574013.13792.23.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> 
> Also, including virtio_net_hdr in the data buffer would need another
> feature flag. Rightly or wrongly, KVM's implementation requires
> virtio_net_hdr to be the first buffer:
> 
>     if (elem.in_num < 1 || elem.in_sg[0].iov_len != sizeof(*hdr)) {
>         fprintf(stderr, "virtio-net header not in first element\n");
>         exit(1);
>     }
> 
> i.e. it's part of the ABI ... at least as KVM sees it :-)

This is actually something that's broken in a nasty way.  Having the 
header in the first element is not supposed to be part of the ABI but it 
sort of has to be ATM.

If an older version of QEMU were to use a newer kernel, and the newer 
kernel had a larger header size, then if we just made the header be the 
first X bytes, QEMU has no way of knowing how many bytes that should be. 
  Instead, the guest actually has to allocate the virtio-net header in 
such a way that it only presents the size depending on the features that 
the host supports.  We don't use a simple versioning scheme, so you'd 
have to check for a combination of features advertised by the host but 
that's not good enough because the host may disable certain features.

Perhaps the header size is whatever the longest element that has been 
commonly negotiated?

So that's why this aggressive check is here.  Not to necessarily cement 
this into the ABI but as a way to make someone figure out how to 
sanitize this all.

Regards,

Anthony Liguori
