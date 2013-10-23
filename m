From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: BUG: scheduling while atomic dev_set_promiscuity->__dev_notify_flags
Date: Tue, 22 Oct 2013 22:34:35 -0700
Message-ID: <CAADnVQLY7-crQLO1Tc4MBLX8R66wAZztw-arnfO3NWO9sLW++Q@mail.gmail.com>
References: <CAMEtUuy91zYJ=bj1dzfdqE8kqZ3rE1RgdR-PZYekSUg8_xoTBw@mail.gmail.com>
	<slrnl6ei2u.vgu.xiyou.wangcong@linux-6brj.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:55317 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab3JWFeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 01:34:36 -0400
Received: by mail-qc0-f173.google.com with SMTP id l13so185383qcy.4
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 22:34:35 -0700 (PDT)
In-Reply-To: <slrnl6ei2u.vgu.xiyou.wangcong@linux-6brj.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 8:53 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, 22 Oct 2013 at 01:04 GMT, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>
>> packet_notifier() does rcu_read_lock() before calling into packet_dev_mc() .
>>
>> Not sure how to fix it cleanly, other than disabling a notify here.
>> Any suggestion?
>>
>
> Passing a gfp flag to rtmsg_ifinfo() seems a right fix for me, but I don't
> know if there is other better way to fix it.

Indeed. rtnl_notify() already accepts gfp_t.

The following diff fixes it for me:
---
 include/linux/rtnetlink.h |    3 ++-
 net/core/dev.c            |    2 +-
 net/core/rtnetlink.c      |   12 +++++++++---
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index f28544b..0180523 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -15,7 +15,8 @@ extern int rtnetlink_put_metrics(struct sk_buff
*skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
                   u32 id, long expires, u32 error);

-extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
+void __rtmsg_ifinfo(int type, struct net_device *dev, unsigned
change, gfp_t flags);
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);

 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 0918aad..59b90fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5257,7 +5257,7 @@ void __dev_notify_flags(struct net_device *dev,
unsigned int old_flags,
     unsigned int changes = dev->flags ^ old_flags;

     if (gchanges)
-        rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges);
+        __rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges, GFP_ATOMIC);

     if (changes & IFF_UP) {
         if (dev->flags & IFF_UP)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4aedf03..5931af9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1984,14 +1984,15 @@ static int rtnl_dump_all(struct sk_buff *skb,
struct netlink_callback *cb)
     return skb->len;
 }

-void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
+void __rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
+            gfp_t flags)
 {
     struct net *net = dev_net(dev);
     struct sk_buff *skb;
     int err = -ENOBUFS;
     size_t if_info_size;

-    skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), GFP_KERNEL);
+    skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), flags);
     if (skb == NULL)
         goto errout;

@@ -2002,12 +2003,17 @@ void rtmsg_ifinfo(int type, struct net_device
*dev, unsigned int change)
         kfree_skb(skb);
         goto errout;
     }
-    rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+    rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
     return;
 errout:
     if (err < 0)
         rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 }
+
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
+{
+    __rtmsg_ifinfo(type, dev, change, GFP_KERNEL);
+}
 EXPORT_SYMBOL(rtmsg_ifinfo);

 static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
--

Nicolas, I've sent you my .config.
Any better ideas?

Thanks
Alex
