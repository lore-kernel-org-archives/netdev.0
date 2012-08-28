From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] skbuff: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 16:17:19 -0300
Message-ID: <20120828161719.6faca38c@obelix.rh>
References: <CAPgLHd9m2VbFFXt5Q3MMrK6BPXvMrT-ptq+RfgBToXOpxAKOOw@mail.gmail.com>
	<1346163154.3571.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160Ab2H1TR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 15:17:29 -0400
In-Reply-To: <1346163154.3571.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Aug 2012 07:12:34 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2012-08-28 at 21:10 +0800, Wei Yongjun wrote:
> > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > 
> > Remove pointless conditional before kfree_skb().
> > 
> > Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > ---
> >  include/linux/skbuff.h | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 7632c87..0b846d9 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -2464,8 +2464,7 @@ static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
> >  }
> >  static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
> >  {
> > -	if (skb)
> > -		kfree_skb(skb);
> > +	kfree_skb(skb);
> >  }
> >  #endif
> >  #ifdef CONFIG_BRIDGE_NETFILTER
> > 
> 
> 
> Its not exactly pointless.
> 
> Its a tradeoff between kernel code size, and ability for cpu to predict
> a branch in kfree_skb()
> 
> This test is in hot path, and therefore this patch can potentially have
> a performance impact.
> 
> I really think most kfree_skb() calls are done with a non NULL param,
> so the branch prediction is good.
> 
> But after this patch, things are totally different.
>

But then the kfree_skb() is somewhat misleading because it does
check for NULL argument. One would have to remember if it's in
hot path or not. So, what about a new macro to pair with
kfree_skb()? That would document the code and would also
make easier to remember about the performance issue.

For instance:
/* kfree_skb() version to be used in hot code path
 * as the branch prediction can improve performance
 */
#define kfree_skb_hot(skb)	\
	if (skb)		\
		kfree_skb(skb)	\


fbl
