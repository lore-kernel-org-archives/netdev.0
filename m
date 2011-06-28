From: David Miller <davem@davemloft.net>
Subject: Re: ppp_deflate + kmalloc
Date: Mon, 27 Jun 2011 21:15:58 -0700 (PDT)
Message-ID: <20110627.211558.640845527643065916.davem@davemloft.net>
References: <BANLkTi=+2dqr1LPwG8MHpcYOyzJH57iavw@mail.gmail.com>
	<4E049900.4080402@workingcode.com>
	<BANLkTinMNb65nyo+Y8xhpTP2RC6x06ZJqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carlsonj@workingcode.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: mjackson220.list@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <BANLkTinMNb65nyo+Y8xhpTP2RC6x06ZJqQ@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Jackson <mjackson220.list@gmail.com>
Date: Sun, 26 Jun 2011 23:17:54 +0200

> Thanks for the advice. Hopefully we can indeed remove these obscure
> PPP options from our configuration - I'll look into that.
> 
> However, the point still stands that a 4th order kmalloc is likely to
> fail (even our "embedded" device has 256MB RAM and slub allocator,
> after all), and the page allocation code regards anything above order
> 3 as unrealistic and doesn't invoke the OOM to try to satisfy it, so
> my view remains that this should be changed to vmalloc.

PPP is not the only place in the tree where we potentially have
this problem.

crypto/deflate.c:	stream->workspace = kzalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
crypto/zlib.c:	stream->workspace = kzalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
drivers/net/bnx2x/bnx2x_main.c:	bp->strm->workspace = kmalloc(zlib_inflate_workspacesize(),
drivers/net/ppp_deflate.c:	state->strm.workspace = kmalloc(zlib_inflate_workspacesize(),
fs/binfmt_flat.c:	strm.workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
lib/zlib_inflate/infutil.c:	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);

A particularly problematic case is binfmt_flat.c since this is used on
systems which lack an MMU, and therefore for which vmalloc() is not
applicable.

What I'll do for now is transform all of the networking cases, but
someone should think seriously about the remaining cases.
