From: Joubert Berger <joubert@berger-family.org>
Subject: Help with some code
Date: Wed, 09 Jun 2004 21:20:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086830414.16999.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am trying to write a routine that will allow me to send a reset packet
with some additional status information.  The routine below seems to be
able to ok as it sends the newly created skbuff to ip_finish_output(). 
But after that the kernel panics.  Could I get someone to look over this
and see what I might be doing wrong?

--joubert

void SendTcpRst(struct sk_buff *oskb, int status)
{
        struct sk_buff *nskb;
        struct iphdr    *oiph, *iph;
        struct my_tcp_reset tcp_reset, *my_reset_ptr;
        struct tcphdr *otcph, *tcph;
        struct ethhdr *oeth, *eth;
        unsigned char *ohdr;
        unsigned int    iplen;
        struct rtable *rt;
        int ret;
        if (!oskb)
                return;
          
        oeth = oskb->mac.ethernet;
        oiph = oskb->nh.iph;
        otcph = (struct tcphdr *)
                ((u_int32_t*)oskb->nh.iph + oskb->nh.iph->ihl);
                                                                                
        if (ip_route_output(&rt, oskb->nh.iph->saddr,
                            oskb->nh.iph->daddr ,
                            RT_TOS(oskb->nh.iph->tos) | RTO_CONN,
                            0) != 0) {
                printk(("no route to host\n"));
                return;
        }
                                                                                
        tcp_reset.status = htonl(status);
                                                                               
        nskb = alloc_skb(16  + sizeof(struct iphdr) +
                              sizeof(struct tcphdr) +
                               sizeof(struct my_tcp_reset), GFP_ATOMIC);
        if (!nskb)
                return;
                                                                             
        skb_reserve(nskb, 16);
        eth = (struct ethhdr *) skb_push(nskb, sizeof(struct ethhdr));
        iph = (struct iphdr *) skb_put(nskb, sizeof(struct iphdr));
        tcph = (struct tcphdr *) skb_put(nskb, sizeof(struct tcphdr));
        my_reset_ptr = (struct my_tcp_reset *) skb_put(nskb,
                                                sizeof(struct
my_tcp_reset));
                                                                                
        memcpy(my_reset_ptr, &tcp_reset, sizeof(struct my_tcp_reset));
                                                                                
        /* Populate new ethernet frame */
                                                                                
printk("copy ethernet frame\n");
        memcpy(eth->h_dest, oeth->h_source, ETH_ALEN);
        memcpy(eth->h_source, oeth->h_dest, ETH_ALEN);
        eth->h_proto = oeth->h_proto;
                                                                                
        /* Populate new TCP frame */
                                                                                
printk("copy TCP frame\n");
        tcph->seq = 0;
        tcph->ack_seq = htonl(ntohl(otcph->seq) + 1);
        ((u_int8_t *)tcph)[13] = 0;
        tcph->rst = 1;
        tcph->ack = 0;
        tcph->window = 0;
        tcph->urg_ptr = 0;
        tcph->check = 0;
        tcph->doff = sizeof(struct tcphdr)/4;
       tcph->check = tcp_v4_check(tcph, sizeof(struct tcphdr),
                                   nskb->nh.iph->saddr,
                                   nskb->nh.iph->daddr,
                                   csum_partial((char *)tcph,
                                                sizeof(struct tcphdr),
0));
        /* Populate new IP frame */
                                                                                
printk("copy IP frame\n");
        iph->ihl = 5;
        iph->version = 4;
        iph->ttl = MAXTTL;
        iph->tos = 0;
        iph->id = 0;
        iph->protocol = IPPROTO_TCP;
        iph->saddr = oiph->daddr;
        iph->daddr = oiph->saddr;
        iph->frag_off = htons(IP_DF);
        iplen = sizeof(struct iphdr) + sizeof(struct tcphdr) +
                sizeof(struct my_tcp_reset);
        iph->tot_len = htons(iplen);
        iph->check = 0;
        iph->tot_len = htons(iplen);
        iph->check = 0;
        iph->check = ip_fast_csum((void *) iph, iph->ihl);
                                                                                
        /* Populate skb info */
                                                                                
printk("copy  SKB\n");
        nskb->priority = 0;
        nskb->dst = dst_clone(&rt->u.dst);
        nskb->dev = nskb->dst->dev;
        nskb->h.th = tcph;
        nskb->nh.iph = iph;
        nskb->mac.ethernet = eth;
        nskb->protocol = oskb->protocol;
        nskb->ip_summed = oskb->ip_summed;
        nskb->stamp = oskb->stamp;
        nskb->pkt_type = PACKET_HOST;
        nskb->nfct = NULL;
        nskb->nfcache = 0;
        nskb->nfmark = 0;
        nskb->cloned = 0;
        atomic_set(&nskb->users, 1);
        /* Deliver packet now */
                                                                                
printk("TEST: SRC=%u.%u.%u.%u DST=%u.%u.%u.%u \n",
               NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
        ret = ip_finish_output(nskb);
printk("TEST: ret=%d\n", ret);
}
