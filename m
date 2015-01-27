From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 06/10] net/mlx4_core: Fix struct mlx4_vhcr_cmd
 to make implicit padding explicit
Date: Tue, 27 Jan 2015 09:43:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
 <1422351179-27284-7-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>
To: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:50556 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511AbbA0Jni convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 04:43:38 -0500
In-Reply-To: <1422351179-27284-7-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai
> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> Struct mlx4_vhcr was implicitly padded by the gcc compiler.
> This commit makes that padding explicit, to prevent issues with
> changing compilers. Note that we added the padding dword (rather
> than simply packing the structure) in order to maintain compatibility
> with previous kernels.

It isn't a 'compiler' option, but depends on the architecture.

> Reported-by: Alexander Schmidt <alexs@linux.vnet.ibm.com>
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> index 096a81c..595e18a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> @@ -196,13 +196,14 @@ struct mlx4_vhcr {
>  struct mlx4_vhcr_cmd {
>  	__be64 in_param;
>  	__be32 in_modifier;
> +	u32 reserved1;

Adding a pad here changes the alignment on most 32bit architectures (eg i386)
where 64bit integers are only aligned to 4 byte boundaries.
So you are not 'maintaining compatibility with previous kernels'.

>  	__be64 out_param;
>  	__be16 token;
>  	u16 reserved;
>  	u8 status;
>  	u8 flags;
>  	__be16 opcode;
> -};
> +} __packed;

Don't add '__packed' unless you expect the structure to be misaligned
in memory.
On systems that fault mis-aligned memory requests you've requested the
compiler generate code to read/write everything using byte sized memory
accesses and a lot of shifting and masking.

	David
