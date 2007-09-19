From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Wed, 19 Sep 2007 10:27:58 +0200
Message-ID: <46F0DD8E.8070808@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de>	<20070917100438.18347.2@janus.isnogud.escape.de>	<46EFD33D.8030905@trash.net> <ygffy1bzn4c.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474AbXISIey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 04:34:54 -0400
In-Reply-To: <ygffy1bzn4c.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>>+HLIST_HEAD(rx_dev_list);
>>
>>
>>Same here (static).
> 
> 
> Can't be static since it's used in proc.c.  But __read_mostly might
> make sense.
> 
> What exactly is the effect of __read_mostly?  Is that in a separate
> ELF section?  Where is that finally located?


Its a seperate section to prevent false sharing.

> 
> 
>>>+		if (ret == -ENOSYS)
>>>+			printk(KERN_INFO "can: request_module(%s) not"
>>>+			       " implemented.\n", module_name);
>>>+		else if (ret)
>>>+			printk(KERN_ERR "can: request_module(%s) failed\n",
>>>+			       module_name);
>>
>>
>>Both of these printks seem to be user-triggerable, so they should
>>be rate-limited (or maybe get removed completely/changed to DBG).
> 
> 
> Hm, I don't think DBG() would be right here, since the messages show
> problems in the installation to the admin.  OTOH, I see that a user
> can flood the log by opening sockets with invalid proto numbers.  Rate
> limiting might solve this, or we should print the message only once
> per proto number.  I will think about this.


IMO this is a perfectly normal condition (not finding a module).
Especially the !KMOD case is hardly an error.


>>>+	/* check for success and correct type */
>>>+	cp = proto_tab[protocol];
>>
>>
>>What prevents the module from getting unloaded again (and using
>>a stale pointer)?
> 
> 
> When the module is unloaded it calls can_proto_unregister() which
> clears the pointer.  Do you see a race condition here?


Yes, you do request_module, load the module, get the cp pointer
from proto_tab, the module is unloaded again. cp points to
stable memory. Using module references would fix this.

>>>+		if (!(skb->dev->flags & IFF_LOOPBACK)) {
>>>+			/*
>>>+			 * If the interface is not capable to do loopback
>>>+			 * itself, we do it here.
>>>+			 */
>>>+			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
>>>+
>>>+			if (!newskb) {
>>>+				kfree_skb(skb);
>>>+				return -ENOMEM;
>>>+			}
>>>+
>>>+			newskb->sk = skb->sk;
>>>+			newskb->ip_summed = CHECKSUM_UNNECESSARY;
>>>+			newskb->pkt_type = PACKET_BROADCAST;
>>>+			netif_rx(newskb);
>>
>>
>>So the intention here is to send the packet to the non-loopback device
>>and manually loop it, which means sending it twice?
> 
> 
> CAN is a broadcast message network, so every frame should be (usually)
> sent to all receivers, on remote hosts and to all local sockets.  If
> the driver for the interface is not able to loop back the frame for
> local delivery, the can_send() function will do this as a fallback.
> For real CAN devices it is preferred that the driver does loopback.
> For vcan it makes no difference where loopback is done.  The module
> paramenter for vcan is therefore only useful to test and debug the CAN
> core module.  It is nothing a normal user will ever use.


Thanks for the explanation.


>>>+static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev)
>>>+{
>>>+	struct dev_rcv_lists *d;
>>>+	struct hlist_node *n;
>>>+
>>>+	....
>>>+
>>>+	hlist_for_each_entry(d, n, &rx_dev_list, list) {
>>
>>
>>On the receive path you use RCU, so this should be
>>hlist_for_each_entry_rcu(), no? The bottem half disabling during
>>addition/removal also seems unnecessary, but I might be missing
>>something.
> 
> 
> find_dev_rcv_lists() is called in one place from can_rcv() with RCU
> lock held, as you write.  The other two calls to find_dev_rcv_lists()
> are from can_rx_register/unregister() functions which change the
> receive lists.  Therefore, we can't only use RCU but need protection
> against simultanous writes.  We do this with the spin_lock_bh().  The
> _bh variant, because can_rcv() runs in interrupt and we need to block
> that.  I thought this is pretty standard.
> 
> I'll check this again tomorrow, but I have put much time in these
> locking issues already, changed it quite a few times and hoped to have
> got it right finally.


I'm not saying you should use *only* RCU, you need the lock
for additions/removal of course, but since the receive path
doesn't take that lock and relies on RCU, you need to use
the _rcu list walking variant to avoid races with concurrent
list changes.


>>>+	case NETDEV_REGISTER:
>>>+
>>>+		/*
>>>+		 * create new dev_rcv_lists for this device
>>>+		 *
>>>+		 * N.B. zeroing the struct is the correct initialization
>>>+		 * for the embedded hlist_head structs.
>>>+		 * Another list type, e.g. list_head, would require
>>>+		 * explicit initialization.
>>>+		 */
>>>+
>>>+		DBG("creating new dev_rcv_lists for %s\n", dev->name);
>>>+
>>>+		d = kzalloc(sizeof(*d),
>>>+			    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
>>
>>
>>netdevice registration should never happen from interrupt handlers.
> 
> 
> Hm, I seem to remember we had such an occurance with hot-pluggable
> devices, i.e. USB.  But I may be wrong.  In what context is
> NETDEV_REGISTER called for e.g. USB devices?  Can we safely write
> just GFP_KERNEL here?


Yes. register_netdevice() takes the rtnl mutex, so it can only
be used in process context.

>>>+		stattimer.expires = jiffies + HZ;
>>
>>round_jiffies?
> 
> 
> Yes.  We don't depend on exact times relative to module load time, but
> we would like to have the timer expirations 1 second apart.  But we
> would still get this with round_jiffies(), right?


I don't think you will get *exactly* one second, but you also have
no guarantee for that now.

>>>+ * proc read functions
>>>+ *
>>>+ * From known use-cases we expect about 10 entries in a receive list to be
>>>+ * printed in the proc_fs. So PAGE_SIZE is definitely enough space here.
>>
>>
>>Would be nicer to use seq_file (for all the proc stuff).
> 
> 
> That has already been on my TODO list.  There was some problem which I
> don't remember ATM, which is why I dropped it temporarily.  Now on my
> TODO list again.


Thanks :)
