From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next 2/3] bpf: permit multiple bpf attachments for a
 single perf event
Date: Thu, 26 Oct 2017 09:42:57 -0700
Message-ID: <99987cd2-2b48-6f29-ba1e-9f9790c10299@fb.com>
References: <20171023175805.2898366-1-yhs@fb.com>
 <20171023175805.2898366-3-yhs@fb.com>
 <20171026135641.GT3165@worktop.lehotels.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rostedt@goodmis.org>, <ast@fb.com>, <daniel@iogearbox.net>,
        <kafai@fb.com>, <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40504 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932127AbdJZQnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 12:43:47 -0400
In-Reply-To: <20171026135641.GT3165@worktop.lehotels.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/26/17 6:56 AM, Peter Zijlstra wrote:
> On Mon, Oct 23, 2017 at 10:58:04AM -0700, Yonghong Song wrote:
>> This patch enables multiple bpf attachments for a
>> kprobe/uprobe/tracepoint single trace event.
> 
> This forgets to explain _why_ this is a good thing to do.

Before this patch, each perf tracepoint event (tp_event)
can only attach one bpf program. Each tp_event is internally
identifiable through a config ID, through which perf_event_open
associates to a particular tp_event.

Only one ID is associated with each kernel tracepoint. We have
use cases that an application already attached a bpf program to
a particular kernel tracepoint (e.g., block:block_rq_issue).
Another unrelated application tries to attach its own bpf program
to the same tracepoint but failed. This patch removed such
a limitation and permits more than one bpf programs attaching
to the same tracepoint.

Strictly speaking, kprobe/uprobe does not need this as users
can always create a new tp_event attaching to the same kprobe/uprobe.
However, since in kernel kprobe/uprobe/tracepoint shared the same
tp_event infrastructure, adding this support avoid code/data_structure
multiplexing with just a little non-configuration runtime overhead
(going through a one-element pointer array vs. a pointer).

Sorry about missing this piece in the commit message.
Will try to do better next time.

> 
>> +static DEFINE_MUTEX(bpf_event_mutex);
>> +
>> +int perf_event_attach_bpf_prog(struct perf_event *event,
>> +			   struct bpf_prog *prog)
>> +{
>> +	struct bpf_prog_array __rcu *old_array;
>> +	struct bpf_prog_array *new_array;
>> +	int ret;
>> +
>> +	mutex_lock(&bpf_event_mutex);
>> +
>> +	if (event->prog)
>> +		return -EEXIST;
>> +
>> +	old_array = rcu_dereference_protected(event->tp_event->prog_array,
>> +					      lockdep_is_held(&bpf_event_mutex));
> 
> Since all modifications to prog_array are serialized by this one mutex;
> you don't need rcu_dereference() here, there are no possible ordering
> problems.

Yes, will fix this in a subsequent patch.

>> +	ret = bpf_prog_array_copy(old_array, NULL, prog, &new_array);
>> +	if (ret < 0)
>> +		goto out;
>> +
>> +	/* set the new array to event->tp_event and set event->prog */
>> +	event->prog = prog;
>> +	rcu_assign_pointer(event->tp_event->prog_array, new_array);
>> +
>> +	if (old_array)
>> +		bpf_prog_array_free(old_array);
>> +
>> +out:
> 
> Its customary to call that unlock:

Yes. Will fix it in a subsequent patch.

> 
>> +	mutex_unlock(&bpf_event_mutex);
>> +	return ret;
>> +}
