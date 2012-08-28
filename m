From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skbuff: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 13:09:58 -0700
Message-ID: <1346184598.3571.16.camel@edumazet-glaptop>
References: <CAPgLHd9m2VbFFXt5Q3MMrK6BPXvMrT-ptq+RfgBToXOpxAKOOw@mail.gmail.com>
	 <1346163154.3571.6.camel@edumazet-glaptop>
	 <20120828161719.6faca38c@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36679 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083Ab2H1UJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 16:09:59 -0400
Received: by pbbrr13 with SMTP id rr13so9979803pbb.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 13:09:58 -0700 (PDT)
In-Reply-To: <20120828161719.6faca38c@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-28 at 16:17 -0300, Flavio Leitner wrote:
> On Tue, 28 Aug 2012 07:12:34 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Tue, 2012-08-28 at 21:10 +0800, Wei Yongjun wrote:
> > > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > > 
> > > Remove pointless conditional before kfree_skb().
> > > 
> > > Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > > ---
> > >  include/linux/skbuff.h | 3 +--
> > >  1 file changed, 1 insertion(+), 2 deletions(-)
> > > 
> > > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > > index 7632c87..0b846d9 100644
> > > --- a/include/linux/skbuff.h
> > > +++ b/include/linux/skbuff.h
> > > @@ -2464,8 +2464,7 @@ static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
> > >  }
> > >  static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
> > >  {
> > > -	if (skb)
> > > -		kfree_skb(skb);
> > > +	kfree_skb(skb);
> > >  }
> > >  #endif
> > >  #ifdef CONFIG_BRIDGE_NETFILTER
> > > 
> > 
> > 
> > Its not exactly pointless.
> > 
> > Its a tradeoff between kernel code size, and ability for cpu to predict
> > a branch in kfree_skb()
> > 
> > This test is in hot path, and therefore this patch can potentially have
> > a performance impact.
> > 
> > I really think most kfree_skb() calls are done with a non NULL param,
> > so the branch prediction is good.
> > 
> > But after this patch, things are totally different.
> >
> 
> But then the kfree_skb() is somewhat misleading because it does
> check for NULL argument. One would have to remember if it's in
> hot path or not. So, what about a new macro to pair with
> kfree_skb()? That would document the code and would also
> make easier to remember about the performance issue.
> 
> For instance:
> /* kfree_skb() version to be used in hot code path
>  * as the branch prediction can improve performance
>  */
> #define kfree_skb_hot(skb)	\
> 	if (skb)		\
> 		kfree_skb(skb)	\

Really kfree_skb() is not misleading at all :

if (unlikely(!skb))
	return;

So while its _perfectly_ valid to call kfree_skb(NULL), this code
expect callers to not abuse this facility.

And nf_conntrack_put_reasm() is called from skb_release_head_state()

We know in this code that most of the time, skb will be NULL.

I dont think we need to add another API for this case and see one
hundred patches coming _trying_ to use this new API.

Just review patches and shout if something bad happens.
