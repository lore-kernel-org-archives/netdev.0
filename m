From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: raw: don't agree to 0 sized headers
Date: Thu, 31 Jul 2014 12:24:32 -0700 (PDT)
Message-ID: <20140731.122432.358447367571730334.davem@davemloft.net>
References: <1406726468-19035-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406726468-19035-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed, 30 Jul 2014 09:21:08 -0400

> For raw sockets, we'd always assume that a header is supplied and will attempt
> to copy it into the ip header space using memcpy_fromiovecend():
> 
> 	if (memcpy_fromiovecend((void *)iph, from, 0, length))
> 		goto error_free;
> 
> The problem is that memcpy_fromiovecend() assumes that there are actual data
> to read from the iovec and doesn't deal with cases where there are none:
> 
> 	int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
> 				int offset, int len)
> 	{
> 		/* Skip over the finished iovecs */
> 		while (offset >= iov->iov_len) {
> 			offset -= iov->iov_len;
> 			iov++;
> 		}
> 		[...]
> 
> So when offset == 0 and iov->iov_len == 0, we'll just run iov into random
> kernel memory until it hits something bad and dies in a BUG/panic - either
> killing the kernel or leaking memory and held locks.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

I sincerely think that memcpy_fromiovecend() is the part at fault here.

Defensively it should handle zero length copies, as memcpy_fromiovec()
right above it does.
