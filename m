From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v7 net-next 00/28] BPF syscall
Date: Tue, 26 Aug 2014 21:57:07 -0700
Message-ID: <CAMEtUuw1n1HzAeyKFj9=nGq7RKZq7TADS-6M_BkHbTsWJ_Gm-Q@mail.gmail.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
	<CALCETrX2MzNxQ1ogt+Qx8iPjUe+z0gN6ZLwu9nAcZzTN+D+iYw@mail.gmail.com>
	<CAMEtUuwYqJVUuZxPBKy57NonWF+X_5vkNx4uSEx_d=-xBka1Kg@mail.gmail.com>
	<CALCETrWs9GRufGKxAoV628bh1f3HObkxNQuW3tYRt2rFwNAbxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chema Gonzalez <chema@google.com>,
	Namhyung Kim <namhyung@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Network Development <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Ingo Molnar <mingo@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:62871 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbaH0E5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 00:57:09 -0400
Received: by mail-wg0-f47.google.com with SMTP id b13so15457074wgh.30
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 21:57:07 -0700 (PDT)
In-Reply-To: <CALCETrWs9GRufGKxAoV628bh1f3HObkxNQuW3tYRt2rFwNAbxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2014 at 9:49 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Tue, Aug 26, 2014 at 9:35 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Tue, Aug 26, 2014 at 8:56 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> On Aug 26, 2014 7:29 PM, "Alexei Starovoitov" <ast@plumgrid.com> wrote:
>>>>
>>>> Hi Ingo, David,
>>>>
>>>> posting whole thing again as RFC to get feedback on syscall only.
>>>> If syscall bpf(int cmd, union bpf_attr *attr, unsigned int size) is ok,
>>>> I'll split them into small chunks as requested and will repost without RFC.
>>>
>>> IMO it's much easier to review a syscall if we just look at a
>>> specification of what it does.  The code is, in some sense, secondary.
>>
>> 'specification of what it does'... hmm, you mean beyond what's
>> there in commit logs and in Documentation/networking/filter.txt ?
>> Aren't samples at the end give an idea on 'what it does'?
>> I'm happy to add 'specification', I just don't understand yet what
>> it suppose to talk about beyond what's already written.
>> I understand that the patches are missing explanation on 'why'
>> the syscall is being added, but I don't think it's what you're asking...
>
> I mean a hopefully short document that defines what the syscall does.
> It should be precise enough that one could, in principle, implement
> the syscall just by reading the document and that one could use the
> syscall just by reading the document.
>
> Given that there's a whole instruction set to go with it, it may end
> up being moderately complicated or saying things like "see this other
> thing for a description of the instruction set" and "there are some
> extensible sets of functions you can call with it".

I'm still lost.

Here is the quote from Documentation/networking/filter.txt
"
'maps' is a generic storage of different types for sharing data between kernel
and userspace.

The maps are accessed from user space via BPF syscall,
which has commands:
- create a map with given type and attributes
  map_fd = bpf(BPF_MAP_CREATE, union bpf_attr *attr, u32 size)
  using attr->map_type, attr->key_size, attr->value_size, attr->max_entries
  returns process-local file descriptor or negative error

- lookup key in a given map
  err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key, attr->value
  returns zero and stores found elem into value or negative error

- create or update key/value pair in a given map
  err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key, attr->value
  returns zero or negative error

- find and delete element by key in a given map
  err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
  using attr->map_fd, attr->key

- to delete map: close(fd)
  Exiting process will delete maps automatically

userspace programs uses this API to create/populate/read
maps that eBPF programs are concurrently updating.
"
and more in commit log:
"
- load eBPF program
  fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)

  where 'attr' is
  struct {
      enum bpf_prog_type prog_type;
      __u32 insn_cnt;
      struct bpf_insn __user *insns;
      const char __user *license;
  };
  insns - array of eBPF instructions
  license - must be GPL compatible to call helper functions marked gpl_only

- unload eBPF program
  close(fd)
"

Isn't it short and describes what it does?
Do you want me to describe what eBPF program can do?
