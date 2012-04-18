From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Wed, 18 Apr 2012 15:57:23 +0800
Message-ID: <4F8E73E3.6080900@huawei.com>
References: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
 <20120417085248.3e642294@nehalam.linuxnetplumber.net>
 <1334681323.2472.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ctrix+debianbugs@navynet.it,
	peter.huangpeng@gmail.com, harry.majun@huawei.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1334681323.2472.43.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012/4/18 0:48, Eric Dumazet wrote:
> On Tue, 2012-04-17 at 08:52 -0700, Stephen Hemminger wrote:
>
>> This check seems like a disaster waiting to happen when the next
>> change to DST table happens.
>
> Please Peter Document this, adding a new DST_FAKE_RTABLE flag
>
> #define DST_FAKE_RTABLE DST_NOPEER
>
> or just use a bit, we have plenty of them available.
>


Add DST_FAKE_RTABLE to dst_entry, this is the new patch.
Is this ok?

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>
---
  include/linux/netfilter_bridge.h |    8 ++++++++
  include/net/dst.h                |    1 +
  net/bridge/br_forward.c          |    1 +
  net/bridge/br_netfilter.c        |    8 ++------
  4 files changed, 12 insertions(+), 6 deletions(-)
diff --git a/include/linux/netfilter_bridge.h 
b/include/linux/netfilter_bridge.h
index 0ddd161..eb09e3b 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -104,9 +104,17 @@ struct bridge_skb_cb {
         } daddr;
  };

+static inline void br_drop_fake_rtable(struct sk_buff *skb) {
+       struct dst_entry *dst = skb_dst(skb);
+       /* abuse fact that only fake_rtable has DST_FAKE_RTABLE set */
+       if (dst && (dst->flags & DST_FAKE_RTABLE))
+               skb_dst_drop(skb);
+}
+
  #else
  #define nf_bridge_maybe_copy_header(skb)       (0)
  #define nf_bridge_pad(skb)                     (0)
+#define br_drop_fake_rtable(skb)               (0)
  #endif /* CONFIG_BRIDGE_NETFILTER */

  #endif /* __KERNEL__ */
diff --git a/include/net/dst.h b/include/net/dst.h
index 59c5d18..b094030 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -55,6 +55,7 @@ struct dst_entry {
  #define DST_NOCACHE            0x0010
  #define DST_NOCOUNT            0x0020
  #define DST_NOPEER             0x0040
+#define DST_FAKE_RTABLE                0x0080

         short                   error;
         short                   obsolete;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 61f6534..a2098e3 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -47,6 +47,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
                 kfree_skb(skb);
         } else {
                 skb_push(skb, ETH_HLEN);
+               br_drop_fake_rtable(skb);
                 dev_queue_xmit(skb);
         }

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index dec4f38..d7f49b6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -156,7 +156,7 @@ void br_netfilter_rtable_init(struct net_bridge *br)
         rt->dst.dev = br->dev;
         rt->dst.path = &rt->dst;
         dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
-       rt->dst.flags   = DST_NOXFRM | DST_NOPEER;
+       rt->dst.flags   = DST_NOXFRM | DST_NOPEER | DST_FAKE_RTABLE;
         rt->dst.ops = &fake_dst_ops;
  }

@@ -694,11 +694,7 @@ static unsigned int br_nf_local_in(unsigned int 
hook, struct sk_buff *skb,
                                    const struct net_device *out,
                                    int (*okfn)(struct sk_buff *))
  {
-       struct rtable *rt = skb_rtable(skb);
-
-       if (rt && rt == bridge_parent_rtable(in))
-               skb_dst_drop(skb);
-
+       br_drop_fake_rtable(skb);
         return NF_ACCEPT;
  }
