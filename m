From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Thu, 28 Oct 2004 17:23:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41818D99.9020300@candelatech.com>
References: <41797696.9070905@candelatech.com>	<20041022214611.GA4948@electric-eye.fr.zoreil.com> <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com> <4181838B.6040002@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4181838B.6040002@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> Ben Greear wrote:
> 

> Hi Ben,
> 
> I am not happy with this change to vlan_dev_hard_start_xmit().
> 
> I certainly appreciate the idea of avoiding flow-control "black-holes", 
> but that would
> take more than just this change. You have to consider (at least) these 
> issues:
> 
>  o It is considered an error if a queue-less device returns anything but 
> zero from its
>    hard_start_xmit() function (see dev_queue_xmit()).

This certainly was not clear to me.  The comments in dev_queue_xmit are
wrong about the return value (failure cases can be > zero too).  Are
there other errors or ommissions there?

What sorts of things go wrong if you do return an error here when you don't
have a queue?

>  o So, lets add a tx queue to it. Sure, that would be nice. Now we can 
> even do shaping
>    and other fancy stuff. But then how do we manage netif_queue_stopped? 
> Especially
>    restarting the queue could be tricky.

Right... it would probably be an O(N) thing to wake the queues for all virtual
devices on a physical device, and we certainly don't want to do that
often.  Maybe if you only tried to wake the blocked queues (ie, kept a list
of just blocked queues), then that would be less painful on average,
but the worst-case is still bad.

>  o But couldn't we skip netif_stop_queue() and just return 
> NETDEV_TX_BUSY when congested?
>    No, that would make the qdisc system "busy-retry" untill it succeeds. 
> BAD.
> 
>  o It is unsafe to pass a shared skb to dev_queue_xmit() unless you 
> control all the
>    references yourself. (It will likely be enqueued on a list.)

Since we either free the duplicate copy, or pass it to the queue and forget
about it, this last point does not matter in the patch I submitted, right?


> And specifically for this patch:
> 
>  o The skb could be freed (replaced) in __vlan_put_tag(), so you cannot 
> tell the caller
>    to hang on to it.

Yep, that is quite nasty...I had not noticed.  If I kept a copy of the original
pointer (using skb_get() to bump the reference) passed in,
that would fix this particular problem?

>  o If rv is NET_XMIT_CN (and probably also rv < 0) you have to return 0, 
> in order to
>    make the caller forget about this skb.

Is there a complete list of what return codes are possible?  Maybe we could make
it return an enum instead of an integer so we can more easily track these
sorts of things down??

Thanks for noticing!
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
