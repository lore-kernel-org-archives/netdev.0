From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Mon, 5 Oct 2015 14:32:29 -0700
Message-ID: <5612EC6D.6080301@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <CAGXu5j+s+3Z6=WKKNGouNijNKcrq5o_n9-BD85Nabd-_GtL+ag@mail.gmail.com>
 <5612E7C4.1010306@plumgrid.com>
 <CALCETrXUqYmwRhiFLnzWDrnVX5NdpoAnSggy8pxhzRPP86i5XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrXUqYmwRhiFLnzWDrnVX5NdpoAnSggy8pxhzRPP86i5XA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/5/15 2:16 PM, Andy Lutomirski wrote:
> On Mon, Oct 5, 2015 at 2:12 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On 10/5/15 2:00 PM, Kees Cook wrote:
>>>
>>> On Mon, Oct 5, 2015 at 1:48 PM, Alexei Starovoitov<ast@plumgrid.com>
>>> wrote:
>>>>
>>>>> In order to let unprivileged users load and execute eBPF programs
>>>>> teach verifier to prevent pointer leaks.
>>>>> Verifier will prevent
>>>>> - any arithmetic on pointers
>>>>>    (except R10+Imm which is used to compute stack addresses)
>>>>> - comparison of pointers
>>>>> - passing pointers to helper functions
>>>>> - indirectly passing pointers in stack to helper functions
>>>>> - returning pointer from bpf program
>>>>> - storing pointers into ctx or maps
>>>
>>> Does the arithmetic restriction include using a pointer as an index to
>>> a maps-based tail call? I'm still worried about pointer-based
>>> side-effects.
>>
>>
>> the array maps that hold FDs (BPF_MAP_TYPE_PROG_ARRAY and
>> BPF_MAP_TYPE_PERF_EVENT_ARRAY) don't have lookup/update accessors
>> from the program side, so programs cannot see or manipulate
>> those pointers.
>> For the former only bpf_tail_call() is allowed that takes integer
>> index and jumps to it. And the latter map accessed with
>> bpf_perf_event_read() that also takes index only (this helper
>> is not available to socket filters anyway).
>> Also bpf_tail_call() can only jump to the program of the same type.
>> So I'm quite certain it's safe.
>
> At some point there will be an unprivileged way to create a map,
> though, and we don't want to let pointers get poked into the map.

yes. exactly. With these two patches non-root can create a map
against memlock user limit and have a program store bytes into it
(like data from network packet), but it cannot store pointers into it.
That's covered by test "unpriv: write pointer into map elem value"
I've added new tests for all cases that can 'leak pointer':
  unpriv: return pointer OK
  unpriv: add const to pointer OK
  unpriv: add pointer to pointer OK
  unpriv: neg pointer OK
  unpriv: cmp pointer with const OK
  unpriv: cmp pointer with pointer OK
  unpriv: pass pointer to printk OK
  unpriv: pass pointer to helper function OK
  unpriv: indirectly pass pointer on stack to helper function OK
  unpriv: mangle pointer on stack 1 OK
  unpriv: mangle pointer on stack 2 OK
  unpriv: read pointer from stack in small chunks OK
  unpriv: write pointer into ctx OK
  unpriv: write pointer into map elem value OK
  unpriv: partial copy of pointer OK

the most interesting one is 'indirectly pass pointer'.
It checks the case where user stores a pointer into a stack
and then uses that stack region either as a key for lookup or
as part of format string for printk.
