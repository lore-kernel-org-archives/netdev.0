From: Andy Zhou <azhou@nicira.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 1/2] BPF: add a
 new BPF program type BPF_PROG_TYPE_OPENVSWITCH
Date: Thu, 5 Feb 2015 11:47:15 -0800
Message-ID: <CACzMAJ+AhoDs487TN02bawS9fWCQ26FmGwOvw1C79PW5iX=QwA@mail.gmail.com>
References: <1423090122-19807-1-git-send-email-azhou@nicira.com>
	<1423090122-19807-2-git-send-email-azhou@nicira.com>
	<20150205144828.GF5546@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:33093 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751615AbbBETrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:47:16 -0500
Received: by mail-ob0-f181.google.com with SMTP id vb8so8891384obc.12
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:47:15 -0800 (PST)
In-Reply-To: <20150205144828.GF5546@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 6:48 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
> On 02/04/15 at 02:48pm, Andy Zhou wrote:
>>  struct bpf_verifier_ops {
>>       /* return eBPF function prototype for verification */
>> -     const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
>> +     const struct bpf_func_proto *(*get_func_proto)(int func_id);
>
> This change should maybe go in a separate commit.
Agreed.  Ideally, each program type should have its own func_id space. Current
registration does not allow this. Should this be added?

In the interest of reusing common helper functions, should we also consider
partition the func_id space into common ones and program type specific ones?
For example, the prink like function can be specified the common func_id space.

>
>> +static const struct bpf_func_proto *ovs_func_proto(int func_id)
>> +{
>> +     switch (func_id) {
>> +     case OVS_BPF_FUNC_output:
>> +             return &bpf_helper_output_proto;
>> +     default:
>> +             return NULL;
>> +     }
>> +}
>
> You'd still want to use the map helpers so it seems like we should
> change the bpf verified to verify against both a global and type
> specific list unless we want to add all the map helpers to
> ovs_func_proto as well.

It is not clear what OVS can benefit from the map helpers.  Map provides
a fixed sized array.  OVS data structure, such as flow, are more
dynamic and non-contiguous in memory.

Is extending BPF to allow for passing those dynamic objects a reasonable
direction?

>
>> +static bool test_is_valid_access(int off, int size, enum bpf_access_type type)
>> +{
>> +     const struct bpf_context_access *access;
>> +
>> +     if (off < 0 || off >= ARRAY_SIZE(bpf_ctx_access))
>> +             return false;
>> +
>> +     access = &bpf_ctx_access[off];
>> +     if (access->size == size && (access->type & type))
>> +             return true;
>> +
>> +     return false;
>> +}
>
> OK. I see why you kept ctxt simple at first ;-)
