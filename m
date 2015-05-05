From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated
 bit flags
Date: Tue, 05 May 2015 14:37:24 +0200
Message-ID: <5548B984.5000900@iogearbox.net>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <5548ABF8.5080806@mojatatu.com> <20150505114733.GE17061@breakpoint.cc> <5548B070.80502@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40745 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422667AbbEEMhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 08:37:33 -0400
In-Reply-To: <5548B070.80502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/2015 01:58 PM, Jamal Hadi Salim wrote:
> On 05/05/15 07:47, Florian Westphal wrote:
>> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>> Initial feedback on the series:
>>> - Can you keep the macros around? eg SET_TC_NCLS is more readable
>>> than skb->tc_nocls = 1 also hides the bit details.

(see below)

>> I beg to differ, sorry :-/
>>
>> We use blah:1 everywhere else in sk_buff, only tc is different and
>> its not obvious (to me) how tc_verd is being used and for what.
>>
>> Or are you saying that should redefine SET_TC_NCLS to something like
>>
>> #define SET_TC_NCLS(skb)    (skb)->tc_nocls = 1
>>
>> ?
>
> It is borderline questionable for 1 bit but for consistency i
> suggest you do what was there before. I pointed to nocls but
> i meant the comment generically because previous code you are
> changing intended to use the macros.
> In any case I will leave it up to you.

So, just to give my comment on the macros ... if I look at them ...

#define TC_MUNGED          _TC_MAKEMASK1(0)
#define SET_TC_MUNGED(v)   ( TC_MUNGED | (v & ~TC_MUNGED))
#define CLR_TC_MUNGED(v)   ( v & ~TC_MUNGED)

#define TC_OK2MUNGE        _TC_MAKEMASK1(1)
#define SET_TC_OK2MUNGE(v)   ( TC_OK2MUNGE | (v & ~TC_OK2MUNGE))
#define CLR_TC_OK2MUNGE(v)   ( v & ~TC_OK2MUNGE)

#define S_TC_VERD          _TC_MAKE32(2)
#define M_TC_VERD          _TC_MAKEMASK(4,S_TC_VERD)
#define G_TC_VERD(x)       _TC_GETVALUE(x,S_TC_VERD,M_TC_VERD)
#define V_TC_VERD(x)       _TC_MAKEVALUE(x,S_TC_VERD)
#define SET_TC_VERD(v,n)   ((V_TC_VERD(n)) | (v & ~M_TC_VERD))

#define S_TC_FROM          _TC_MAKE32(6)
#define M_TC_FROM          _TC_MAKEMASK(2,S_TC_FROM)
#define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
#define V_TC_FROM(x)       _TC_MAKEVALUE(x,S_TC_FROM)
#define SET_TC_FROM(v,n)   ((V_TC_FROM(n)) | (v & ~M_TC_FROM))

... I quite frankly find the transformation after Florian's series
*MUCH*, *MUCH* more intuitive, also given that we use such kind of
bit flags already extensively everywhere in else the stack.

What's more is that we reduce skbuff usage by 13-12 bits (given the
follow up fix with AT_STACK is addressed).

I really think we should get rid of these macros from tc code.

>>> I think the ones that are no longer needed should just be deleted
>>> as opposed to what you and Alexei did earlier.
>>
>> Fair enough, I can do that.
>
> Perhaps even as a first patch that move would be useful.

I think that can be done as a follow-up *after* the series. Given
it's uapi (which probably never should have been?) it's a different
question on its own.

Looking at git log include/uapi/linux/pkt_cls.h, it slipped in via
David Howells uapi script ...

commit 607ca46e97a1b6594b29647d98a32d545c24bdff
Author: David Howells <dhowells@redhat.com>
Date:   Sat Oct 13 10:46:48 2012 +0100

     UAPI: (Scripted) Disintegrate include/linux

     Signed-off-by: David Howells <dhowells@redhat.com>
     Acked-by: Arnd Bergmann <arnd@arndb.de>
     Acked-by: Thomas Gleixner <tglx@linutronix.de>
     Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
     Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
     Acked-by: Dave Jones <davej@redhat.com>

... if that was accidental, we should remove all the macros that are
then undef'ed for kernel space. I currently fail to see how iproute2
could have ever used them.

>>> - We need two bits for the location (ingress, egress, from stack)
>>> from stack being 0 i.e when it is not set implicitly it is from the
>>> host stack then we can check for ingress or egress when we choose.
>>
>> Hmm, are you sure?  How is that used?
>
> As example, when something like
> if (!(at & AT_EGRESS))
> implies it is either from ingress or the stack.
> It does not only from ingress.
>
>> In fact ifb will BUG() if neither AT_INGRESS or AT_EGRESS was set
>> in G_TC_FROM().
>
> Yes, because you cant send directly from the stack host to ifb. You
> can only redirect to it. If we ever end there from the host we should
> bug()

Hm, I actually missed we have AT_STACK (== 0) as it's not set explicitly,
good point, that means tc_from_ingress needs to be one single bit more.

Thanks,
Daniel
