From: Joe Perches <joe@perches.com>
Subject: [PATCH] i40e: use ether_addr_equal_64bits
Date: Fri, 27 Dec 2013 13:56:11 -0800
Message-ID: <1388181371.30298.38.camel@joe-AO722>
References: <52BD22ED.4030302@huawei.com>
	 <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1388163982.30298.12.camel@joe-AO722>
	 <alpine.DEB.2.02.1312272112110.2018@localhost6.localdomain6>
	 <1388177217.30298.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net,
	Julia Lawall <julia.lawall@lip6.fr>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388177217.30298.24.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All ether_addr_equal tests in i40e can use the
slightly more efficient ether_addr_equal_64bits.

All addresses passed to the various functions that
use ether_addr_equal are using structs that have 2
or more bytes of additional data after the mac addr
being tested.

struct i40e_mac_filter.macaddr[6] (followed by s16 vlan)
struct net_device.dev_addr (pointer to char array of MAX_ADDR_LEN)
struct sockaddr.sa_data (array of 14 bytes)
struct netdev_hw_addr.addr (pointer to char array of MAX_ADDR_LEN)

Signed-off-by: Joe Perches <joe@perches.com>
---

On Fri, 2013-12-27 at 12:46 -0800, Joe Perches wrote:
> On Fri, 2013-12-27 at 21:12 +0100, Julia Lawall wrote:
> > On Fri, 27 Dec 2013, Joe Perches wrote:
> > 
> > > On Fri, 2013-12-27 at 07:48 -0800, Eric Dumazet wrote:
> > > > On Fri, 2013-12-27 at 14:49 +0800, Ding Tianhong wrote:
> > > > > Use possibly more efficient ether_addr_equal
> > > > > to instead of memcmp.
> > > []
> > > > > diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
> > > []
> > > > > @@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
> > > > >  
> > > > >  	if(*eth->h_dest&1)
> > > > >  	{
> > > > > -		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
> > > > > +		if(ether_addr_equal(eth->h_dest, dev->broadcast))
> > > > >  			skb->pkt_type=PACKET_BROADCAST;
> > > > >  		else
> > > > >  			skb->pkt_type=PACKET_MULTICAST;
> > > > 
> > > > What about :
> > > > 
> > > >         if (is_multicast_ether_addr(eth->h_dest)) {
> > > >                 if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
> > > >                         skb->pkt_type = PACKET_BROADCAST;
> > > >                 else
> > > >                         skb->pkt_type = PACKET_MULTICAST;
> > > >         }
> > > 
> > > That is better though I wonder how many systems are
> > > still using laplink via parallel null-printer cables.
> > > 
> > > No matter, better is better.
> > > 
> > > The same optimization using ether_addr_equal_64bits
> > > may be possible to do in other places given other
> > > structs too.
> > > 
> > > Perhaps it's a possible spatch/coccinelle conversion,
> > > 
> > > I don't know spatch well enough to know if a
> > > mechanism to check if structure members have other
> > > fields that follow them in the structure or if the
> > > structure member is an array of a minimum size.
> > > 
> > > Maybe Julia does.  (cc'd)
> > 
> > I'm not sure to competely understand the issues.  Could you explain more?
> 
> Hi Julia.
> 
> Maybe this explanation is helpful?
> 
> ethernet addresses are u8[6] (48 bits)
> 
> ether_addr_equal_64bits gets passed a pointer to u8[8]
> and is more efficient on 64 bit architectures than
> ether_addr_equal because the test can be done with a
> single compare and shift.
> 
> The idea is not to access past the end of the ethernet
> address as appropriate (think pointer to eeprom or other
> such end-of-addressable memory conditions)
> 
> If a struct containing an ethernet address has additional
> members after the ethernet address, or the u8[6] addressa
> passed to ether_addr_equal is not going to access past
> the end of memory or the structure, then
> ether_addr_equal_64bits should be used in lieu of
> ether_addr_equal.

I believe this is correct, but maybe the
conditions for using ether_addr_equal_64bits
could be documented a bit better.

Jeff/Intel folk?  What do you think?

 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index efdf8a2..4c1d35c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -992,7 +992,7 @@ static struct i40e_mac_filter *i40e_find_filter(struct i40e_vsi *vsi,
 		return NULL;
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
-		if ((ether_addr_equal(macaddr, f->macaddr)) &&
+		if (ether_addr_equal_64bits(macaddr, f->macaddr) &&
 		    (vlan == f->vlan)    &&
 		    (!is_vf || f->is_vf) &&
 		    (!is_netdev || f->is_netdev))
@@ -1020,7 +1020,7 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 		return NULL;
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
-		if ((ether_addr_equal(macaddr, f->macaddr)) &&
+		if (ether_addr_equal_64bits(macaddr, f->macaddr) &&
 		    (!is_vf || f->is_vf) &&
 		    (!is_netdev || f->is_netdev))
 			return f;
@@ -1209,7 +1209,7 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 
 	netdev_info(netdev, "set mac address=%pM\n", addr->sa_data);
 
-	if (ether_addr_equal(netdev->dev_addr, addr->sa_data))
+	if (ether_addr_equal_64bits(netdev->dev_addr, addr->sa_data))
 		return 0;
 
 	if (vsi->type == I40E_VSI_MAIN) {
@@ -1409,21 +1409,24 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 
 		if (is_multicast_ether_addr(f->macaddr)) {
 			netdev_for_each_mc_addr(mca, netdev) {
-				if (ether_addr_equal(mca->addr, f->macaddr)) {
+				if (ether_addr_equal_64bits(mca->addr,
+							    f->macaddr)) {
 					found = true;
 					break;
 				}
 			}
 		} else {
 			netdev_for_each_uc_addr(uca, netdev) {
-				if (ether_addr_equal(uca->addr, f->macaddr)) {
+				if (ether_addr_equal_64bits(uca->addr,
+							    f->macaddr)) {
 					found = true;
 					break;
 				}
 			}
 
 			for_each_dev_addr(netdev, ha) {
-				if (ether_addr_equal(ha->addr, f->macaddr)) {
+				if (ether_addr_equal_64bits(ha->addr,
+							    f->macaddr)) {
 					found = true;
 					break;
 				}
@@ -1889,7 +1892,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		if (is_netdev) {
 			if (f->vlan &&
-			    ether_addr_equal(netdev->dev_addr, f->macaddr))
+			    ether_addr_equal_64bits(netdev->dev_addr,
+						    f->macaddr))
 				filter_count++;
 		}
 
