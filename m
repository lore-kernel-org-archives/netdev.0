From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: netfilter: nf_conntrack: there maybe a bug in
 __nf_conntrack_confirm, when it race against get_next_corpse
Date: Tue, 28 Oct 2014 11:11:09 +0100
Message-ID: <20141028111109.1f64f76e@redhat.com>
References: <02ef01cff25f$29887f60$7c997e20$@gmail.com>
	<02f201cff260$8622e610$9268b230$@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	"'Netfilter Developer Mailing List'"
	<netfilter-devel@vger.kernel.org>,
	"'Pablo Neira Ayuso'" <pablo@netfilter.org>,
	"'Patrick McHardy'" <kaber@trash.net>, <kadlec@blackhole.kfki.hu>,
	<davem@davemloft.net>, "'Changli Gao'" <xiaosuo@gmail.com>,
	"'Andrey Vagin'" <avagin@openvz.org>, brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "billbonaparte" <programme110@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <02f201cff260$8622e610$9268b230$@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 28 Oct 2014 11:37:31 +0800 "billbonaparte" <programme110@gmail.com> wrote:

> Hi, all:
> sorry for sending this mail again, the last mail doesn't show text
> clearly.

This one also mangles the text, so I cannot follow the race you are
describing.  I'll try to reconstruct...

> In function __nf_conntrack_confirm, we check the conntrack if it was
> already dead, before insert it into hash-table. 
> We do this because if we insert an already 'dead' hash,  it will
> block further use of that particular connection.

Have you run into this problem in practice, or is this based on a
theory?

> but we don't do that right.
> let's consider the following case:
> 
[tried to reconstruct]

> 	cpu1                             cpu2
> __nf_conntrack_confirm             get_next_corpse
>   lock corresponding hash-list      ....
>   check nf_ct_is_dying(ct)          ....
>    .....                           for_each_possible_cpu(cpu) {
>    .....                           (processing &pcpu->unconfirmed)
>    .....                           spin_lock_bh(&pcpu->lock);
>    .....                           set_bit(IPS_DYING_BIT, &ct->status);
>    .....                           spin_unlock_bh(&pcpu_lock);
>  spin_lock_bh(&pcpu->lock);
>  nf_ct_del_from_dying_or_unconfirmed_list(ct);
>  spin_unlock_bh(&pcpu_lock);
>
>  add_timer(&ct->timeout);
>  ct->status |= IPS_CONFIRMED;
>  __nf_conntrack_hash_insert(ct);
>   /* the conntrack has been seted as dying*/

Yes, I think you are correct.  There is a race.  As we are modifying
the ct->status, without holding the hash bucket lock.


> The above case reveal two problems:
> 	1. we may insert a dead conntrack to hash-table, it will block
> further use of that particular connection.
> 	2. operation on ct->status should be atomic, because it race aginst
> get_next_corpse.
> 	  due to this reason, the operation on ct->status in
> nf_nat_setup_info should be atomic as well.
> 
> 	if we want to resolve the first problem, we must delete the
> unconfirmed conntrack from unconfirmed-list first, then check if it is
> already dead.

Guess that would be one approach.

> 	Am I right to do this ?
> 	Appreciate any comments and reply.

Perhaps we could get rid of unconfirmed list handling in get_next_corpse?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
