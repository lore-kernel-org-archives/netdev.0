From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Thu, 11 Apr 2013 16:59:59 -0700
Message-ID: <1365724799.3563.5.camel@sridhar.usor.ibm.com>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com>
	 <1365530913.29336.50.camel@oc1677441337.ibm.com>
	 <1365646215.25993.3.camel@cr0> <516641CF.4020101@us.ibm.com>
	 <1937058599.2214531.1365659704193.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:60657 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889Ab3DLAAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 20:00:06 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 11 Apr 2013 20:00:05 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C890A38C8047
	for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 20:00:02 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C002dQ55443644
	for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 20:00:02 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C000tH009914
	for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 20:00:01 -0400
In-Reply-To: <1937058599.2214531.1365659704193.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 01:55 -0400, Cong Wang wrote:
> 
> ----- Original Message -----
> > On 4/10/2013 7:10 PM, Cong Wang wrote:
> > >> - when source and destination endpoints belonging to different vni's
> > >>    are on 2 different bridges on the same host. encap bypass is done
> > >>    in this scenario by checking if rt_flags has RTCF_LOCAL set. I think
> > >>    you must be hitting this path and the following patch should fix
> > >>    it by only doing bypass if the source and dest devices belong to
> > >>    the same net. Can you try it and see if it fixes your tests?
> > > I just tested it, unfortunately it doesn't work, the bug still exists.
> > >
> > > If you need any other info, please let me know.
> > So does it mean that you are hitting the if condition that does encap
> > bypass
> > even afterthe net_eq() check? Do the tests pass If you comment out the
> > 'if' block?
> 
> Yes, after adding a printk inside the 'if' block, I got:
> 
> [   71.456329] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
> [   71.596551] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth1
> [   72.028574] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
> [   72.436384] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth1
> [   73.028576] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
> [   73.185134] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
> [   73.436582] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth1
> [   74.184251] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
> 
> It seems the dst dev is the dev which vxlan0 setup on, so
> there is no way to know if the packet is targeted for a different netns
> on the same host, at least I don't find such RTCF_* flag.

OK. i was able to setup vxlan between 2 net namespaces and reproduce
the issue.

The following patch fixes the issue for me. can you try it out?

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9a64715..d6509de 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1013,7 +1013,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	/* Bypass encapsulation if the destination is local */
-	if (rt->rt_flags & RTCF_LOCAL) {
+	if (rt->dst.dev->flags & IFF_LOOPBACK) {
 		struct vxlan_dev *dst_vxlan;
 
 		ip_rt_put(rt);
