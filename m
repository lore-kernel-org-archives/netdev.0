From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH iproute2 -master] tc, bpf: make sure relo is in relation
 with map section
Date: Thu, 21 Jan 2016 19:13:44 -0800
Message-ID: <20160122031343.GA6593@ast-mbp.thefacebook.com>
References: <6f06b68f62c89489ec1afea5ba1c328ef51efd10.1453418999.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	wangnan0@huawei.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32799 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbcAVDNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 22:13:44 -0500
Received: by mail-pf0-f176.google.com with SMTP id e65so34271381pfe.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 19:13:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6f06b68f62c89489ec1afea5ba1c328ef51efd10.1453418999.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2016 at 12:46:28AM +0100, Daniel Borkmann wrote:
> Add a test that symbol from relocation entry is actually related
> to map section and bail out with an error message if it's not the
> case; in relation to [1].
> 
>   [1] https://llvm.org/bugs/show_bug.cgi?id=26243
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks. Useful check.
Wang, we probably want something like this in libbpf as well.

> ---
>  tc/tc_bpf.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
> index 219ffa5..3c97cdb 100644
> --- a/tc/tc_bpf.c
> +++ b/tc/tc_bpf.c
> @@ -1336,6 +1336,12 @@ static int bpf_apply_relo_data(struct bpf_elf_ctx *ctx,
>  
>  		if (gelf_getsym(ctx->sym_tab, GELF_R_SYM(relo.r_info), &sym) != &sym)
>  			return -EIO;
> +		if (sym.st_shndx != ctx->sec_maps) {
> +			fprintf(stderr, "ELF contains non-map related relo data in "
> +				"entry %u pointing to section %u! Compiler bug?!\n",
> +				relo_ent, sym.st_shndx);
> +			return -EIO;
> +		}
>  
>  		rmap = sym.st_value / sizeof(struct bpf_elf_map);
>  		if (rmap >= ARRAY_SIZE(ctx->map_fds))
> -- 
> 1.9.3
> 
