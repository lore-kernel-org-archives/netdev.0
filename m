From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/7] bpf: add 'flags' attribute to
 BPF_MAP_UPDATE_ELEM command
Date: Tue, 4 Nov 2014 15:04:34 -0800
Message-ID: <CAMEtUuy5gJbeLqiSr1=SiNQ7WyqocUVV-siwhEnpBVqmzYzzCQ@mail.gmail.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com>
	<1415069656-14138-2-git-send-email-ast@plumgrid.com>
	<54589B89.5000309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54589B89.5000309-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 1:25 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
> On 11/04/2014 03:54 AM, Alexei Starovoitov wrote:
>>
>> the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
>> either update existing map element or create a new one.
>> Initially the plan was to add a new command to handle the case of
>> 'create new element if it didn't exist', but 'flags' style looks
>> cleaner and overall diff is much smaller (more code reused), so add 'flags'
>> attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
>> enum {
>>    BPF_MAP_UPDATE_OR_CREATE = 0, /* add new element or update existing */
>>    BPF_MAP_CREATE_ONLY,          /* add new element if it didn't exist */
>>    BPF_MAP_UPDATE_ONLY           /* update existing element */
>> };
>
>
> From you commit message/code I currently don't see an explanation why
> it cannot be done in typical ``flags style'' as various syscalls do,
> i.e. BPF_MAP_UPDATE_OR_CREATE rather represented as ...
>
>   BPF_MAP_CREATE | BPF_MAP_UPDATE
>
> Do you expect more than 64 different flags to be passed from user space
> for BPF_MAP?

several reasons:
- preserve flags==0 as default behavior
- avoid holes and extra checks for invalid combinations, so
  if (flags > BPF_MAP_UPDATE_ONLY) goto err, is enough.
- it looks much neater when user space uses
  BPF_MAP_UPDATE_OR_CREATE instead of ORing bits.

Note this choice doesn't prevent adding bit-like flags
in the future. Today I cannot think of any new flags
for the update() command, but if somebody comes up with
a new selector that can apply to all three combinations,
we can add it as 3rd bit that can be ORed.
Default will stay zero and 'if >' check in older
kernels will seamlessly work with new userspace.
I don't like holes in flags and combinatorial
explosion of bits and checks for them unless
absolutely necessary.
