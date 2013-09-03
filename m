From: Jesse Gross <jesse@nicira.com>
Subject: Re: [-next] openvswitch BUILD_BUG_ON failed
Date: Tue, 3 Sep 2013 14:44:32 -0700
Message-ID: <CAEP_g=-BWdWJ5WtNy0=Eq8GJp84i88QbGq-gQcANBhCKajcJsQ@mail.gmail.com>
References: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A@mail.gmail.com>
 <CAEP_g=-XvRiHPzSAp2rgC9Hxdd+pGEHvSTEJ1A1SkWnk1-6xZA@mail.gmail.com>
 <20130829.181001.145658561677052552.davem@davemloft.net> <CAEP_g=-XxgK9HVxvcaW3RS2zfa+77pB4cqfLFC0rcV7QJc+2BQ@mail.gmail.com>
 <CAMuHMdU3M9uUFKd3EQ0HbcAvf5e62PA4NJG_mQHhpvZwFJnUWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Andy Zhou <azhou@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:46026 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755324Ab3ICVoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 17:44:54 -0400
Received: by mail-lb0-f182.google.com with SMTP id c11so4813240lbj.41
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 14:44:52 -0700 (PDT)
In-Reply-To: <CAMuHMdU3M9uUFKd3EQ0HbcAvf5e62PA4NJG_mQHhpvZwFJnUWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 31, 2013 at 5:11 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Fri, Aug 30, 2013 at 3:11 AM, Jesse Gross <jesse@nicira.com> wrote:
>> On Thu, Aug 29, 2013 at 3:10 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Jesse Gross <jesse@nicira.com>
>>> Date: Thu, 29 Aug 2013 14:42:22 -0700
>>>
>>>> On Thu, Aug 29, 2013 at 2:21 PM, Geert Uytterhoeven
>>>> <geert@linux-m68k.org> wrote:
>>>>> However, I have some doubts about other alignment "enforcements":
>>>>>
>>>>> "__aligned(__alignof__(long))" makes the whole struct aligned to the
>>>>> alignment rule for "long":
>>>>>    1. This is only 2 bytes on m68k, i.e. != sizeof(long).
>>>>>    2. This is 4 bytes on many 32-bit platforms, which may be less than the
>>>>>       default alignment for "__be64" (cfr. some members of struct
>>>>>       ovs_key_ipv4_tunnel), so this may make those 64-bit members unaligned.
>>>>
>>>> Do any of those 32-bit architectures actually care about alignment of
>>>> 64 bit values? On 32-bit x86, a long is 32 bits but the alignment
>>>> requirement of __be64 is also 32 bit.
>>>
>>> All except x86-32 do, it is in fact the odd man out with respect to this
>>> issue.
>>
>> Thanks, good to know.
>>
>> Andy, do you want to modify your patch to just drop the alignment
>> specification as Geert suggested (but definitely keep the new build
>> assert that you added)? It's probably better to just send the patch to
>> netdev (against net-next) as well since you'll likely get better
>> comments there and we can fix this faster if you cut out the
>> middleman.
>
> Why do you want to keep the build asserts?
> Is this in-memory structure also transfered as-is over the network?
> If yes, you definitely want the padding.

Well they caught this bug and really don't cost anything.

> Nevertheless, as the struct contains u32 and even __be64 members, the
> size of the struct will always be a multiple of the alignment unit for
> 64-bit quantities (and thus also for long), as per the C standard.
> Hence the check
>
>     BUILD_BUG_ON(sizeof(struct sw_flow_key) % __alignof__(long));
>
> will only catch bad compiler bugs or people adding __packed to the struct.

It's possible that we might want to pack the structure in the future.
More generally though, the contents of the struct is really
independent of the alignment requirements here because we're accessing
it as an array of bytes in long-sized chunks so implicitly depending
on the size of the members is not that great.
