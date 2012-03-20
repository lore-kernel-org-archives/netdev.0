From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] adjust __net_exit
Date: Mon, 19 Mar 2012 19:17:47 -0700
Message-ID: <m1fwd46mno.fsf@fess.ebiederm.org>
References: <4F588BEC020000780007710A@nat28.tlf.novell.com>
	<20120316.221813.236130733754848615.davem@davemloft.net>
	<20120317230318.GA19460@merkur.ravnborg.org>
	<4F66F8F70200007800079305@nat28.tlf.novell.com>
	<20120319084703.GA20897@merkur.ravnborg.org>
	<4F6705ED0200007800079343@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Sam Ravnborg" <sam@ravnborg.org>,
	"David Miller" <davem@davemloft.net>, <xemul@openvz.org>,
	<netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: "Jan Beulich" <JBeulich@suse.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F6705ED0200007800079343@nat28.tlf.novell.com> (Jan Beulich's
	message of "Mon, 19 Mar 2012 09:09:49 +0000")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Jan Beulich" <JBeulich@suse.com> writes:

>>>> On 19.03.12 at 09:47, Sam Ravnborg <sam@ravnborg.org> wrote:
>>> >> > Using the (bogus and unused elsewhere)
>>> >> > __exit_refok to implement this is inefficient - any non-modular code
>>> >> > really can reside in __init (as non-modular __exit code is never used).
>> 
>>> > 2) fix up the bogus commit message
>>> 
>>> Bogus in what way?
>> 
>> I fail to see that __exit_refok is bogus.
>
> Either an exit function references only permitted code (in which case
> it is legitimately using __exit), or it references non-__exit code, in
> which case it shouldn't have an override at all. Permitting an exit
> function to reference e.g. __init code is suspicious (at best) in all
> cases I can think of (in contrast to allowing a non-init function to
> reference __init code on a code path that can be proven to be taken
> only during system startup).

My apologies I said that there was nothing network namespace specific
left to talk about and I had goofed in my analysis.  The weirdness with
references comes from how struct pernet_operations is used.

Structures of type struct pernet_operations hold holds pointers to .init
functions marked as __net_init and .exit and .exit_batch marked as
__net_exit.

The assertion is that references from static instances of struct
pernet_operations that live in __net_initdata should be ok.


Structures of type pernet_operations are passed to
register_pernet_subsys or register_pernet_device which ultimately call
register_pernet_operations.  Register pernet_operations when the network
namespace is disabled simply calls the .init function when the network
namespace code is compiled out.  The .exit and .exit_batch functions
are not referenced at all.

When the network namespace code is compiled in __net_init __net_exit
and __net_initdata all go away.

So the exit function references only permitted code.  But the exit
function is being referenced by data in an init section which requires
the override.

How should we mark functions in __net_exit that can be thrown away
when outside of a module and never even loaded when compiled into the
kernel when the network namespace is disabled?

The original definition of __exit_refok seemed to say this very clearly
to me.  This is an __exit section but references to it from __init data
are ok.

Eric
