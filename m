From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] udp: use sk_protocol instead of pcflag to
 detect udplite sockets
Date: Fri, 31 Mar 2017 16:33:04 +0200
Message-ID: <1490970784.2845.15.camel@redhat.com>
References: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
         <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41022 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754597AbdCaOdH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 10:33:07 -0400
In-Reply-To: <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-31 at 06:25 -0700, Eric Dumazet wrote:
> On Fri, 2017-03-31 at 11:47 +0200, Paolo Abeni wrote:
> > In the udp_sock struct, the 'forward_deficit' and 'pcflag' fields
> > share the same cacheline. While the first is dirtied by
> > udp_recvmsg, the latter is read, possibly several times, by the
> > bottom half processing to discriminate between udp and udplite
> > sockets.
> > 
> > With this patch, sk->sk_protocol is used to check is the socket is
> > really an udplite one, avoiding some cache misses per
> > packet and improving the performance under udp_flood with
> > small packet up to 10%.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  include/linux/udp.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/udp.h b/include/linux/udp.h
> > index c0f5308..6cb4061 100644
> > --- a/include/linux/udp.h
> > +++ b/include/linux/udp.h
> > @@ -115,6 +115,6 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
> >  #define udp_portaddr_for_each_entry_rcu(__sk, list) \
> >  	hlist_for_each_entry_rcu(__sk, list, __sk_common.skc_portaddr_node)
> >  
> > -#define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
> > +#define IS_UDPLITE(__sk) (__sk->sk_protocol == IPPROTO_UDPLITE)
> >  
> >  #endif	/* _LINUX_UDP_H */
> 
> 
> 
> I am pretty sure we agreed in the past that forward_deficit would need
> to be placed on a cache line of its own. Somehow we manage to not
> implement this properly.
> 
> What about other fields like encap_rcv, encap_destroy, gro_receive,
> gro_complete. They really should have the same false sharing issue.

I did the above to avoid increasing the udp_sock struct size; this will
costs more than a whole cacheline.

I did not hit others false sharing issues because:
- gro_receive/gro_complete are touched only for packets coming from 
devices with udp tunnel offload enabled, that hit the tunnel offload
path on the nic; such packets will most probably land in the udp tunnel
 and will not use 'forward_deficit'
- encap_destroy is touched only socket shutdown
- encap_rcv is protected by the 'udp_encap_needed' static key

I think this latter is problematic, so I'm ok with the patch you
suggested.

The above change could still make sense, the udp code is already
checking for udplite sockets with either pcflag and protocol;
testing always the same data will make the code more cleaner.

Paolo
