From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 1/2] BPF: add a
 new BPF program type BPF_PROG_TYPE_OPENVSWITCH
Date: Thu, 5 Feb 2015 12:30:34 -0800
Message-ID: <CAADnVQ+KY2kWtpwYJn1049YNfy9ZVsdVZRDLyQfZwhvD2P3DJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@noironetworks.com>,
	"dev@openvswitch.com" <dev@openvswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:63502 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbBEUaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 15:30:55 -0500
Received: by mail-qg0-f53.google.com with SMTP id f51so7988595qge.12
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 12:30:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 11:47 AM, Andy Zhou <azhou@nicira.com> wrote:
> On Thu, Feb 5, 2015 at 6:48 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
>> On 02/04/15 at 02:48pm, Andy Zhou wrote:
>>>  struct bpf_verifier_ops {
>>>       /* return eBPF function prototype for verification */
>>> -     const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
>>> +     const struct bpf_func_proto *(*get_func_proto)(int func_id);
>>
>> This change should maybe go in a separate commit.
> Agreed.  Ideally, each program type should have its own func_id space. Current
> registration does not allow this. Should this be added?
>
> In the interest of reusing common helper functions, should we also consider
> partition the func_id space into common ones and program type specific ones?
> For example, the prink like function can be specified the common func_id space.

I don't like per-program_type func_ids, since overlapping ids is
a debugging headache and it encourages hiding ids instead of
clearly adding them to uapi's enum bpf_func_id.
per-program type ids also make it impossible to share common helper ids
which is already the case between socket and tracing prog types.
Having one place and one enum for all ids helps to keep
exposed user helpers under control.

>>> +static const struct bpf_func_proto *ovs_func_proto(int func_id)
>>> +{
>>> +     switch (func_id) {
>>> +     case OVS_BPF_FUNC_output:
>>> +             return &bpf_helper_output_proto;
>>> +     default:
>>> +             return NULL;
>>> +     }
>>> +}
>>
>> You'd still want to use the map helpers so it seems like we should
>> change the bpf verified to verify against both a global and type
>> specific list unless we want to add all the map helpers to
>> ovs_func_proto as well.
>
> It is not clear what OVS can benefit from the map helpers.  Map provides
> a fixed sized array.  OVS data structure, such as flow, are more
> dynamic and non-contiguous in memory.

that's a misunderstanding.
maps can be different types including rhashtable type.
Actually I was waiting for rhashtable to stabilize
before adding it as new map type ;)
There is 'max_entries' limit that must be there for safety reasons,
but it doesn't mean that all entries are always allocated at
init time and never change.
contiguous vs non-contiguous is also internal detail of map
implementation.
