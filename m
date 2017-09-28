From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next] libbpf: use map_flags when creating maps
Date: Thu, 28 Sep 2017 13:33:00 -0400
Message-ID: <CAEfhGiwai3fZsWPx--Axyc1n4+WRwxeFO+uLgQKbQ-8wiJqtAw@mail.gmail.com>
References: <20170927140458.44337-1-kraigatgoog@gmail.com> <f7d4addc-9f6a-4ddb-b383-f255cd2f728f@fb.com>
 <59CC201C.6090502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36086 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751945AbdI1RdD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:33:03 -0400
Received: by mail-qk0-f193.google.com with SMTP id j5so919908qkd.3
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 10:33:03 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by smtp.gmail.com with ESMTPSA id j92sm1354809qtb.27.2017.09.28.10.33.01
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 10:33:02 -0700 (PDT)
Received: by mail-qk0-f169.google.com with SMTP id o77so2150608qke.9
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 10:33:01 -0700 (PDT)
In-Reply-To: <59CC201C.6090502@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 6:03 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 09/27/2017 06:29 PM, Alexei Starovoitov wrote:
>>
>> On 9/27/17 7:04 AM, Craig Gallek wrote:
>>>
>>> From: Craig Gallek <kraig@google.com>
>>>
>>> This extends struct bpf_map_def to include a flags field.  Note that
>>> this has the potential to break the validation logic in
>>> bpf_object__validate_maps and bpf_object__init_maps as they use
>>> sizeof(struct bpf_map_def) as a minimal allowable size of a map section.
>>> Any bpf program compiled with a smaller struct bpf_map_def will fail this
>>> check.
>>>
>>> I don't believe this will be an issue in practice as both compile-time
>>> definitions of struct bpf_map_def (in samples/bpf/bpf_load.h and
>>> tools/testing/selftests/bpf/bpf_helpers.h) have always been larger
>>> than this newly updated version in libbpf.h.
>>>
>>> Signed-off-by: Craig Gallek <kraig@google.com>
>>> ---
>>>  tools/lib/bpf/libbpf.c | 2 +-
>>>  tools/lib/bpf/libbpf.h | 1 +
>>>  2 files changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
>>> index 35f6dfcdc565..6bea85f260a3 100644
>>> --- a/tools/lib/bpf/libbpf.c
>>> +++ b/tools/lib/bpf/libbpf.c
>>> @@ -874,7 +874,7 @@ bpf_object__create_maps(struct bpf_object *obj)
>>>                        def->key_size,
>>>                        def->value_size,
>>>                        def->max_entries,
>>> -                      0);
>>> +                      def->map_flags);
>>>          if (*pfd < 0) {
>>>              size_t j;
>>>              int err = *pfd;
>>> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
>>> index 7959086eb9c9..6e20003109e0 100644
>>> --- a/tools/lib/bpf/libbpf.h
>>> +++ b/tools/lib/bpf/libbpf.h
>>> @@ -207,6 +207,7 @@ struct bpf_map_def {
>>>      unsigned int key_size;
>>>      unsigned int value_size;
>>>      unsigned int max_entries;
>>> +    unsigned int map_flags;
>>>  };
>>
>>
>> yes it will break loading of pre-compiled .o
>> Instead of breaking, let's fix the loader to do it the way
>> samples/bpf/bpf_load.c does.
>> See commit 156450d9d964 ("samples/bpf: make bpf_load.c code compatible
>> with ELF maps section changes")
>
>
> +1, iproute2 loader also does map spec fixup
>
> For libbpf it would be good also such that it reduces the diff
> further between the libbpf and bpf_load so that it allows move
> to libbpf for samples in future.

Fair enough, I'll try to get this to work more dynamically.  I did
noticed that the fields of struct bpf_map_def in
selftests/.../bpf_helpers.h and iproute2's struct bpf_elf_map have
diverged. The flags field is the only thing missing from libbpf right
now (and they are at the same offset for both), so it won't be an
issue for this change, but it is going to make unifying all of these
things under libbpf not trivial at some point...
