From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Tue, 09 Apr 2013 11:08:33 -0700
Message-ID: <1365530913.29336.50.camel@oc1677441337.ibm.com>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:46005 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763112Ab3DISJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 14:09:10 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Tue, 9 Apr 2013 12:09:09 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9E6576E807A
	for <netdev@vger.kernel.org>; Tue,  9 Apr 2013 14:08:48 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39I8gsA243420
	for <netdev@vger.kernel.org>; Tue, 9 Apr 2013 14:08:45 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39I8ZoK009529
	for <netdev@vger.kernel.org>; Tue, 9 Apr 2013 12:08:35 -0600
In-Reply-To: <1365501445-9712-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 17:57 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> This reverts commit 9dcc71e1fdbb7aa10d92a3d35e8a201adc84abd0.
> It apparently breaks my vxlan tests between different namespaces.
> 
I haven't tried vxlan with network namespaces.
This patch effects the following 2 code paths
- when source and destination endpoints are on the same bridge and
  route short-circuiting is enabled. I guess you are not hitting
  this path as this is possible only if you specify 'rsc' flag when
  creating vxlan device.
- when source and destination endpoints belonging to different vni's
  are on 2 different bridges on the same host. encap bypass is done
  in this scenario by checking if rt_flags has RTCF_LOCAL set. I think
  you must be hitting this path and the following patch should fix
  it by only doing bypass if the source and dest devices belong to 
  the same net. Can you try it and see if it fixes your tests?

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9a64715..d53d8cb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1012,12 +1012,15 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	/* Bypass encapsulation if the destination is local */
-	if (rt->rt_flags & RTCF_LOCAL) {
+	/* Bypass encapsulation if the destination is local and in the same
+	   network namespace.
+	 */
+	if (net_eq(dev_net(dev), dev_net(rt->dst.dev)) &&
+	     rt->rt_flags & RTCF_LOCAL) {
 		struct vxlan_dev *dst_vxlan;
 
+		dst_vxlan = vxlan_find_vni(dev_net(rt->dst.dev), vni);
 		ip_rt_put(rt);
-		dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
 		if (!dst_vxlan)
 			goto tx_error;
 		vxlan_encap_bypass(skb, vxlan, dst_vxlan);

  
Thanks
Sridhar
