From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 17:42:00 -0700
Message-ID: <20150902004200.GA77081@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901205505.GA66075@kafai-mba.local>
 <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901222533.GB66075@kafai-mba.local>
 <1441147116.8932.188.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150902003144.GD66075@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33745 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751145AbbIBAmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 20:42:31 -0400
Content-Disposition: inline
In-Reply-To: <20150902003144.GD66075@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 05:31:44PM -0700, Martin KaFai Lau wrote:
> On Tue, Sep 01, 2015 at 03:38:36PM -0700, Eric Dumazet wrote:
> > On Tue, 2015-09-01 at 15:25 -0700, Martin KaFai Lau wrote:
> > > On Tue, Sep 01, 2015 at 02:26:58PM -0700, Eric Dumazet wrote:
> > > > On Tue, 2015-09-01 at 13:55 -0700, Martin KaFai Lau wrote:
> > > > > On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > > > > > It should not be a problem. refcnt is taken when/if necessary (skb
> > > > > > queued on a qdisc for example)
> > > > > >
> > > > > > We have other uses of skb_dst_set_noref()
> > > > > >
> > > > > > Please describe the problem ?
> > > > > The current ip6_tnl_dst_get() does not take the dst refcnt.
> > > > >
> > > > > If the dst is released after ip6_tnl_dst_get() and before
> > > > > skb_dst_set_noref(), would it cause an issue?
> > > >
> > > > We are under rcu here, and a dst in a cache is protected by RCU by
> > > > definition.
> > > >
> > > > skb_dst_set_noref() has following debugging clause, does it trigger for
> > > > you ?
> > > >
> > > > WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
> > > No. I did not see this.
> > >
> > > I am probably missing something.  Do you mean the rcu can
> > > protect the followings:
> > >
> > >
> > > ip6_tnl_dst_get()
> > > 			dst_release()
> > > 						dst_free() /* refcnt is 0 */
> > > skb_dst_set_noref()
> > >
> >
> > Yes, this is protected by normal rcu rules.
> >
> > dst wont be freed until all cpus exit their rcu read sections.
> For DST_NOCACHE, like:
>
> rcu_read_lock()
>
> ip6_tnl_dst_get()
>  			dst_release()	/* refcnt is 0 */
> 			=>call_rcu(dst_destroy)
> skb_dst_set_noref()
> __dev_queue_xmit()
> =>skb_dst_force()
> =>__dev_xmit_skb()
> =>q->enqueue()
>
> rcu_read_unlock()
> /* Here, I am holding a dst refcnt but
>  * the dst is already in the next
>  * rcu destroy cycle?
>  */
I look a closer look at dst_rcu_free() and your commit pointers.  I can see your point
for DST_NOCACHE.

However, dst_free() for not DST_NOCACHE is still an issue, I think.
