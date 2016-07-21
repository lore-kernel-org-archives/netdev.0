From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx5e: Query minimum required header
 copy during xmit
Date: Thu, 21 Jul 2016 09:41:28 -0700
Message-ID: <20160721164126.GA91555@ast-mbp.thefacebook.com>
References: <1469053202-30649-1-git-send-email-saeedm@mellanox.com>
 <1469053202-30649-3-git-send-email-saeedm@mellanox.com>
 <20160721051529.GA89065@ast-mbp.thefacebook.com>
 <CALzJLG8jy-eRe9g93h1ChSdVN3ynON5f=KXH5_5rVMWqvn0-=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33291 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267AbcGUQlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 12:41:55 -0400
Received: by mail-yw0-f196.google.com with SMTP id z8so4253787ywa.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 09:41:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG8jy-eRe9g93h1ChSdVN3ynON5f=KXH5_5rVMWqvn0-=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 11:22:32AM +0300, Saeed Mahameed wrote:
> On Thu, Jul 21, 2016 at 8:15 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Thu, Jul 21, 2016 at 01:20:02AM +0300, Saeed Mahameed wrote:
> >> From: Hadar Hen Zion <hadarh@mellanox.com>
> >>
> >> Add support for query the minimum inline mode from the Firmware.
> >> It is required for correct TX steering according to L3/L4 packet
> >> headers.
> >>
> >> Each send queue (SQ) has inline mode that defines the minimal required
> >> headers that needs to be copied into the SQ WQE.
> >> The driver asks the Firmware for the wqe_inline_mode device capability
> >> value.  In case the device capability defined as "vport context" the
> >> driver must check the reported min inline mode from the vport context
> >> before creating its SQs.
> >>
> >> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> >> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> > ...
> >> +     int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
> >> +     u32 *out;
> >> +
> >> +     out = mlx5_vzalloc(outlen);
> >> +     if (!out)
> >> +             return;
> >
> > Just discovered this...
> > outlen is a small constant here, yet you want to try to vmalloc it?
> > What is the point?
> > There are 67 places in mlx5 where failed kmalloc is retried with
> > vmalloc... was that path ever tested?
> 
> The point is that there are a lot of places in the code that want to
> allocate huge commands and mlx5_vzalloc is a nice black box that
> provides the method to allocate such huge chunks of memory.
> 
> Now sometimes people tend to reuse same pieces of code for code consistency.
> 
> I don't see any harm from doing that.

There are several *_kvzalloc() helpers in the kernel. Their main purpose
is to allocate large chunks of contigous memory.
mlx5 driver just calls mlx5_vzalloc everywhere even when the size is known
and it's small. There is a lot of harm in such 'consistency':
. if we're under memory pressure and small size kmalloc fails, it will hurt
  the system if vmalloc somehow finds a free page for this small alloc
. the memory returned by vmalloc is virtually contiguous, whereas the driver
  takes it and puts in all sort of hardware things. I'm not sure why I didn't
  blow up yet
In general you should never call vmalloc with anything smaller than page size.
