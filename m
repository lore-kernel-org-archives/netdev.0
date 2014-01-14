From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Mon, 13 Jan 2014 20:53:16 -0800
Message-ID: <20140114045316.GV10038@linux.vnet.ibm.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
 <1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHA+R7OMM9ndy4hXF4rJBsA_Rb0KZ-MonuvE++wgzO_oMbo+eQ@mail.gmail.com>
 <1389548697.31367.184.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHA+R7Pe_pGFw5cA3v_RnGvOurAykJNVH5=DeeEVHG84faWi2Q@mail.gmail.com>
 <1389601233.31367.213.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:53888 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbaANExV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 23:53:21 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 13 Jan 2014 21:53:20 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9548D19D8041
	for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 21:53:09 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0E4r7fP6685094
	for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 05:53:07 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s0E4uXC2012133
	for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 21:56:33 -0700
Content-Disposition: inline
In-Reply-To: <1389601233.31367.213.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 12:20:33AM -0800, Eric Dumazet wrote:
> On Sun, 2014-01-12 at 22:36 -0800, Cong Wang wrote:
> > > Please read rcu_dereference_protected() documentation in
> > > include/linux/rcupdate.h
> > 
> > I did before I replied.
> 
> 
> 
> > 
> > >
> > > Also you can run sparse, with CONFIG_SPARSE_RCU_POINTER=y in
> > > your .config
> > >
> > > make C=2 net/ipv4/ip_tunnel.o
> > >
> > > And then you'll know the answer to this question.
> > >
> > 
> > Sounds like it is only to shut up a sparse warning, then its name
> > is misleading, we clearly don't dereference it here.

OK, I'll bite...  This code invokes dst_release() which looks to me
like it dereferences this pointer:

void dst_release(struct dst_entry *dst)
{
	if (dst) {
		int newrefcnt;

		newrefcnt = atomic_dec_return(&dst->__refcnt);
		WARN_ON(newrefcnt < 0);
		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
			dst = dst_destroy(dst);
			if (dst)
				__dst_free(dst);
		}
	}
}

If you really were not dereferencing the pointer, for example, if you
were only testing it against NULL or some such, then you can use
rcu_access_pointer().  This is a bit cheaper on DEC Alpha, FWIW.

You can think of rcu_dereference() as meaning "fetch this RCU-protected
pointer with intent to dereference()" if that helps.

Or am I missing your point?

> Historical reasons, you should have been there when Paul invented the
> name and lazy people like us let him do so !
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=b62730baea32f86fe91a7930e4b7ee8d82778b79

Indeed!  ;-)

And rcu_dereference() is at least an improvement over the earlier
hand-placed smp_read_barrier_depends().

							Thanx, Paul

> You are lucky, there is plenty of documentation, maybe too much..
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
