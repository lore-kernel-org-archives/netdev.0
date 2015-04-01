From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Tue, 31 Mar 2015 22:16:49 -0700
Message-ID: <551B7F41.3080203@plumgrid.com>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, tgraf@suug.ch, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35773 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbDAFQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 01:16:53 -0400
Received: by ierf6 with SMTP id f6so34249283ier.2
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 22:16:52 -0700 (PDT)
In-Reply-To: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/15 3:35 PM, Daniel Borkmann wrote:
> +static inline void act_update_drop_map(void)
> +{
> +	uint32_t *count, cpu = get_smp_processor_id();
> +
> +	count = bpf_map_lookup_elem(&map_drops, &cpu);
> +	if (count)
> +		__sync_fetch_and_add(count, 1);

since this function demonstrates poor man's per-cpu counters we can use
regular *count++ instead of atomic.
Just picking nits :)

> +__section("action-rand") int act_rand_main(struct __sk_buff *skb)
> +{
> +	/* Sorry, we're near event horizon ... */
> +	if ((get_prandom_u32() & 3) == 0) {
> +		act_update_drop_map();
> +		return TC_ACT_SHOT;
> +	}

didn't get the joke. Is it April 1st yet? :)

> +/* tc ELF map ABI */
> +struct bpf_elf_map {
> +	uint32_t type;
> +	uint32_t id;
> +	uint32_t size_key;
> +	uint32_t size_value;
> +	uint32_t max_elem;
> +};

can you change 'id' being last, so that TC+bpf programs from
samples/bpf/ that don't have 'id' concept can also be loaded?

> +#ifndef min
> +# define min(x, y) ({			\
> +	typeof(x) _min1 = (x);		\
> +	typeof(y) _min2 = (y);		\
> +	(void) (&_min1 == &_min2);	\
> +	_min1 < _min2 ? _min1 : _min2; })
> +#endif
...
> +#ifndef min
> +# define min(x, y) ({			\
> +	typeof(x) _min1 = (x);		\
> +	typeof(y) _min2 = (y);		\
> +	(void) (&_min1 == &_min2);	\
> +	_min1 < _min2 ? _min1 : _min2; })
> +#endif

two 'min' macros in different files?

> -static inline int bpf_open_object(const char *path, enum bpf_prog_type type)
> +static inline int bpf_open_object(const char *path, enum bpf_prog_type type,
> +				  const char *sec)
>   {
>   	errno = ENOSYS;
>   	return -1;
>   }

while playing with it, I hit the ENOSYS first, since my user space
is quite old. Can you add a human readable printf message here and other
places, so we don't have to recompile tc with -g and run gdb on it?
I think it will help distributions to configure dependencies of iproute2
as well.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Great work! Thanks a lot!
