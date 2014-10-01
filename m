From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH V1 net-next 2/4] net/mlx5_core: Use hardware registers
 description header file
Date: Wed, 1 Oct 2014 10:12:10 -0700
Message-ID: <CAADnVQ+0q=j9soWX-ge6Re4F6sDahq=O-Ptaguca8WUaTE-qQw@mail.gmail.com>
References: <1412169488-17500-1-git-send-email-eli@mellanox.com>
	<1412169488-17500-3-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Joe Perches <joe@perches.com>
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:39391 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbaJARML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 13:12:11 -0400
Received: by mail-qa0-f54.google.com with SMTP id i13so568699qae.13
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 10:12:11 -0700 (PDT)
In-Reply-To: <1412169488-17500-3-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 6:18 AM, Eli Cohen <eli@mellanox.com> wrote:
>
> Change-Id: Ieea94e4b329ec46902b1634cf66b0c3a04445a04

checkpatch errors on gerrit tags by default,
but I'm not sure what's an official stance on it, since I see patches
with this tag slip through here and there.

> +static inline void non_existent_function(void)
> +{
> +       pr_info("%s\n", __func__);
> +}
> +
> +static inline void non_existent_function_sz_align32(void)
> +{
> +       pr_info("%s\n", __func__);
> +}
> +
> +static inline void non_existent_function_const_overflow(void)
> +{
> +       pr_info("%s\n", __func__);
> +}
> +
> +static inline void memcpy_cpu_to_be32(void *dst, void *src, int len)
> +{
> +       u32 *dst_u32 = (u32 *)dst;
> +       int i;
> +
> +       memcpy(dst, src, len);
> +
> +       for (i = 0; i < (len >> 2); i++)
> +               dst_u32[i] = cpu_to_be32(dst_u32[i]);

it just assumes that pointers are aligned and len is power of 4 ?

> +}
> +
> +/* insert a value to a struct */
> +#define MLX5_SET(typ, p, fld, v) do { \
> +       if (__mlx5_st_sz_bits(typ) % 32) \
> +               non_existent_function_sz_align32();             \
> +       *((__be32 *)(p) + __mlx5_dw_off(typ, fld)) = \
> +       cpu_to_be32((be32_to_cpu(*((__be32 *)(p) + __mlx5_dw_off(typ, fld))) & \
> +                    (~__mlx5_dw_mask(typ, fld))) | (((v) & __mlx5_mask(typ, fld)) \
> +                    << __mlx5_dw_bit_off(typ, fld))); \
> +} while (0)
> +
> +#define MLX5_GET(typ, p, fld) ((be32_to_cpu(*((__be32 *)(p) +\
> +__mlx5_dw_off(typ, fld))) >> __mlx5_dw_bit_off(typ, fld)) & \
> +__mlx5_mask(typ, fld))
> +
> +#define MLX5_GET_PR(typ, p, fld) ({ \
> +       u32 ___t = MLX5_GET(typ, p, fld); \
> +       pr_debug(#fld " = 0x%x\n", ___t); \
> +       ___t; \
> +})
> +
> +#define MLX5_SET64(typ, p, fld, v) do { \
> +       if (__mlx5_bit_sz(typ, fld) != 64) \
> +               non_existent_function(); \
> +       else if (__mlx5_bit_off(typ, fld) % 64) \
> +               non_existent_function(); \
> +       else \
> +               *((__be64 *)(p) + __mlx5_64_off(typ, fld)) = cpu_to_be64(v); \
> +} while (0)

is it possible to use BUILD_BUG_ON instead of runtime pr_info() ?
