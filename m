From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] skbuff: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 17:39:29 -0300
Message-ID: <20120828173929.7b371079@obelix.rh>
References: <CAPgLHd9m2VbFFXt5Q3MMrK6BPXvMrT-ptq+RfgBToXOpxAKOOw@mail.gmail.com>
	<1346163154.3571.6.camel@edumazet-glaptop>
	<20120828161719.6faca38c@obelix.rh>
	<1346184598.3571.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052Ab2H1Ujf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 16:39:35 -0400
In-Reply-To: <1346184598.3571.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Aug 2012 13:09:58 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2012-08-28 at 16:17 -0300, Flavio Leitner wrote:
> > On Tue, 28 Aug 2012 07:12:34 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > On Tue, 2012-08-28 at 21:10 +0800, Wei Yongjun wrote:
> > > > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > > > 
> > > > Remove pointless conditional before kfree_skb().
> > > > 
> > > > Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > > > ---
> > > >  include/linux/skbuff.h | 3 +--
> > > >  1 file changed, 1 insertion(+), 2 deletions(-)
> > > > 
> > > > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > > > index 7632c87..0b846d9 100644
> > > > --- a/include/linux/skbuff.h
> > > > +++ b/include/linux/skbuff.h
> > > > @@ -2464,8 +2464,7 @@ static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
> > > >  }
> > > >  static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
> > > >  {
> > > > -	if (skb)
> > > > -		kfree_skb(skb);
> > > > +	kfree_skb(skb);
> > > >  }
> > > >  #endif
> > > >  #ifdef CONFIG_BRIDGE_NETFILTER
> > > > 
> > > 
> > > 
> > > Its not exactly pointless.
> > > 
> > > Its a tradeoff between kernel code size, and ability for cpu to predict
> > > a branch in kfree_skb()
> > > 
> > > This test is in hot path, and therefore this patch can potentially have
> > > a performance impact.
> > > 
> > > I really think most kfree_skb() calls are done with a non NULL param,
> > > so the branch prediction is good.
> > > 
> > > But after this patch, things are totally different.
> > >
> > 
> > But then the kfree_skb() is somewhat misleading because it does
> > check for NULL argument. One would have to remember if it's in
> > hot path or not. So, what about a new macro to pair with
> > kfree_skb()? That would document the code and would also
> > make easier to remember about the performance issue.
> > 
> > For instance:
> > /* kfree_skb() version to be used in hot code path
> >  * as the branch prediction can improve performance
> >  */
> > #define kfree_skb_hot(skb)	\
> > 	if (skb)		\
> > 		kfree_skb(skb)	\
> 
> Really kfree_skb() is not misleading at all :
> 
> if (unlikely(!skb))
> 	return;
> 
> So while its _perfectly_ valid to call kfree_skb(NULL), this code
> expect callers to not abuse this facility.

Well, I don't think that is obvious. Neither the patch's author.

> And nf_conntrack_put_reasm() is called from skb_release_head_state()
> 
> We know in this code that most of the time, skb will be NULL.

yeah, but it looks pointless to check the same thing twice.

> I dont think we need to add another API for this case and see one
> hundred patches coming _trying_ to use this new API.

Ok, and what if kfree_skb() becomes a macro that first checks
if the skb is NULL and if not, call the _kfree_skb() to
continue as before?

#define kfree_skb(skb)		\
        if (skb)		\
		_kfree_skb(skb)	\


void _kfree_skb(struct sk_buff *skb)
{                       
        if (likely(atomic_read(&skb->users) == 1))
                smp_rmb();      
        else if (likely(!atomic_dec_and_test(&skb->users)))
                return;
        trace_kfree_skb(skb, __builtin_return_address(0));
        __kfree_skb(skb);
}

Same API which would work for either use-cases. At the cost of
additional size in the binary.

> Just review patches and shout if something bad happens.

I hope we always have you around to catch these cases :)

fbl
