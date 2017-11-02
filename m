From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v15] openvswitch: enable NSH support
Date: Thu, 2 Nov 2017 10:50:38 +0800
Message-ID: <20171102025037.GA54997@localhost.localdomain>
References: <1509508981-66202-1-git-send-email-yi.y.yang@intel.com>
 <CAOrHB_DfrpQF_W9CL5q-=0aKSh5sBmcMqTvs9HeupeYQFoVJ6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>,
        Eric Garver <e@erig.me>,
        "David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38086 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752051AbdKBCzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 22:55:25 -0400
Content-Disposition: inline
In-Reply-To: <CAOrHB_DfrpQF_W9CL5q-=0aKSh5sBmcMqTvs9HeupeYQFoVJ6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 02, 2017 at 08:52:40AM +0800, Pravin Shelar wrote:
> On Tue, Oct 31, 2017 at 9:03 PM, Yi Yang <yi.y.yang@intel.com> wrote:
> >
> > OVS master and 2.8 branch has merged NSH userspace
> > patch series, this patch is to enable NSH support
> > in kernel data path in order that OVS can support
> > NSH in compat mode by porting this.
> >
> > Signed-off-by: Yi Yang <yi.y.yang@intel.com>
> > ---
> I have comment related to checksum, otherwise patch looks good to me.

Pravin, thank you for your comments, the below part is incremental patch
for checksum, please help check it, I'll send out v16 with this after
you confirm.

diff --git a/net/nsh/nsh.c b/net/nsh/nsh.c
index 2764682..d7da99a 100644
--- a/net/nsh/nsh.c
+++ b/net/nsh/nsh.c
@@ -36,6 +36,7 @@ int nsh_push(struct sk_buff *skb, const struct nshhdr *pushed_nh)
 	nh = (struct nshhdr *)(skb->data);
 	memcpy(nh, pushed_nh, length);
 	nh->np = next_proto;
+	skb_postpush_rcsum(skb, nh, length);
 
 	skb->protocol = htons(ETH_P_NSH);
 	skb_reset_mac_header(skb);
@@ -63,7 +64,7 @@ int nsh_pop(struct sk_buff *skb)
 	if (!inner_proto)
 		return -EAFNOSUPPORT;
 
-	skb_pull(skb, length);
+	skb_pull_rcsum(skb, length);
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	skb_reset_mac_len(skb);
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index dd1449d..5ba0e35 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -671,6 +671,7 @@ static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		return err;
 
 	nh = nsh_hdr(skb);
+	skb_postpull_rcsum(skb, nh, length);
 	flags = nsh_get_flags(nh);
 	flags = OVS_MASKED(flags, key.base.flags, mask.base.flags);
 	flow_key->nsh.base.flags = flags;
@@ -698,6 +699,7 @@ static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	default:
 		return -EINVAL;
 	}
+	skb_postpush_rcsum(skb, nh, length);
 	return 0;
 }
 
