From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 06/10] net/mlx4_core: Fix struct mlx4_vhcr_cmd
 to make implicit padding explicit
Date: Tue, 27 Jan 2015 15:00:27 +0200
Message-ID: <20150127150027.184ba5e8@jpm-OptiPlex-GX620>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
	<1422351179-27284-7-git-send-email-amirv@mellanox.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:37218 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758849AbbA0M71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:59:27 -0500
Received: by mail-wg0-f48.google.com with SMTP id x12so14589282wgg.7
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 04:59:26 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2015 09:43:27 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Amir Vadai
> > From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> > 
> > Struct mlx4_vhcr was implicitly padded by the gcc compiler.
> > This commit makes that padding explicit, to prevent issues with
> > changing compilers. Note that we added the padding dword (rather
> > than simply packing the structure) in order to maintain
> > compatibility with previous kernels.
> 
> It isn't a 'compiler' option, but depends on the architecture.
> 
> > Reported-by: Alexander Schmidt <alexs@linux.vnet.ibm.com>
> > Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/mlx4.h | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> > b/drivers/net/ethernet/mellanox/mlx4/mlx4.h index 096a81c..595e18a
> > 100644 --- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> > +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> > @@ -196,13 +196,14 @@ struct mlx4_vhcr {
> >  struct mlx4_vhcr_cmd {
> >  	__be64 in_param;
> >  	__be32 in_modifier;
> > +	u32 reserved1;
> 
> Adding a pad here changes the alignment on most 32bit architectures
> (eg i386) where 64bit integers are only aligned to 4 byte boundaries.
> So you are not 'maintaining compatibility with previous kernels'.

You are correct. However, this structure is used ONLY for communication
between a Host and a Guest on that host.  In the current code (before
this fix), it was not possible to run a 32-bit Guest over a 64-bit Host,
because of the implicit padding that occurred on the 64-bit Host
and did not occur on the 32-bit Guest.

With this fix, a 32-bit Guest (with the fix) will be able to run over a
64-bit Host (with or without the fix).

The padding dword thus serves to maintain 64-bit Host (old or
new) compatibility with 64-bit Guests (old or new), while allowing
64-bit Hosts to support new 32-bit Guests.

I'll fix the changelog for the next submission.

> 
> >  	__be64 out_param;
> >  	__be16 token;
> >  	u16 reserved;
> >  	u8 status;
> >  	u8 flags;
> >  	__be16 opcode;
> > -};
> > +} __packed;
> 
> Don't add '__packed' unless you expect the structure to be misaligned
> in memory.
> On systems that fault mis-aligned memory requests you've requested the
> compiler generate code to read/write everything using byte sized
> memory accesses and a lot of shifting and masking.

OK, I'll remove the "packed" in the next submission, since with the
padding dword 64-bit arch and 32-bit arch compilers should produce the
same offsets.

> 
> 	David
> 

Thanks for the review!

-Jack
