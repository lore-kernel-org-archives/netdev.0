From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Fri, 28 Nov 2014 05:14:18 +0000
Message-ID: <20141128051417.GA9306@ZenIV.linux.org.uk>
References: <20141105.155054.2198151263164321219.davem@davemloft.net>
 <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141106055023.GA28865@gondor.apana.org.au>
 <20141106064318.GW7996@ZenIV.linux.org.uk>
 <20141106064629.GA29321@gondor.apana.org.au>
 <20141106071109.GX7996@ZenIV.linux.org.uk>
 <A2BAEFC30C8FD34388F02C9B3121859D1C3087CA@eusaamb103.ericsson.se>
 <20141106221608.GA7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bcrl@kvack.org" <bcrl@kvack.org>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141106221608.GA7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 10:16:08PM +0000, Al Viro wrote:
> On Thu, Nov 06, 2014 at 09:55:31AM +0000, Jon Maloy wrote:
> > > Point, but that might very well be a pattern to watch for - there's at least one
> > > more instance in TIPC (also not exploitable, according to TIPC folks) and such
> > 
> > I don't recall this, and I can't see where it would be either. Can you please
> > point to where it is?
> 
> The same dest_name_check() thing.  This
>         if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
>                 return -EFAULT;
>         if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
>                 return -EACCES;
> is easily bypassed.  Suppose you want to send a packet with these two
> bits in ->tcm_type not being 00, and you don't have CAP_NET_ADMIN.
> Not a problem - spawn two threads sharing memory, have one trying to
> call sendmsg() while another keeps flipping these two bits.  Sooner
> of later you'll get the timing right and have these bits observed as 00
> in dest_name_check() and 11 when it comes to memcpy_fromiovecend() actually
> copying the whole thing.  And considering that the interval between those
> two is much longer than the loop in the second thread would take on
> each iteration, I'd expect the odds around 25% per attempted sendmsg().
> 
> IOW, this test is either pointless and can be removed completely, or there's
> an exploitable race.  As far as I understand from your replies both back then
> and in another branch of this thread, it's the former and the proper fix is
> to remove at least that part of dest_name_check().  So this case is also
> not something exploitable, but it certainly matches the same pattern.
> 
> My point was simply that this pattern is worth watching for - recurrent bug
> classes like that have a good chance to spawn an instance that will be
> exploitable.

Ping?  Can we simply remove dest_name_check() completely?  That's one of the
few remaining obstacles to making ->sendmsg() iov_iter-clean.  For now I'm
simply commenting its call out in tipc_sendmsg(); if it _is_ needed for
anything, we'll need to get rid of that double copying from userland.  I can
do that, but my impression from your comments back in April is that you
planned to removed the damn check anyway.

Another question: in tipc_send_stream() we have
        mtu = tsk->max_pkt;
        send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
        __skb_queue_head_init(&head);
        rc = tipc_msg_build(mhdr, m, sent, send, mtu, &head);
        if (unlikely(rc < 0))
                goto exit;
        do {   
                if (likely(!tsk_conn_cong(tsk))) {
                        rc = tipc_link_xmit(&head, dnode, ref);
                        if (likely(!rc)) {
                                tsk->sent_unacked++;
                                sent += send;
                                if (sent == dsz)
                                        break;
                                goto next;
                        }
                        if (rc == -EMSGSIZE) {
                                tsk->max_pkt = tipc_node_get_mtu(dnode, ref);
                                goto next;
                        }

How can it hit that EMSGSIZE?  AFAICS, it can come only from
int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list)
{
        struct tipc_msg *msg = buf_msg(skb_peek(list));
        uint psz = msg_size(msg);
...
        uint mtu = link->max_pkt;
...
        /* Has valid packet limit been used ? */   
        if (unlikely(psz > mtu)) {
                __skb_queue_purge(list);
                return -EMSGSIZE;
        }

and msg_size() is basically the bits copied into skb by tipc_msg_build() and
set by msg_set_size() in there.  And unless I'm seriously misreading that
function, it can't be more than pktmax argument, i.e. mtu.  So unless something
manages to crap into our skb or change mtu right under us, it shouldn't be
possible.  And mtu (i.e. ->max_pkt) ought to be protected by lock_sock() there.

What's going on there?
