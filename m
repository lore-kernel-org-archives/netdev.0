From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Fri, 29 Aug 2014 21:53:39 +0200
Message-ID: <20140829195339.GA9780@kria>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
 <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Cc: Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

2014-08-29, 11:14:48 -0700, Cong Wang wrote:
> On Fri, Aug 29, 2014 at 8:26 AM, Tommi Rantala <tt.rantala@gmail.com> wrote:
> > [   77.297196] RTNL: assertion failed at net/ipv6/addrconf.c (1699)
> > [   77.298080] CPU: 0 PID: 4842 Comm: trinity-main Not tainted 3.17.0-rc2+ #30
> > [   77.299039] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [   77.299789]  ffff88003d76a618 ffff880026133c50 ffffffff8238ba79
> > ffff880037c84520
> > [   77.300829]  ffff880026133c90 ffffffff820bd52b 0000000000000000
> > ffffffff82d86c40
> > [   77.301869]  0000000000000000 00000000f76fd1e1 ffff8800382d8000
> > ffff8800382d8220
> > [   77.302906] Call Trace:
> > [   77.303246]  [<ffffffff8238ba79>] dump_stack+0x4d/0x66
> > [   77.303928]  [<ffffffff820bd52b>] addrconf_join_solict+0x4b/0xb0
> > [   77.304731]  [<ffffffff820b031b>] ipv6_dev_ac_inc+0x2bb/0x330
> > [   77.305498]  [<ffffffff820b0060>] ? ac6_seq_start+0x260/0x260
> > [   77.306257]  [<ffffffff820b05fe>] ipv6_sock_ac_join+0x26e/0x360
> > [   77.307046]  [<ffffffff820b0429>] ? ipv6_sock_ac_join+0x99/0x360
> > [   77.307798]  [<ffffffff820cdd60>] do_ipv6_setsockopt.isra.5+0xa70/0xf20
> 
> 
> I think we should just use rtnl_lock() instead of rcu_read_lock() there,
> it is not a hot path worth optimization.
> 
> Please try the attached patch.

note: it doesn't build as it is now, it needs:

-EXPORT_SYMBOL(dev_get_by_flags_rcu);
+EXPORT_SYMBOL(dev_get_by_flags);


I just tried your patch with a basic test program (open
socket/join/leave/close and open socket/join/close).

I think you need to modify ipv6_sock_ac_close as well, or you can still
trigger the assertion when closing the socket without leaving first.

Modified patch attached.


-- 
Sabrina

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="ipv6-anycast_v2.diff"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 429801370d0c..1ae0e745b1b1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2077,8 +2077,8 @@ void __dev_remove_pack(struct packet_type *pt);
 void dev_add_offload(struct packet_offload *po);
 void dev_remove_offload(struct packet_offload *po);
 
-struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short flags,
-					unsigned short mask);
+struct net_device *dev_get_by_flags(struct net *net, unsigned short flags,
+				    unsigned short mask);
 struct net_device *dev_get_by_name(struct net *net, const char *name);
 struct net_device *dev_get_by_name_rcu(struct net *net, const char *name);
 struct net_device *__dev_get_by_name(struct net *net, const char *name);
diff --git a/net/core/dev.c b/net/core/dev.c
index 443b814db05b..8fede6ef4a39 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -897,23 +897,24 @@ struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
 EXPORT_SYMBOL(dev_getfirstbyhwtype);
 
 /**
- *	dev_get_by_flags_rcu - find any device with given flags
+ *	dev_get_by_flags - find any device with given flags
  *	@net: the applicable net namespace
  *	@if_flags: IFF_* values
  *	@mask: bitmask of bits in if_flags to check
  *
  *	Search for any interface with the given flags. Returns NULL if a device
  *	is not found or a pointer to the device. Must be called inside
- *	rcu_read_lock(), and result refcount is unchanged.
+ *	rtnl_lock(), and result refcount is unchanged.
  */
 
-struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags,
+struct net_device *dev_get_by_flags(struct net *net, unsigned short if_flags,
 				    unsigned short mask)
 {
 	struct net_device *dev, *ret;
 
+	ASSERT_RTNL();
 	ret = NULL;
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev(net, dev) {
 		if (((dev->flags ^ if_flags) & mask) == 0) {
 			ret = dev;
 			break;
@@ -921,7 +922,7 @@ struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags
 	}
 	return ret;
 }
-EXPORT_SYMBOL(dev_get_by_flags_rcu);
+EXPORT_SYMBOL(dev_get_by_flags);
 
 /**
  *	dev_valid_name - check if name is okay for network device
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 210183244689..6de5caa26ea4 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -77,7 +77,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	pac->acl_next = NULL;
 	pac->acl_addr = *addr;
 
-	rcu_read_lock();
+	rtnl_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
@@ -90,11 +90,11 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			goto error;
 		} else {
 			/* router, no matching interface: just pick one */
-			dev = dev_get_by_flags_rcu(net, IFF_UP,
+			dev = dev_get_by_flags(net, IFF_UP,
 						   IFF_UP | IFF_LOOPBACK);
 		}
 	} else
-		dev = dev_get_by_index_rcu(net, ifindex);
+		dev = __dev_get_by_index(net, ifindex);
 
 	if (dev == NULL) {
 		err = -ENODEV;
@@ -136,7 +136,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	}
 
 error:
-	rcu_read_unlock();
+	rtnl_unlock();
 	if (pac)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 	return err;
@@ -171,13 +171,15 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	spin_unlock_bh(&ipv6_sk_ac_lock);
 
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+	rtnl_lock();
+	dev = __dev_get_by_index(net, pac->acl_ifindex);
 	if (dev)
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
-	rcu_read_unlock();
+	rtnl_unlock();
 
 	sock_kfree_s(sk, pac, sizeof(*pac));
+	if (!dev)
+		return -ENODEV;
 	return 0;
 }
 
@@ -198,12 +200,12 @@ void ipv6_sock_ac_close(struct sock *sk)
 	spin_unlock_bh(&ipv6_sk_ac_lock);
 
 	prev_index = 0;
-	rcu_read_lock();
+	rtnl_lock();
 	while (pac) {
 		struct ipv6_ac_socklist *next = pac->acl_next;
 
 		if (pac->acl_ifindex != prev_index) {
-			dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+			dev = __dev_get_by_index(net, pac->acl_ifindex);
 			prev_index = pac->acl_ifindex;
 		}
 		if (dev)
@@ -211,7 +213,7 @@ void ipv6_sock_ac_close(struct sock *sk)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 		pac = next;
 	}
-	rcu_read_unlock();
+	rtnl_unlock();
 }
 
 static void aca_put(struct ifacaddr6 *ac)

--LZvS9be/3tNcYl/X--
