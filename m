From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/7] bpf: add 'flags' attribute to BPF_MAP_UPDATE_ELEM
 command
Date: Wed, 05 Nov 2014 15:57:16 +0100
Message-ID: <545A3ACC.3080101@redhat.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com> <1415069656-14138-2-git-send-email-ast@plumgrid.com> <54589B89.5000309@redhat.com> <CAMEtUuy5gJbeLqiSr1=SiNQ7WyqocUVV-siwhEnpBVqmzYzzCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuy5gJbeLqiSr1=SiNQ7WyqocUVV-siwhEnpBVqmzYzzCQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2014 12:04 AM, Alexei Starovoitov wrote:
> On Tue, Nov 4, 2014 at 1:25 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 11/04/2014 03:54 AM, Alexei Starovoitov wrote:
>>>
>>> the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
>>> either update existing map element or create a new one.
>>> Initially the plan was to add a new command to handle the case of
>>> 'create new element if it didn't exist', but 'flags' style looks
>>> cleaner and overall diff is much smaller (more code reused), so add 'flags'
>>> attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
>>> enum {
>>>     BPF_MAP_UPDATE_OR_CREATE = 0, /* add new element or update existing */
>>>     BPF_MAP_CREATE_ONLY,          /* add new element if it didn't exist */
>>>     BPF_MAP_UPDATE_ONLY           /* update existing element */
>>> };
>>
>>  From you commit message/code I currently don't see an explanation why
>> it cannot be done in typical ``flags style'' as various syscalls do,
>> i.e. BPF_MAP_UPDATE_OR_CREATE rather represented as ...
>>
>>    BPF_MAP_CREATE | BPF_MAP_UPDATE
>>
>> Do you expect more than 64 different flags to be passed from user space
>> for BPF_MAP?
>
> several reasons:
> - preserve flags==0 as default behavior
> - avoid holes and extra checks for invalid combinations, so
>    if (flags > BPF_MAP_UPDATE_ONLY) goto err, is enough.
> - it looks much neater when user space uses
>    BPF_MAP_UPDATE_OR_CREATE instead of ORing bits.
>
> Note this choice doesn't prevent adding bit-like flags
> in the future. Today I cannot think of any new flags
> for the update() command, but if somebody comes up with
> a new selector that can apply to all three combinations,
> we can add it as 3rd bit that can be ORed.

Hm, mixing enums together with bitfield-like flags seems
kind of hacky ... :/ Or, do you mean to say you're adding
a 2nd flag field, i.e. splitting the 64bits into a 32bit
``cmd enum'' and 32bit ``flag section''?

I see the point with flags == 0 as default behavior though,
but at this point in time we won't get burnt by it since
the API is not yet in a usable state and defaults to be
compiled-out.

> Default will stay zero and 'if >' check in older
> kernels will seamlessly work with new userspace.
> I don't like holes in flags and combinatorial
> explosion of bits and checks for them unless
> absolutely necessary.

Hm, my concern is that we start to add many *_OR_* enum
elements once we find that a flag might be a useful in
combination with many other flags ... even though if we
only can think of 3 flags /right now/.
