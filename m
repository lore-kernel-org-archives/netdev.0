From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 2/2] macvtap: restore vlan header on user read
Date: Thu, 3 May 2012 17:31:10 +0300
Message-ID: <20120503143108.GA20969@redhat.com>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
 <1335373316-612-1-git-send-email-basil.gor@gmail.com>
 <m162cngitu.fsf@fess.ebiederm.org>
 <20120503130751.GB26366@redhat.com>
 <m1ehr1l711.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Basil Gor <basil.gor@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756146Ab2ECObG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 10:31:06 -0400
Content-Disposition: inline
In-Reply-To: <m1ehr1l711.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 06:37:46AM -0700, Eric W. Biederman wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> 
> > On Wed, Apr 25, 2012 at 10:31:25PM -0700, Eric W. Biederman wrote:
> >> Basil Gor <basil.gor@gmail.com> writes:
> >> 
> >> > Vlan tag is restored during buffer transmit to a network device (bridge
> >> > port) in bridging code in case of tun/tap driver. In case of macvtap it
> >> > has to be done explicitly. Otherwise vlan_tci is ignored and user always
> >> > gets untagged packets.
> >> 
> >> We could quibble about efficiencies but this looks good except for
> >> macvtap_recvmsg which isn't setting the auxdata for the vlan header.
> >> 
> >> Eric
> >
> > Right. I'm guessing we need to support old userspace
> > so if there's auxdata, put vlan there but if not,
> > put the vlan in the packet like this patch does.
> 
> This patch isn't horrible.
> 
> Still why copy the skb when you can just split the copy to userspace
> into a couple of pieces?
> 
> We don't need to change the skb and changing the skb looks like
> it is likely to confuse things and cause bugs because we are
> not working with a consistent model of how vlan information
> is encoded.
> 
> Still something needs to happen and this works in more cases even if it
> isn't perfect.
> 
> Eric

Absolutely. And it's easier than I thought.
So we can do something like the below (warning: compiled only).
Basil - want to take a look?
My only concern if we put this logic in an out of way
driver like macvtap will people remember to update it?
Maybe better to update skb_copy_datagram_const_iovec which is in core?


Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0427c65..5a1724c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1,5 +1,6 @@
 #include <linux/etherdevice.h>
 #include <linux/if_macvlan.h>
+#include <linux/if_vlan.h>
 #include <linux/interrupt.h>
 #include <linux/nsproxy.h>
 #include <linux/compat.h>
@@ -759,6 +760,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	struct macvlan_dev *vlan;
 	int ret;
 	int vnet_hdr_len = 0;
+	int vlan_offset = 0;
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
@@ -776,8 +778,29 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 
 	len = min_t(int, skb->len, len);
 
-	ret = skb_copy_datagram_const_iovec(skb, 0, iv, vnet_hdr_len, len);
+	if (vlan_tx_tag_present(skb)) {
+		struct {
+			__be16 h_vlan_proto;
+			__be16 h_vlan_TCI;
+		} veth;
+ 		veth.h_vlan_proto = htons(ETH_P_8021Q);
+ 		veth.h_vlan_TCI = vlan_tx_tag_get(skb);
+
+		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
+		ret = skb_copy_datagram_const_iovec(skb, 0, iv, vnet_hdr_len,
+						    vlan_offset);
+		if (ret)
+			goto done;
+		ret = memcpy_toiovecend(iv, (unsigned char *)&veth, vlan_offset,
+					sizeof veth);
+		if (ret)
+			goto done;
+		vlan_offset += sizeof veth;
+	}
+	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, vnet_hdr_len,
+					    len);
 
+done:
 	rcu_read_lock_bh();
 	vlan = rcu_dereference_bh(q->vlan);
 	if (vlan)
