From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next 2/3] bpf: permit multiple bpf attachments for a
 single perf event
Date: Mon, 23 Oct 2017 14:00:28 -0700
Message-ID: <21b52a2b-63f9-0a8c-e4e0-f4fe216a0ffe@fb.com>
References: <20171023175805.2898366-1-yhs@fb.com>
 <20171023175805.2898366-3-yhs@fb.com> <59EE568D.7040204@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>, <peterz@infradead.org>,
        <rostedt@goodmis.org>, <ast@fb.com>, <kafai@fb.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56080 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750835AbdJWVCE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 17:02:04 -0400
In-Reply-To: <59EE568D.7040204@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/23/17 1:52 PM, Daniel Borkmann wrote:
> On 10/23/2017 07:58 PM, Yonghong Song wrote:
> [...]
>>       __this_cpu_dec(bpf_prog_active);
>> @@ -741,3 +754,63 @@ const struct bpf_verifier_ops 
>> perf_event_verifier_ops = {
>>
>>   const struct bpf_prog_ops perf_event_prog_ops = {
>>   };
>> +
>> +static DEFINE_MUTEX(bpf_event_mutex);
>> +
>> +int perf_event_attach_bpf_prog(struct perf_event *event,
>> +               struct bpf_prog *prog)
>> +{
>> +    struct bpf_prog_array __rcu *old_array;
>> +    struct bpf_prog_array *new_array;
>> +    int ret;
>> +
>> +    mutex_lock(&bpf_event_mutex);
>> +
>> +    if (event->prog)
>> +        return -EEXIST;
> 
> Needs to go to out here, otherwise deadlock.

Thanks for catching this! Will fix this and the below one as well in the 
new revision.

> 
>> +
>> +    old_array = rcu_dereference_protected(event->tp_event->prog_array,
>> +                          lockdep_is_held(&bpf_event_mutex));
>> +    ret = bpf_prog_array_copy(old_array, NULL, prog, &new_array);
>> +    if (ret < 0)
>> +        goto out;
>> +
>> +    /* set the new array to event->tp_event and set event->prog */
>> +    event->prog = prog;
>> +    rcu_assign_pointer(event->tp_event->prog_array, new_array);
>> +
>> +    if (old_array)
>> +        bpf_prog_array_free(old_array);
>> +
>> +out:
>> +    mutex_unlock(&bpf_event_mutex);
>> +    return ret;
>> +}
>> +
>> +void perf_event_detach_bpf_prog(struct perf_event *event)
>> +{
>> +    struct bpf_prog_array __rcu *old_array;
>> +    struct bpf_prog_array *new_array;
>> +    int ret;
>> +
>> +    mutex_lock(&bpf_event_mutex);
>> +
>> +    if (!event->prog)
>> +        return;
> 
> Ditto.
> 
>> +
>> +    old_array = rcu_dereference_protected(event->tp_event->prog_array,
>> +                          lockdep_is_held(&bpf_event_mutex));
>> +
>> +    ret = bpf_prog_array_copy(old_array, event->prog, NULL, &new_array);
>> +    if (ret < 0) {
>> +        bpf_prog_array_delete_safe(old_array, event->prog);
>> +    } else {
>> +        rcu_assign_pointer(event->tp_event->prog_array, new_array);
>> +        bpf_prog_array_free(old_array);
>> +    }
>> +
>> +    bpf_prog_put(event->prog);
>> +    event->prog = NULL;
>> +
>> +    mutex_unlock(&bpf_event_mutex);
>> +}
> [...]
