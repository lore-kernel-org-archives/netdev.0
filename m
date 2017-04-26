From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Wed, 26 Apr 2017 14:25:55 -0700
Message-ID: <20170426212553.fq3uyhktfxvn36rv@ast-mbp>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
 <20170426182419.14574-7-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.com,
        jbenc@redhat.com, aconole@bytheb.org,
        Martin KaFai Lau <kafai@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33612 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030531AbdDZVZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 17:25:58 -0400
Received: by mail-pf0-f194.google.com with SMTP id c198so2851449pfc.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 14:25:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170426182419.14574-7-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 08:24:19PM +0200, Hannes Frederic Sowa wrote:
>  
> +static const char *bpf_type_string(enum bpf_prog_type type)
> +{
> +	static const char *bpf_type_names[] = {
> +#define X(type) #type
> +		BPF_PROG_TYPES
> +#undef X
> +	};
> +
> +	if (type >= ARRAY_SIZE(bpf_type_names))
> +		return "<unknown>";
> +
> +	return bpf_type_names[type];
> +}
> +
>  static int ebpf_proc_show(struct seq_file *s, void *v)
>  {
> +	struct bpf_prog *prog;
> +	struct bpf_prog_aux *aux;
> +	char prog_tag[sizeof(prog->tag) * 2 + 1] = { };
> +
>  	if (v == SEQ_START_TOKEN) {
> -		seq_printf(s, "# tag\n");
> +		seq_printf(s, "# tag\t\t\ttype\t\t\truntime\tcap\tmemlock\n");
>  		return 0;
>  	}
>  
> +	aux = v;
> +	prog = aux->prog;
> +
> +	bin2hex(prog_tag, prog->tag, sizeof(prog->tag));
> +	seq_printf(s, "%s\t%s\t%s\t%s\t%llu\n", prog_tag,
> +		   bpf_type_string(prog->type),
> +		   prog->jited ? "jit" : "int",
> +		   prog->priv_cap_sys_admin ? "priv" : "unpriv",
> +		   prog->pages * 1ULL << PAGE_SHIFT);

As I said several times already I'm strongly against procfs
style of exposing information about the programs.
I don't want this to become debugfs for bpf.
Maintaining the list of all loaded programs is fine
and we need a way to iterate through them, but procfs
is obviously not the interface to do that.
Programs/maps are binary whereas any fs interface is text.
It also doesn't scale with large number of programs/maps.
I prefer Daniel's suggestion on adding 'get_next' like API.
Also would be good if you can wait for Martin to finish his
prog->handle/id patches. Then user space will be able
to iterate through all the progs/maps and fetch all info about
them through syscall in extensible way.
And you wouldn't need to abuse kallsyms list for different purpose.
