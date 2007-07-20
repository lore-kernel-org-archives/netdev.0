From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [RFC 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Fri, 20 Jul 2007 17:41:44 +0200
Message-ID: <200707201741.45079.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>, Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks a lot for your comments so far.
This generic LRO patch differs from the last one in several points.
A new interface for a "receive in pages" mode has been added and tested
with an eHEA prototype. Seems to work well.

Does this extended interface seem to be sufficient?

Below some more explanations:

Thanks,
Jan-Bernd


Changes to http://www.spinics.net/lists/netdev/msg35490.html :

- Interfaces are changed to allow later support for IPv6 / UDP
- New interface to support "receive in pages"
- TCP checksums are updated properly
- TCP packets with push flag are aggregated now
- Timestamps are now compared using after()


The additional interface to support "receive in pages":

void lro_receive_frags(struct net_lro_mgr *lro_mgr,
                       struct skb_frag_struct *frags,
                       int len, int true_size, void *priv);

void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
                                    struct skb_frag_struct *frags,
                                    int len,
                                    int true_size,
                                    struct vlan_group *vgrp,
                                    u16 vlan_tag,
                                    void *priv);

These functions generate SKBs only for the first packet of an
LRO session. The next fragment list to be aggregated will be
added in the fragment list of that SKB.

The reason why this is a smart approach is described in:
http://www.spinics.net/lists/netdev/msg35634.html

All other packets that do not match the LRO requirements are
put in an SKB and sent to the stack.

Packets that are received in an extra buffer (small packets) and
thus not in an skb fragment can be sent by the driver to the stack
after flushing the appropriate LRO sessions:

void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
                   struct iphdr *iph, struct tcphdr *tcph);

or

void lro_flush_all(struct net_lro_mgr *lro_mgr);
