From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] keeping dst refcnt correctly with using xfrm
Date: Fri, 06 Jun 2003 00:27:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606.002719.35016156.davem@redhat.com>
References: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Fri, 6 Jun 2003 14:49:25 +0900
   
   In dst_pop refernce cound of dsts except for last are incremented in
   dst_clone and decremented in next call dst_pop but last dst refernce
   count will be never decremented.
   All dst are held by xfrm_policy and there is no need to touch the
   refernce count here.

Ok, there is problem with this logic.

Final dst is set to skb->dst, and when SKB is freed then
we do dst_release(skb->dst).  Therefore it _IS_ decremented.
(see net/core/skbuff.c:__kfree_skb(), it is where this final
DST reference is decremented).

Something is going wrong in ipv6 code if this is not happening.

If you modify skb->dst, it is your job to maintain reference
properly.

Look at how ipv4 works, we do all the work in the route lookup
and furthermore we never pass &skb->dst into these lookups.

What ipv6 output does looks really really strange.  It is silly
to do flow lookups in places like ip6_xmit().  And this is where
all the refcount bugs are really coming from.  Like ipv4, flow lookups
should be occuring at end of ip6_route_output() processing.

As far as I can tell, ip6_xmit() makes calculations based upon "dst"
and this is wrong.  It updates only skb->dst, but this is not what
that function uses to make decisions.  'dst' is old copy :(
