From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next 19/20] net: plip: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 23:47:57 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1312272338170.2018@localhost6.localdomain6>
References: <52BD22ED.4030302@huawei.com>  <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>  <1388163982.30298.12.camel@joe-AO722>  <alpine.DEB.2.02.1312272112110.2018@localhost6.localdomain6> <1388177217.30298.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <julia.lawall@lip6.fr>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388177217.30298.24.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> members after the ethernet address, or the u8[6] address
> passed to ether_addr_equal is not going to access past
> the end of memory or the structure, then
> ether_addr_equal_64bits should be used in lieu of
> ether_addr_equal.

I tried the following semantic patch:

@r@
type T;
T *eth;
identifier fld;
type T1;
T1 *eth1;
identifier fld1;
expression e1;
position p;
@@

ether_addr_equal@p(eth->fld, eth1->fld1)

@ok@
type r.T, t1, t2;
identifier r.fld, fld2;
@@

T { ...
    t1 fld[...];
    t2 fld2;
    ...
  };

@ok1@
type r.T1, t1, t2;
identifier r.fld1, fld2;
@@

T1 { ...
    t1 fld1[...];
    t2 fld2;
    ...
  };

@depends on ok && ok1@
position r.p;
@@

*ether_addr_equal@p(...)

The first rule finds an existing call to ether_addr_equal where both 
arguments are structure field references.  It gets the type of the 
structure in each case, and notes the field name.  The next two rules 
check each of the structure declarations to ensure that the field is 
declared as an array and it is followed by at least one other field.  The 
last rule generates some output for cases where both fields pass the test.

Note that this is not at all exhaustive, because it is not checking cases 
where one argument is a parameter that is passed from some call site where 
the argument is a field that has this property.  Thus, it does not find 
the case in drivers/net/ethernet/intel/i40e/i40e_main.c.  Nevertheless, it 
does find a few occurrences, as shown below.  In this output, - indicates 
an item of interest, not something to be removed.  It is not a patch, even 
though it looks like one.

One can get quite a lot more results if one doesn't require that both 
arguments satisfy the property, ie allowing one argument to be a function 
parameter rather than a structure field reference.  So perhaps it would be 
worth making a (more complicated) semantic patch to find such cases.

julia

diff -u -p /var/linuxes/linux-next/drivers/net/wireless/ipw2x00/libipw_rx.c /tmp/nothing/drivers/net/wireless/ipw2x00/libipw_rx.c
--- /var/linuxes/linux-next/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ /tmp/nothing/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -1468,7 +1468,6 @@ static inline int is_same_network(struct
 	 * as one network */
 	return ((src->ssid_len == dst->ssid_len) &&
 		(src->channel == dst->channel) &&
-		ether_addr_equal(src->bssid, dst->bssid) &&
 		!memcmp(src->ssid, dst->ssid, src->ssid_len));
 }
 
diff -u -p /var/linuxes/linux-next/drivers/scsi/fcoe/fcoe_ctlr.c /tmp/nothing/drivers/scsi/fcoe/fcoe_ctlr.c
--- /var/linuxes/linux-next/drivers/scsi/fcoe/fcoe_ctlr.c
+++ /tmp/nothing/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -339,7 +339,6 @@ static void fcoe_ctlr_announce(struct fc
 	spin_unlock_bh(&fip->ctlr_lock);
 	sel = fip->sel_fcf;
 
-	if (sel && ether_addr_equal(sel->fcf_mac, fip->dest_addr))
 		goto unlock;
 	if (!is_zero_ether_addr(fip->dest_addr)) {
 		printk(KERN_NOTICE "libfcoe: host%d: "
diff -u -p /var/linuxes/linux-next/drivers/scsi/fcoe/fcoe_sysfs.c /tmp/nothing/drivers/scsi/fcoe/fcoe_sysfs.c
--- /var/linuxes/linux-next/drivers/scsi/fcoe/fcoe_sysfs.c
+++ /tmp/nothing/drivers/scsi/fcoe/fcoe_sysfs.c
@@ -657,7 +657,6 @@ static int fcoe_fcf_device_match(struct
 	if (new->switch_name == old->switch_name &&
 	    new->fabric_name == old->fabric_name &&
 	    new->fc_map == old->fc_map &&
-	    ether_addr_equal(new->mac, old->mac))
 		return 1;
 	return 0;
 }
diff -u -p /var/linuxes/linux-next/drivers/staging/slicoss/slicoss.c /tmp/nothing/drivers/staging/slicoss/slicoss.c
--- /var/linuxes/linux-next/drivers/staging/slicoss/slicoss.c
+++ /tmp/nothing/drivers/staging/slicoss/slicoss.c
@@ -787,8 +787,6 @@ static bool slic_mac_filter(struct adapt
 			struct mcast_address *mcaddr = adapter->mcastaddrs;
 
 			while (mcaddr) {
-				if (ether_addr_equal(mcaddr->address,
-						     ether_frame->ether_dhost)) {
 					adapter->rcv_multicasts++;
 					netdev->stats.multicast++;
 					return true;
diff -u -p /var/linuxes/linux-next/drivers/staging/vt6655/wpactl.c /tmp/nothing/drivers/staging/vt6655/wpactl.c
--- /var/linuxes/linux-next/drivers/staging/vt6655/wpactl.c
+++ /tmp/nothing/drivers/staging/vt6655/wpactl.c
@@ -394,7 +394,6 @@ int wpa_set_keys(PSDevice pDevice, void
 
 		} else {
 			// Key Table Full
-			if (ether_addr_equal(param->addr, pDevice->abyBSSID)) {
 				//DBG_PRN_WLAN03(("return NDIS_STATUS_INVALID_DATA -Key Table Full.2\n"));
 				//spin_unlock_irq(&pDevice->lock);
 				return -EINVAL;
