From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Thu, 27 Apr 2017 15:28:50 +0200
Message-ID: <fed27cb3-4509-8cd1-c0a3-6b7ea8cb5831@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
 <20170426182419.14574-7-hannes@stressinduktion.org>
 <20170426212553.fq3uyhktfxvn36rv@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.com,
        jbenc@redhat.com, aconole@bytheb.org,
        Martin KaFai Lau <kafai@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51799 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938098AbdD0N2x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 09:28:53 -0400
In-Reply-To: <20170426212553.fq3uyhktfxvn36rv@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.04.2017 23:25, Alexei Starovoitov wrote:
> On Wed, Apr 26, 2017 at 08:24:19PM +0200, Hannes Frederic Sowa wrote:
>>  
>> +static const char *bpf_type_string(enum bpf_prog_type type)
>> +{
>> +	static const char *bpf_type_names[] = {
>> +#define X(type) #type
>> +		BPF_PROG_TYPES
>> +#undef X
>> +	};
>> +
>> +	if (type >= ARRAY_SIZE(bpf_type_names))
>> +		return "<unknown>";
>> +
>> +	return bpf_type_names[type];
>> +}
>> +
>>  static int ebpf_proc_show(struct seq_file *s, void *v)
>>  {
>> +	struct bpf_prog *prog;
>> +	struct bpf_prog_aux *aux;
>> +	char prog_tag[sizeof(prog->tag) * 2 + 1] = { };
>> +
>>  	if (v == SEQ_START_TOKEN) {
>> -		seq_printf(s, "# tag\n");
>> +		seq_printf(s, "# tag\t\t\ttype\t\t\truntime\tcap\tmemlock\n");
>>  		return 0;
>>  	}
>>  
>> +	aux = v;
>> +	prog = aux->prog;
>> +
>> +	bin2hex(prog_tag, prog->tag, sizeof(prog->tag));
>> +	seq_printf(s, "%s\t%s\t%s\t%s\t%llu\n", prog_tag,
>> +		   bpf_type_string(prog->type),
>> +		   prog->jited ? "jit" : "int",
>> +		   prog->priv_cap_sys_admin ? "priv" : "unpriv",
>> +		   prog->pages * 1ULL << PAGE_SHIFT);
> 
> As I said several times already I'm strongly against procfs
> style of exposing information about the programs.

I would not expand procfs interface to dump ebpf bytecode or jitcode,
albeit I would prefer a file system abstraction for that.

> I don't want this to become debugfs for bpf.

Right now it just prints a list of ebpf programs. You reject of where
things are going or do you already reject this particular patch?

> Maintaining the list of all loaded programs is fine
> and we need a way to iterate through them, but procfs
> is obviously not the interface to do that.
> Programs/maps are binary whereas any fs interface is text.

It should give admins only a high level overview of what is going on in
there system. I don't want o print any kind of opcodes there, just
giving people the possibility to see what is going on.

> It also doesn't scale with large number of programs/maps.
> I prefer Daniel's suggestion on adding 'get_next' like API.
> Also would be good if you can wait for Martin to finish his
> prog->handle/id patches. Then user space will be able
> to iterate through all the progs/maps and fetch all info about
> them through syscall in extensible way.
> And you wouldn't need to abuse kallsyms list for different purpose.

I don't buy the scalability argument:

What is the scalability issue with this O(1) approach on loading and
O(n) (but also without any locks held) on dumping? You can't do any
better. You can even dump several programs with one syscall instead of
slowly iterating over them.

Certainly I can wait with those patches until Martin presented his patches.

And regarding abusing the list, I just renamed it. If you think I abuse
something I can also add another list like bpf_prog_id patches do?

Bye bye,
Hannes
