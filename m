From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen patch available for perusal.
Date: Sat, 04 Nov 2006 09:29:04 -0800
Message-ID: <454CCDE0.5040109@candelatech.com>
References: <45468F2E.4060809@candelatech.com>	 <17736.54766.657083.873206@robur.slu.se> <4548F166.1020001@candelatech.com> <1162643532.5166.34.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:43946 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S965561AbWKDR1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Nov 2006 12:27:44 -0500
To: hadi@cyberus.ca
In-Reply-To: <1162643532.5166.34.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2006-01-11 at 11:11 -0800, Ben Greear wrote:
>
>   
>> I'd be thrilled to have the receive logic go into pktgen, even if 
>> it was #if 0 with a comment
>> showing how to patch dev.c to get it working.  It would make my 
>> out-of-tree patch smaller
>> and should help others who are doing research and driver development...
>>
>>     
>
> I use pktgen extensively these days for ipsec testing. I also record
> stats for pkts i receive using a tc action drop. Very simple and works
> great.  
> Ben, you keep insisting on doing this hook (every 3 months) because you
> dont want to invest time to do it with netlink (I thought you sold this
> as part of your product - the investment of your time is really not that
> high). If you tell me what the packet trigger is, I will send you a
> script ;->
>   
Please do send a script.  I match based on this method below.   Probably 
you only
need the part that checks for the MAGIC, the rest can be in a method 
called after
you match in your script?

/* Returns < 0 if the skb is not a pktgen buffer. */
int pktgen_receive(struct sk_buff* skb) {
        /* See if we have a pktgen packet */
    /* TODO:  Add support for detecting IPv6, TCP packets too.  This 
will only
     * catch UDP at the moment. --Ben
     */
    /*printk("pktgen-rcv, skb->len: %d\n", skb->len);*/
   
        if ((skb->len >= (20 + 8 + sizeof(struct pktgen_hdr))) &&
            (skb->protocol == __constant_htons(ETH_P_IP))) {
        struct pktgen_hdr* pgh;
               
                /* It's IP, and long enough, lets check the magic number.
                 * TODO:  This is a hack not always guaranteed to catch 
the right
                 * packets.
                 */
       
        /*printk("Length & protocol passed, skb->data: %p, raw: %p\n",
          skb->data, skb->h.raw);*/
      
                pgh = (struct pktgen_hdr*)(skb->data + 20 + 8);
       
                /*
                tmp = (char*)(skb->data);
                for (i = 0; i<90; i++) {
                        printk("%02hx ", tmp[i]);
                        if (((i + 1) % 15) == 0) {
                                printk("\n");
                        }
                }
                printk("\n");
                */
               
                if (pgh->pgh_magic == __constant_ntohl(PKTGEN_MAGIC)) {
                        struct net_device* dev = skb->dev;
                        struct pktgen_dev* pkt_dev;
                        __u32 seq = ntohl(pgh->seq_num);

            // TODO:  Need lock..maybe
            pkt_dev = dev->pkt_dev;
                       
                        if (!pkt_dev) {
                return -1;
                        }

                        pkt_dev->pkts_rcvd++;
                        pkt_dev->bytes_rcvd += ((skb->tail - 
skb->mac.raw) + 4); /* +4 for the checksum */
                       
                        /* Check for out-of-sequence packets */
                        if (pkt_dev->last_seq_rcvd == seq) {
                                pkt_dev->dup_rcvd++;
                                pkt_dev->dup_since_incr++;
                        }
                        else {
                                __s64 rx;
                                __s64 tx;
                                struct timeval txtv;
                if (skb->tstamp.off_sec || skb->tstamp.off_usec) {
                    skb_get_timestamp(skb, &txtv);
                }
                else {
                    do_gettimeofday(&txtv);
                    skb_set_timestamp(skb, &txtv);
                }
                                rx = tv_to_us(&txtv);

                                txtv.tv_usec = ntohl(pgh->tv_usec);
                                txtv.tv_sec = ntohl(pgh->tv_sec);
                                tx = tv_to_us(&txtv);
                                record_latency(pkt_dev, rx - tx);
                               
                                if ((pkt_dev->last_seq_rcvd + 1) == seq) {
                                        if ((pkt_dev->peer_clone_skb > 1) &&
                                            (pkt_dev->peer_clone_skb > 
(pkt_dev->dup_since_incr + 1))) {
                                               
                                                pkt_dev->seq_gap_rcvd += 
(pkt_dev->peer_clone_skb -
                                                                       
pkt_dev->dup_since_incr - 1);
                                        }
                                        /* Great, in order...all is well */
                                }
                                else if (pkt_dev->last_seq_rcvd < seq) {
                                        /* sequence gap, means we 
dropped a pkt most likely */
                                        if (pkt_dev->peer_clone_skb > 1) {
                                                /* We dropped more than 
one sequence number's worth,
                                                 * and if we're using 
clone_skb, then this is quite
                                                 * a few.  This number 
still will not be exact, but
                                                 * it will be closer.
                                                 */
                                                pkt_dev->seq_gap_rcvd += 
(((seq - pkt_dev->last_seq_rcvd) *
                                                                        
pkt_dev->peer_clone_skb) -
                                                                       
pkt_dev->dup_since_incr);
                                        }
                                        else {
                                                pkt_dev->seq_gap_rcvd += 
(seq - pkt_dev->last_seq_rcvd - 1);
                                        }
                                }
                                else {
                                        pkt_dev->ooo_rcvd++; /* 
out-of-order */
                                }
                               
                                pkt_dev->dup_since_incr = 0;
                        }
                        pkt_dev->last_seq_rcvd = seq;
                        kfree_skb(skb);
                        if (debug > 1) {
                                printk("done with pktgen_receive, free'd 
pkt\n");
                        }
                        return 0;
                }
        }
        return -1; /* Let another protocol handle it, it's not for us! */
}/* pktgen_receive */

> Robert, I have started writing some generic netlink messaging to replace
> the /proc that i will send your way. I need to get consensus on some
> tunnel-mode IPSEC patches first then i will send the about three
> patchsets your way (to replace the old ones i sent earlier).
>
> cheers,
> jamal
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


