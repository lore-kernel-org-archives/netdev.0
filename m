From: "durgam@it.iitb.ac.in phani" <durgam.iit@gmail.com>
Subject: [PATCH] changes required to flush all routing table entries in side kernel
Date: Tue, 26 Feb 2008 16:24:54 +0530
Message-ID: <f46324890802260254p604b20date75974ca2349055@mail.gmail.com>
References: <f46324890802090413p79154b7fic6db453eb2960180@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:6785 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbYBZKy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 05:54:56 -0500
Received: by wr-out-0506.google.com with SMTP id c48so3166837wra.23
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 02:54:55 -0800 (PST)
In-Reply-To: <f46324890802090413p79154b7fic6db453eb2960180@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem :   Need to clean up routing table entries in side the Linux
 kernel. But  kernel is not providing  single command to clear all
 routing table entries at once.

 Modified the kernel to take of the changes    Defined new  net link
 message under  NETLINK_ROUTE   family  RTM_FLUSHROUTE.   At the
 receiving end in side kernel,  removed all routing table entries
 related with each device.

      Changed the code so that only the corresponding device reference
 will be incremented and perform the flush of entries related to that
 device and reduce the reference count.   In side fib_sync_flush(This
 function is same as fib_sync_down, except  that checking for protocol)
 ,  checking whether the route entry is installed by protocol,  and
 marking them only as dead.


 These are the changes . (version  2.6.14.2 linux kernel)

 --- linux26/include/net/ip_fib.h 2008-01-04 04:41:45.326857000 -0800
 +++ linux26/include/net/modified_ip_fib.h   2008-01-21 04:46:55.000000000 -0800
 @@ -233,6 +233,9 @@ extern void     ip_fib_init(void);

 +extern int inet_rtm_flushroute(struct sk_buff *skb, struct nlmsghdr*
 nlh, void *arg);

 +extern int fib_sync_flush(u32 local, struct net_device *dev, int
 force, int protocol);



 --- linux26/include/linux/rtnetlink.h   2008-01-04 02:57:57.487754000 -0800
 +++ linux26/include/linux/modified_rtnetlink.h  2008-01-21
 04:46:56.000000000 -0800
 @@ -35,7 +35,11 @@ enum {
  #define RTM_DELROUTE   RTM_DELROUTE
    RTM_GETROUTE,
  #define RTM_GETROUTE   RTM_GETROUTE
 -
 +    RTM_FLUSHROUTE,
 +#define RTM_FLUSHROUTE RTM_FLUSHROUTE
 +
    RTM_NEWNEIGH    = 28,
  #define RTM_NEWNEIGH   RTM_NEWNEIGH
    RTM_DELNEIGH,
 @@ -199,7 +203,9 @@ enum
 ~


 --- linux26/net/ipv4/fib_frontend.c 2008-01-04 03:07:17.964607000 -0800
 +++ linux26/net/ipv4/modified_fib_frontend.c    2008-01-21
 04:46:53.000000000 -0800
 +/*
 + * Added For flushing all the routes when clear ip route is issued
 from user space
 + */
 +int inet_rtm_flushroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 +{
 +    struct net_device *dev;
 +    struct in_device *in_dev;
 +    struct rtattr **rta = arg;
 +    struct rtmsg *r = NLMSG_DATA(nlh);
 +
 +    if (inet_check_attr(r, rta))
 +          return -EINVAL;
 +
 +    for (dev = dev_base; dev; dev = dev->next) {
 +        in_dev = in_dev_get(dev);
 +        if (!in_dev)
 +            continue;
 +        if(fib_sync_flush(0, dev, 0, r->rtm_protocol)) {
 +            fib_flush();
 +            rt_cache_flush(0);
 +        }
 +        in_dev_put(in_dev);
 +    }
 +
 +    return 0;
 +}

 This fib_sync_flush is same as fib_sync_down, except  for each entry
 it compares the protocol type of the routing entry  to be  removed.

 --- linux26/net/ipv4/fib_semantics.c    2008-01-09 02:22:49.819492000 -0800
 +++ linux26/net/ipv4/modified_fib_semantics.c1  2008-01-21
 04:46:52.000000000 -0800
 +/*
 + * FLUSH all  the routing table entries related to a
 + * device
 + */
 +
 +int fib_sync_flush(u32 local, struct net_device *dev, int force, int protocol)
 +{
 +    int ret = 0;
 +    int scope = RT_SCOPE_NOWHERE;
 +
 +    if (force)
 +        scope = -1;
 +
 +    if (local && fib_info_laddrhash) {
 +        unsigned int hash = fib_laddr_hashfn(local);
 +        struct hlist_head *head = &fib_info_laddrhash[hash];
 +        struct hlist_node *node;
 +        struct fib_info *fi;
 +        hlist_for_each_entry(fi, node, head, fib_lhash) {
 +        if (fi->fib_prefsrc == local) {
 +            fi->fib_flags |= RTNH_F_DEAD;
 +            ret++;
 +            }
 +        }
 +    }
 +
 +    if (dev) {
 +        struct fib_info *prev_fi = NULL;
 +        unsigned int hash = fib_devindex_hashfn(dev->ifindex);
 +        struct hlist_head *head = &fib_info_devhash[hash];
 +        struct hlist_node *node;
 +        struct fib_nh *nh;
 +        hlist_for_each_entry(nh, node, head, nh_hash) {
 +            struct fib_info *fi = nh->nh_parent;
 +            if(fi->fib_protocol == protocol) {
 +                int dead;
 +                BUG_ON(!fi->fib_nhs);
 +                if (nh->nh_dev != dev || fi == prev_fi)
 +                    continue;
 +                prev_fi = fi;
 +                dead = 0;
 +                change_nexthops(fi) {
 +                    if (nh->nh_flags&RTNH_F_DEAD)
 +                        dead++;
 +                    else if (nh->nh_dev == dev &&
 +                                nh->nh_scope != scope) {
 +                        nh->nh_flags |= RTNH_F_DEAD;
 +#ifdef CONFIG_IP_ROUTE_MULTIPATH
 +                        spin_lock_bh(&fib_multipath_lock);
 +                        fi->fib_power -= nh->nh_power;
 +                        nh->nh_power = 0;
 +                        spin_unlock_bh(&fib_multipath_lock);
 +#endif
 +                        dead++;
 +                    }
 +#ifdef CONFIG_IP_ROUTE_MULTIPATH
 +                    if (force > 1 && nh->nh_dev == dev) {
 +                        dead = fi->fib_nhs;
 +                        break;
 +                    }
 +#endif
 +                } endfor_nexthops(fi)
 +                if (dead == fi->fib_nhs) {
 +                       fi->fib_flags |= RTNH_F_DEAD;
 +                        ret++;
 +                }
 +            }
 +        }
 +    }
 +    return ret;
 +}



 Thanks
 Phani.
Brocade Software Systems.
