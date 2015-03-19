From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 tip 2/8] tracing: attach BPF programs to kprobes
Date: Thu, 19 Mar 2015 08:33:24 -0700
Message-ID: <550AEC44.3060107@plumgrid.com>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>	<1426542584-9406-3-git-send-email-ast@plumgrid.com> <20150319110742.7dc9473d@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150319110742.7dc9473d-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/19/15 8:07 AM, Steven Rostedt wrote:
>>   struct trace_print_flags {
>>   	unsigned long		mask;
>> @@ -252,6 +253,7 @@ enum {
>>   	TRACE_EVENT_FL_WAS_ENABLED_BIT,
>>   	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
>>   	TRACE_EVENT_FL_TRACEPOINT_BIT,
>> +	TRACE_EVENT_FL_KPROBE_BIT,
>
> I think this should be broken up into two patches. One that adds the
> KPROBE_BIT flag to kprobe events, and the other that adds the bpf
> program.

sure. will do.

>
> There should be kerneldoc comments above this function.
>
>> +unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)

ok.

>> +	per_cpu(bpf_prog_active, cpu)--;
>
> Hmm, as cpu == smp_processor_id(), you should be using
> __this_cpu_inc_return(), and __this_cpu_dec().

yeah. picked a wrong place to copy paste from.
will do. good point.

>
> Why not just make kprobe_prog_funcs[] = {
> 	[BPF_FUNC_map_lookup_elem] = &bpf_map_lookup_elem_proto,
> 	[BPF_FUNC_map_update_elem] = &bpf_map_update_elem_proto,
> 	[BPF_FUNC_map_delete_elem] = &bpf_map_delete_elem_proto,
> 	[BPF_FUNC_probe_read] = &kprobe_prog_proto,
>
> And define kprobe_prog_proto separately.
>
> And then you don't need the switch statement, you could just use the
> if (func_id < 0 || func_id >= ARRAY_SIZE(kprobe_prog_funcs))
> 	return kprobe_prog_funcs[func_id];
>
> I think there's several advantages to my approach. One, is that you are
> not wasting memory with empty objects in the array. Also, if the array
> gets out of sync with the enum, it would be possible to return an empty
> object. That is, &kprobe_prog_funcs[out_of_sync_func_id], would not be
> NULL if in the future someone added an enum before BPF_FUNC_probe_read,
> and the func_id passed in is that enum.

yes! There will be gaps in func_ids, so that would have
been a bug. Thanks for catching it!
