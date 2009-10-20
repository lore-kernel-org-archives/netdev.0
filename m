From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 10:37:36 -0700
Message-ID: <4ADDF560.1020509@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50152 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbZJTRhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 13:37:40 -0400
In-Reply-To: <4ADD41F5.5080707@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2009 09:52 PM, Ben Greear wrote:
> Eric Dumazet wrote:
>> Ben Greear a =E9crit :
>>> I'm having strange issues when running pktgen on 10G interfaces whi=
le
>>> also running
>>> pktgen on mac-vlans on that interface, when the mac-vlan pktgen thr=
eads
>>> are on a different
>>> CPU.


I think I found the problem.  First, lockdep was not the issue, and mac=
-vlans
were properly setting up the lockdep keys.  I would have expected lockd=
ep to
figure out I was trying to lock a non-valid lock, but maybe something e=
lse
kept that from happening.

Second:  I think the problem can only happen on my code tree because I
added code to allow mac-vlans to return NETDEV_TX_BUSY
when a hacked varient of dev_queue_xmit decided it could not immediatel=
y
transmit a packet.  Without my change, a packet would have to be create=
d fresh
in this scenario, so it would not hit the bug.

However, I think pktgen might still need a similar fix because other dr=
ivers or
logic might also change the skb tx-queue map.

Here is the problem, or at least one of them:

pktgen tries to xmit, but gets NETDEV_TX_BUSY.  During the xmit attempt=
, the
skb queue map was changed to that of the underlying device, which was 4=
=2E  Note
that mac-vlans have only a single tx queue.
pktgen will retry this skb, but it never resets the skb queue back to 0=
=2E
This means that it will soon be accessing txq[4], which is corrupting
memory.  Things rapidly decline from here!

Here is a patch for comment, in case the pktgen folks would like to
apply something similar:

@@ -3991,11 +4001,26 @@ static void pktgen_xmit(struct pktgen_dev *pkt_=
dev, u64 now)
                 }
         }

-       if (!pkt_dev->skb) {
+       if ((!pkt_dev->skb) || (pkt_dev->clone_count <=3D 1)) {
+               /** If clone count is low, that might be because device=
 is a layered
+                * virtual device, like mac-vlan.  In that case, the qu=
eue-map may be
+                * changed while transmitting out the lower levels, so =
we need to
+                * reset this here so we don't accidentally use a bogus=
 queue.
+                */
+       reset_queue_map:
                 set_cur_queue_map(pkt_dev);
                 queue_map =3D pkt_dev->cur_queue_map;
         } else {
                 queue_map =3D skb_get_queue_mapping(pkt_dev->skb);
+               if (unlikely(queue_map >=3D odev->num_tx_queues)) {
+                       static int do_once =3D 1;
+                       if (do_once) {
+                               printk("pktgen ERROR:  queue_map range =
error, queue_map: %i  num_tx_queues: %i  iface: %s\n",
+                                      queue_map, odev->num_tx_queues, =
odev->name);
+                               WARN_ON(1);
+                       }
+                       goto reset_queue_map;
+               }
         }

         txq =3D netdev_get_tx_queue(odev, queue_map);


Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

