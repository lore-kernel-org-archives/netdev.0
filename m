From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] adjust __net_exit
Date: Sun, 18 Mar 2012 17:41:28 -0700
Message-ID: <m1vcm1777r.fsf@fess.ebiederm.org>
References: <4F588BEC020000780007710A@nat28.tlf.novell.com>
	<20120316.221813.236130733754848615.davem@davemloft.net>
	<20120317230318.GA19460@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, JBeulich@suse.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120317230318.GA19460@merkur.ravnborg.org> (Sam Ravnborg's
	message of "Sun, 18 Mar 2012 00:03:18 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Ravnborg <sam@ravnborg.org> writes:

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

Strange.

>
> The intention with Jan's patch is to move functions annotated
> __net_exit to a discardable section in the core kernel.
> Then at least __exit should be used - there is no logic
> using __init for exit code.
>
> I suggest to:
> 1) fix the patch to use __exit
> 2) fix up the bogus commit message

Those two sound reasonable to me.

The purpose of __net_exit is to mark code that can be __exit if we don't
enable network namespace support.

Looking at the original code it appears that __exit was wrong because
we had __init sections referring to the __exit code and that was
causing modpost to complain.

Now that the definition of __exit_refok has changed half a dozen times
since it was introduced I don't know what will happen.

Since this really isn't about network namespaces but what to do when
the network namespace code is disabled I'm going to bow out now.

> Then it should be OK - iff the assumption hold that the functions
> can be discarded in the core kernel.
> I have grepped a little and saw no uses where this did not hold true.
> So based on this I assume the assumption is OK.

Eric
