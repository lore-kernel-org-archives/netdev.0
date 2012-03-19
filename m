From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] adjust __net_exit
Date: Mon, 19 Mar 2012 08:14:31 +0000
Message-ID: <4F66F8F70200007800079305@nat28.tlf.novell.com>
References: <4F588BEC020000780007710A@nat28.tlf.novell.com>
 <20120316.221813.236130733754848615.davem@davemloft.net>
 <20120317230318.GA19460@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <xemul@openvz.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>, <ebiederm@xmission.com>
To: "David Miller" <davem@davemloft.net>,
	"Sam Ravnborg" <sam@ravnborg.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120317230318.GA19460@merkur.ravnborg.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 18.03.12 at 00:03, Sam Ravnborg <sam@ravnborg.org> wrote:
> On Fri, Mar 16, 2012 at 10:18:13PM -0700, David Miller wrote:
>> From: "Jan Beulich" <JBeulich@suse.com>
>> Date: Thu, 08 Mar 2012 09:37:32 +0000
>> 
>> > __net_exit, judging by the majority of its uses, was intended to serve
>> > as an abstraction to allow calling such annotated functions from both
>> > __init and __exit functions. Using the (bogus and unused elsewhere)
>> > __exit_refok to implement this is inefficient - any non-modular code
>> > really can reside in __init (as non-modular __exit code is never used).
>> > 
>> > Therefore, adjust __net_exit to resolve to nothing (i.e. normal .text)
>> > in modules, and __init in the core kernel.
>> > 
>> > A few other adjustments are necessary/possible with this done - those
>> > were likely just oversights when added originally.
>> > 
>> > Signed-off-by: Jan Beulich <jbeulich@suse.com>
>> 
>> [ I have been waiting for more than a week for a netns developer
>>   to review this patch, I guess I'm too optimistic these days. :-( ]
>> 
>> The only reason you think __exit_refok is "bogus" is because it's
>> semantics got changed by Sam Ravnborg in commit
>> 312b1485fb509c9bc32eda28ad29537896658cb8 ("Introduce new section
>> reference annotations tags: __ref, __refdata, __refconst")
>> 
>> Beforehand the __exit_refok was a real .exit section, so it got
>> completely discarded AT LINK TIME.  Now it sits together with
>> __init_refok which is an unremovable kernel image section, which
>> neither gets removed at compile time nor boot time.
> 
> Some misunderstanding is going on here.
> 
> The *ref* annotation is used to teach modpost that this function (or data)
> may reference functions (or data) which is annotated __init*.
> And the *ref* annotation never caused the annotated code to be discarded.
> 
> This was true before the above mentioned patch - and it is still true.
> 
> Before the path ("Introduce new section reference ....") the __exit_refok
> annotation moved functions to the section named ".exit.text.refok"
> which was explicit part of .text (TEXT_TEXT in vmlinux).
> 
> So __exit_refok does exactly what it is intended to do:
> It puts the function in a section so modpost does not warn about
> references to __init or __exit sections.
> 
> As Jan points out there is only a single user left - so
> this would be a good time to kill it. It is even documented
> in init.h that this is a backward compatibility define.
> 
> The intention with Jan's patch is to move functions annotated
> __net_exit to a discardable section in the core kernel.
> Then at least __exit should be used - there is no logic
> using __init for exit code.
> 
> I suggest to:
> 1) fix the patch to use __exit

That won't work, as the goal is to have the exit functions call from
__net_init iiuc.

> 2) fix up the bogus commit message

Bogus in what way?

> Then it should be OK - iff the assumption hold that the functions
> can be discarded in the core kernel.

Since __exit functions won't ever be called when built in, they can as
well be marked __init and thus become possible to call from __init code
(again iiuc). Perhaps this should even become a concept outside of
net/, as not marking exit code __exit just because is also gets called
on error paths from __init is not uncommon. Maybe it should even be
__exit itself to get changed that way (albeit I vaguely recall that
differences between arches of when .exit.* sections get discarded
might need further consideration), as long as no arch would get
penalized in that it discards .exit.* but not .init.* post-boot.

Jan

> I have grepped a little and saw no uses where this did not hold true.
> So based on this I assume the assumption is OK.
> 
> 	Sam



