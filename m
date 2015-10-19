From: Ani Sinha <ani@arista.com>
Subject: Re: linux 3.4.43 : kernel crash at __nf_conntrack_confirm
Date: Mon, 19 Oct 2015 13:22:51 -0700
Message-ID: <CAOxq_8N1Cx8duPy47THVMnDqN58=a_=gbmzksvVarVr9qkS5Uw@mail.gmail.com>
References: <CAOxq_8PF91fpX9jYTgBbXnOVeVfSu3tytu-3P_Zr5OodGRoz+g@mail.gmail.com>
 <CAOxq_8Pt7VMwkV8+wdjS9vj=-L0L8Xxkd3Beit0zZN_oR6ixhw@mail.gmail.com>
 <20151018080702.GA14564@breakpoint.cc> <CAOxq_8NLLFyNCSDJ68+VjxFGpNSex8ShdhGFNBHK29g_+UBW6g@mail.gmail.com>
 <alpine.OSX.2.20.1510181409060.87917@athabasca.local> <20151018214050.GD4386@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20151018214050.GD4386@breakpoint.cc>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 18, 2015 at 2:40 PM, Florian Westphal <fw@strlen.de> wrote:
> Ani Sinha <ani@arista.com> wrote:
>> Indeed. So it seems to me that we have run into one another such case.
>> In patch c6825c0976fa7893692, I see we have added an additional check (along with comparing tuple and zone) to verify that if the conntrack is confirmed.
>>
>> +       return nf_ct_tuple_equal(tuple, &h->tuple) &&
>> +               nf_ct_zone(ct) == zone &&
>> +               nf_ct_is_confirmed(ct);
>>
>> This is necessary since it's possible that a conntrack can be recreated with the same zone.
>> Unfortunately, we leave a hole open in __nf_conntrack_confirm() because this routine _is_ responsible
>> for confirming the conntrack. We cannot use the same logic here.
>
> Hmm, why?
>
> I don't understand why we need to change __nf_conntrack_confirm(), can
> you elaborate?

ok, let's take a step back. The fundamental question I am trying to
find answer to is that whether it is possible for another thread to
deallocate and then reallocate and initialize the conntrack object
while running concurrently during __nf_conntrack_confirm() . The crash
below seems to indicate that this can happen.

However, in the current 3.4 release (and the image which generated the
crash), we do not have the patch

e53376bef2cd97d3e3f61fdc6

applied. This patch bumps the refcount before adding the connrack
entry into the unconfirmed list.

+ /* Now it is inserted into the unconfirmed list, bump refcount */
+ nf_conntrack_get(&ct->ct_general);

and if we assume the invariant that nf_conntrack_free() is never
called when refcount is !=0, then this would seem to indicate that the
above patch should fix the crash I mentioned in the thread.

One curious piece of hunk is :

+ /* A freed object has refcnt == 0, that's
+ * the golden rule for SLAB_DESTROY_BY_RCU
+ */
+ NF_CT_ASSERT(atomic_read(&ct->ct_general.use) == 0);
+

First, this assertion only puts a warning log at best when it fails.
Second, if this assertion is false, at some point we will get into a
kernel crash as the one I mentioned. So this assertion effectively
does nothing other than perhaps help in debugging. Third, the very
fact that this assertion was placed seems to indicate that there might
be cases where we can free a conntrack object with non-zero ref-count.

Does all this makes sense?
