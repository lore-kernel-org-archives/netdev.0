From: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
Subject: RE: [PATCH] net: Fix skb_under_panic oops in neigh_resolve_output
Date: Fri, 5 Oct 2012 12:33:03 -0400
Message-ID: <CA3E5132752D1F49871ED0FC40D56BBA43ECF33592@EUSAACMS0701.eamcs.ericsson.se>
References: <1349406325-3157-1-git-send-email-ramesh.nagappa@gmail.com>
 <1349418445.21172.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	"xemul@parallels.com" <xemul@parallels.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"ramesh.nagappa@gmail.com" <ramesh.nagappa@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349418445.21172.11.camel@edumazet-glaptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Yes, that is a good optimization. neigh_resolve_output() also has the
__skb_pull() outside the loop, is that required ? The changes would be
like ...

neigh_resolve_output()
...
-        __skb_pull(skb, skb_network_offset(skb));


        if (!neigh_event_send(neigh, skb)) {
                int err;
                struct net_device *dev = neigh->dev;
                unsigned int seq;

                if (dev->header_ops->cache && !neigh->hh.hh_len)
                        neigh_hh_init(neigh, dst);

                do {                        
+			      __skb_pull(skb, skb_network_offset(skb));
                        seq = read_seqbegin(&neigh->ha_lock);
                        err = dev_hard_header(skb, dev, ntohs(skb->protocol),
                                              neigh->ha, NULL, skb->len);
                } while (read_seqretry(&neigh->ha_lock, seq));

Thanks,
Ramesh
 

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com] 
> >  	do {
> >  		seq = read_seqbegin(&neigh->ha_lock);
> > +		__skb_pull(skb, skb_network_offset(skb));
> 
> This __skb_pull() could be done before the read_seqbegin() to 
> keep the protected section short.
> 
> >  		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
> >  				      neigh->ha, NULL, skb->len);
> >  	} while (read_seqretry(&neigh->ha_lock, seq));
> 
> Thanks
> 
> 
> 