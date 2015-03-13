From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] ebpf: add prandom helper for packet sampling
Date: Fri, 13 Mar 2015 09:58:24 -0700
Message-ID: <55031730.5030303@plumgrid.com>
References: <cover.1426249641.git.daniel@iogearbox.net> <83348b7717b2f044140539fc7faa36bebcc3da58.1426249641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36382 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbbCMQ6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:58:44 -0400
Received: by iegc3 with SMTP id c3so117513116ieg.3
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 09:58:36 -0700 (PDT)
In-Reply-To: <83348b7717b2f044140539fc7faa36bebcc3da58.1426249641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/15 6:22 AM, Daniel Borkmann wrote:
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 3fa1af8..4efc41f 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -165,6 +165,7 @@ enum bpf_func_id {
>   	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
>   	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
>   	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
> +	BPF_FUNC_random,	  /* prandom() as u32 or u64 */

can you rename it to BPF_FUNC_get_random_value ?
I'd like names to be as descriptive as possible.
User space can pick any name it likes anyway:
static u64 (*my_foo_func)() = (void *) BPF_FUNC_get_random_value;

Also it will make the following less obscure:
 > +extern const struct bpf_func_proto bpf_random_proto;

'bpf_get_random_value_proto' looks better then 'bpf_random_proto' ;)

> +static u64 bpf_random(u64 dw, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	return prandom_u32() | (dw ? ((u64)prandom_u32() << 32) : 0);

can you make first argument to be a flag instead of bool ?
0 to return u32, 1 to return u64 and >=2 to be reserved and
return -EINVAL?
This way we can extend it later. For example 2 might return
8 truly random bytes from get_random_bytes_arch()

> +const struct bpf_func_proto bpf_random_proto = {
> +	.func		= bpf_random,
> +	.gpl_only	= false,

non-gpl allowed?
well I guess prandom_u32() is non-gpl either.
