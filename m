From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Thu, 11 Apr 2013 01:55:04 -0400 (EDT)
Message-ID: <1937058599.2214531.1365659704193.JavaMail.root@redhat.com>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com> <1365530913.29336.50.camel@oc1677441337.ibm.com> <1365646215.25993.3.camel@cr0> <516641CF.4020101@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:58160 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705Ab3DKFzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 01:55:08 -0400
In-Reply-To: <516641CF.4020101@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> On 4/10/2013 7:10 PM, Cong Wang wrote:
> >> - when source and destination endpoints belonging to different vni's
> >>    are on 2 different bridges on the same host. encap bypass is done
> >>    in this scenario by checking if rt_flags has RTCF_LOCAL set. I think
> >>    you must be hitting this path and the following patch should fix
> >>    it by only doing bypass if the source and dest devices belong to
> >>    the same net. Can you try it and see if it fixes your tests?
> > I just tested it, unfortunately it doesn't work, the bug still exists.
> >
> > If you need any other info, please let me know.
> So does it mean that you are hitting the if condition that does encap
> bypass
> even afterthe net_eq() check? Do the tests pass If you comment out the
> 'if' block?

Yes, after adding a printk inside the 'if' block, I got:

[   71.456329] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
[   71.596551] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth1
[   72.028574] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
[   72.436384] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth1
[   73.028576] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
[   73.185134] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0
[   73.436582] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth1
[   74.184251] vxlan: dev: vxlan0, dst: 224.8.8.8, dst dev: veth0

It seems the dst dev is the dev which vxlan0 setup on, so
there is no way to know if the packet is targeted for a different netns
on the same host, at least I don't find such RTCF_* flag.

I'd propose to revert that commit partially:

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9a64715..0847564 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1012,18 +1012,6 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
                goto tx_error;
        }
 
-       /* Bypass encapsulation if the destination is local */
-       if (rt->rt_flags & RTCF_LOCAL) {
-               struct vxlan_dev *dst_vxlan;
-
-               ip_rt_put(rt);
-               dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
-               if (!dst_vxlan)
-                       goto tx_error;
-               vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-               return NETDEV_TX_OK;
-       }
-
        memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
        IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
                              IPSKB_REROUTED);


> 
> Can you share your test config/scripts so that i can try out your setup if
> it is not toocomplicated?
> 


Sure, here is what I did:

1) create a veth pair: veth0 and veth1
2) create a new netns
3) move veth1 to the new netns
4) setup vxlan0 on veth0
5) setup vxlan0 on veth1 in the new netns
6) ping remote, that is the IP of the vxlan0 in new netns
