From: Frank Pavlic <pavlic@de.ibm.com>
Subject: Re: [PATCH] introducing new net device feature NETIF_F_MC_ALL
Date: Tue, 21 Sep 2004 17:52:47 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <OF5799D6AD.F64E4151-ONC1256F16.00566499-C1256F16.00570AFC@de.ibm.com>
References: <20040917154619.5e384c67.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20040917154619.5e384c67.davem@davemloft.net>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, 
your suggested solution would be great for me ...
I'm on the way to make a new patch introducing your proposal ...

Thank you ...

Frank 
 




"David S. Miller" <davem@davemloft.net> 
Sent by: linux-net-owner@vger.kernel.org
18.09.2004 00:46

To
Frank Pavlic/Germany/IBM@IBMDE
cc
netdev@oss.sgi.com, linux-net@vger.kernel.org
Subject
Re: [PATCH] introducing new net device feature NETIF_F_MC_ALL







Looks mostly fine Frank.

But why don't we save you some work, we have the IP address
handy therefore it's kind of silly for you to have to look
it up again.

Let's create a new netdev callback, something like:

                 void (*mc_change)(struct netdev *dev, void *addr, int 
family, int add);

Then net/ipv4/igmp.c can do something like:

static void ip_mc_filter_add(struct in_device *in_dev, u32 addr)
{
                 char buf[MAX_ADDR_LEN];
                 struct net_device *dev = in_dev->dev;

                 /* Checking for IFF_MULTICAST here is WRONG-WRONG-WRONG.
                    We will get multicast token leakage, when 
IFF_MULTICAST
                    is changed. This check should be done in 
dev->set_multicast_list
                    routine. Something sort of:
                    if (dev->mc_list && dev->flags&IFF_MULTICAST) { do it; 
}
                    --ANK
                    */
                 if (arp_mc_map(addr, buf, dev, 0) == 0) {
                                 dev_mc_add(dev,buf,dev->addr_len,0);
                                 if (dev->mc_change)
                                                 dev->mc_change(dev, 
&addr, AF_INET, 1);
                 }
}

static void ip_mc_filter_del(struct in_device *in_dev, u32 addr)
{
                 char buf[MAX_ADDR_LEN];
                 struct net_device *dev = in_dev->dev;

                 if (arp_mc_map(addr, buf, dev, 0) == 0) {
                                 dev_mc_delete(dev,buf,dev->addr_len,0);
                                 if (dev->mc_change)
                                                 dev->mc_change(dev, 
&addr, AF_INET, 0);
                 }
}

And similarly for the other dev_mc_{add,delete}() call sites.
-
To unsubscribe from this list: send the line "unsubscribe linux-net" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


