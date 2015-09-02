From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 17:31:44 -0700
Message-ID: <20150902003144.GD66075@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901205505.GA66075@kafai-mba.local>
 <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901222533.GB66075@kafai-mba.local>
 <1441147116.8932.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:30927 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750856AbbIBAbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 20:31:53 -0400
Content-Disposition: inline
In-Reply-To: <1441147116.8932.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 03:38:36PM -0700, Eric Dumazet wrote:
> On Tue, 2015-09-01 at 15:25 -0700, Martin KaFai Lau wrote:
> > On Tue, Sep 01, 2015 at 02:26:58PM -0700, Eric Dumazet wrote:
> > > On Tue, 2015-09-01 at 13:55 -0700, Martin KaFai Lau wrote:
> > > > On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > > > > It should not be a problem. refcnt is taken when/if necessary (skb
> > > > > queued on a qdisc for example)
> > > > >
> > > > > We have other uses of skb_dst_set_noref()
> > > > >
> > > > > Please describe the problem ?
> > > > The current ip6_tnl_dst_get() does not take the dst refcnt.
> > > >
> > > > If the dst is released after ip6_tnl_dst_get() and before
> > > > skb_dst_set_noref(), would it cause an issue?
> > >
> > > We are under rcu here, and a dst in a cache is protected by RCU by
> > > definition.
> > >
> > > skb_dst_set_noref() has following debugging clause, does it trigger for
> > > you ?
> > >
> > > WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
> > No. I did not see this.
> >
> > I am probably missing something.  Do you mean the rcu can
> > protect the followings:
> >
> >
> > ip6_tnl_dst_get()
> > 			dst_release()
> > 						dst_free() /* refcnt is 0 */
> > skb_dst_set_noref()
> >
>
> Yes, this is protected by normal rcu rules.
>
> dst wont be freed until all cpus exit their rcu read sections.
I can see skb_dst_set_noref() is safe at this point
but what happen after rcu_read_unlock()?

hmmm... Also, I don't see dst_free() is under the rcu contract, like
call_rcu() or synchronize_rcu().

Even it is (like dst_release for DST_NOCACHE dst_entry),  what happen
after the rcu_read_unlock()? Would someone (like qdisc) holds a dst refcnt
to an already/to-be destroyed dst? For DST_NOCACHE, like:

rcu_read_lock()

ip6_tnl_dst_get()
 			dst_release()	/* refcnt is 0 */
			=>call_rcu(dst_destroy)
skb_dst_set_noref()
__dev_queue_xmit()
=>skb_dst_force()
=>__dev_xmit_skb()
=>q->enqueue()

rcu_read_unlock()
/* Here, I am holding a dst refcnt but
 * the dst is already in the next
 * rcu destroy cycle?
 */

> You should take a look at following commits for a bit of history
>
> 10e2eb878f3ca07ac2f05fa5ca5e6c4c9174a27a
> dbfc4fb7d578d4f224faa6b60deb40804dfdc1b1
> f88649721268999bdff09777847080a52004f691
> 6c7e7610ff6888ea15a901fbcb30c5d461816b34
>
Thanks for the pointers.  It seems the ip_tunnel.c and ip_tunnel_core.c is
always doing skb_dst_set() also.  It is something that can also be optimized
in IPv4 or the situation is different in IPv4?
