From: Stefan de Konink <skinkie@xs4all.nl>
Subject: vlan (8021q) 2.6 patches for 3c59x
Date: Fri, 02 Jul 2004 23:52:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E5D934.70000@xs4all.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010408040406050300020604"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010408040406050300020604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

http://bugzilla.kernel.org/show_bug.cgi?id=2991
message requested by Nivedita Singhvi, niv@us.ibm.com


I patched the original VLAN patch for the 3Com 3c59x card to make it 
match a new prototype in 2.6. I would like to request to get it into the 
mainline kernels.

http://www.bewley.net/linux/vlan/patches/

When not applyed, vlantraffic will break if the senders mtu size is too 
big. Since this patch is around so long for 2.4, but also never applyed, 
and this is probably the most used card made by 3Com an out of the box 
working solution would be nice.

I hope you can review the code, since it is not written by me I can only 
tell this works for 3 months on two firewall routers with multiple vlans 
and interfaces based on Linux 2.6.5.



Greetings,

Stefan de Konink

--------------010408040406050300020604
Content-Type: text/x-patch;
 name="3c59x-26.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c59x-26.patch"

*** 3c59x.c.ORG	Fri Apr  9 22:19:58 2004
--- 3c59x.c	Fri Apr  9 22:20:59 2004
***************
*** 329,334 ****
--- 329,337 ----
     code size of a per-interface flag is not worthwhile. */
  static char mii_preamble_required;
  
+ /* The Ethernet Type used for 802.1q tagged frames */
+ #define VLAN_ETHER_TYPE 0x8100
+ 
  #define PFX DRV_NAME ": "
  
  
***************
*** 697,703 ****
  	Wn2_ResetOptions=12,
  };
  enum Window3 {			/* Window 3: MAC/config bits. */
! 	Wn3_Config=0, Wn3_MAC_Ctrl=6, Wn3_Options=8,
  };
  
  #define BFEXT(value, offset, bitcount)  \
--- 700,706 ----
  	Wn2_ResetOptions=12,
  };
  enum Window3 {			/* Window 3: MAC/config bits. */
! 	Wn3_Config=0, Wn3_MaxPktSize=4, Wn3_MAC_Ctrl=6, Wn3_Options=8,
  };
  
  #define BFEXT(value, offset, bitcount)  \
***************
*** 725,731 ****
  	Media_LnkBeat = 0x0800,
  };
  enum Window7 {					/* Window 7: Bus Master control. */
! 	Wn7_MasterAddr = 0, Wn7_MasterLen = 6, Wn7_MasterStatus = 12,
  };
  /* Boomerang bus master control registers. */
  enum MasterCtrl {
--- 728,735 ----
  	Media_LnkBeat = 0x0800,
  };
  enum Window7 {					/* Window 7: Bus Master control. */
! 	Wn7_MasterAddr = 0, Wn7_VlanEtherType=4, Wn7_MasterLen = 6,
! 	Wn7_MasterStatus = 12,
  };
  /* Boomerang bus master control registers. */
  enum MasterCtrl {
***************
*** 821,827 ****
  		pm_state_valid:1,				/* power_state[] has sane contents */
  		open:1,
  		medialock:1,
! 		must_free_region:1;				/* Flag: if zero, Cardbus owns the I/O region */
  	int drv_flags;
  	u16 status_enable;
  	u16 intr_enable;
--- 825,832 ----
  		pm_state_valid:1,				/* power_state[] has sane contents */
  		open:1,
  		medialock:1,
! 		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O region */
! 		large_frames:1;			/* accept large frames */
  	int drv_flags;
  	u16 status_enable;
  	u16 intr_enable;
***************
*** 906,911 ****
--- 911,920 ----
  static void vortex_tx_timeout(struct net_device *dev);
  static void acpi_set_WOL(struct net_device *dev);
  static struct ethtool_ops vortex_ethtool_ops;
+ #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+ static void set_8021q_mode(struct net_device *dev, int enable);
+ #endif
+ 
  
  /* This driver uses 'options' to pass the media type, full-duplex flag, etc. */
  /* Option count limit only -- unlimited interfaces are supported. */
***************
*** 1166,1171 ****
--- 1175,1181 ----
  	dev->base_addr = ioaddr;
  	dev->irq = irq;
  	dev->mtu = mtu;
+ 	vp->large_frames = mtu > 1500;
  	vp->drv_flags = vci->drv_flags;
  	vp->has_nway = (vci->drv_flags & HAS_NWAY) ? 1 : 0;
  	vp->io_size = vci->io_size;
***************
*** 1618,1624 ****
  
  	/* Set the full-duplex bit. */
  	outw(	((vp->info1 & 0x8000) || vp->full_duplex ? 0x20 : 0) |
! 		 	(dev->mtu > 1500 ? 0x40 : 0) |
  			((vp->full_duplex && vp->flow_ctrl && vp->partner_flow_ctrl) ? 0x100 : 0),
  			ioaddr + Wn3_MAC_Ctrl);
  
--- 1628,1634 ----
  
  	/* Set the full-duplex bit. */
  	outw(	((vp->info1 & 0x8000) || vp->full_duplex ? 0x20 : 0) |
! 		 	(vp->large_frames ? 0x40 : 0) |
  			((vp->full_duplex && vp->flow_ctrl && vp->partner_flow_ctrl) ? 0x100 : 0),
  			ioaddr + Wn3_MAC_Ctrl);
  
***************
*** 1702,1707 ****
--- 1712,1721 ----
  	}
  	/* Set receiver mode: presumably accept b-case and phys addr only. */
  	set_rx_mode(dev);
+ #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+ 	/* enable 802.1q tagged frames */
+ 	set_8021q_mode(dev, 1);
+ #endif
  	outw(StatsEnable, ioaddr + EL3_CMD); /* Turn on statistics. */
  
  //	issue_and_wait(dev, SetTxStart|0x07ff);
***************
*** 1844,1850 ****
  						/* Set the full-duplex bit. */
  						EL3WINDOW(3);
  						outw(	(vp->full_duplex ? 0x20 : 0) |
! 								(dev->mtu > 1500 ? 0x40 : 0) |
  								((vp->full_duplex && vp->flow_ctrl && vp->partner_flow_ctrl) ? 0x100 : 0),
  								ioaddr + Wn3_MAC_Ctrl);
  						if (vortex_debug > 1)
--- 1858,1864 ----
  						/* Set the full-duplex bit. */
  						EL3WINDOW(3);
  						outw(	(vp->full_duplex ? 0x20 : 0) |
! 								(vp->large_frames ? 0x40 : 0) |
  								((vp->full_duplex && vp->flow_ctrl && vp->partner_flow_ctrl) ? 0x100 : 0),
  								ioaddr + Wn3_MAC_Ctrl);
  						if (vortex_debug > 1)
***************
*** 2069,2074 ****
--- 2083,2092 ----
  			issue_and_wait(dev, RxReset|0x07);
  			/* Set the Rx filter to the current state. */
  			set_rx_mode(dev);
+ #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+ 			/* enable 802.1q VLAN tagged frames */
+ 			set_8021q_mode(dev, 1);
+ #endif
  			outw(RxEnable, ioaddr + EL3_CMD); /* Re-enable the receiver. */
  			outw(AckIntr | HostError, ioaddr + EL3_CMD);
  		}
***************
*** 2673,2678 ****
--- 2691,2701 ----
  	outw(RxDisable, ioaddr + EL3_CMD);
  	outw(TxDisable, ioaddr + EL3_CMD);
  
+ #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+ 	/* Disable receiving 802.1q tagged frames */
+ 	set_8021q_mode(dev, 0);
+ #endif
+ 
  	if (dev->if_port == XCVR_10base2)
  		/* Turn off thinnet power.  Green! */
  		outw(StopCoax, ioaddr + EL3_CMD);
***************
*** 2924,2929 ****
--- 2947,2996 ----
  	outw(new_mode, ioaddr + EL3_CMD);
  }
  
+ #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+ /* Setup the card so that it can receive frames with an 802.1q VLAN tag.
+    Note that this must be done after each RxReset due to some backwards
+    compatibility logic in the Cyclone and Tornado ASICs */
+ static void set_8021q_mode(struct net_device *dev, int enable)
+ {
+ 	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+ 	long ioaddr = dev->base_addr;
+ 	int old_window = inw(ioaddr + EL3_CMD);
+ 	int mac_ctrl;
+ 	
+ 	if (vp->drv_flags&IS_CYCLONE || vp->drv_flags&IS_TORNADO) {
+ 		/* cyclone and tornado chipsets can recognize 802.1q
+ 		 * tagged frames and treat them correctly */
+ 
+ 		int max_pkt_size = dev->mtu+14;	/* MTU+Ethernet header */
+ 		if (enable)
+ 			max_pkt_size += 4;	/* 802.1Q VLAN tag */
+ 
+ 		EL3WINDOW(3);
+ 		outw(max_pkt_size, ioaddr+Wn3_MaxPktSize);
+ 
+ 		/* set VlanEtherType to let the hardware checksumming
+ 		   treat tagged frames correctly */
+ 		EL3WINDOW(7);
+ 		outw(VLAN_ETHER_TYPE, ioaddr+Wn7_VlanEtherType);
+ 	} else {
+ 		/* on older cards we have to enable large frames */
+ 
+ 		vp->large_frames = dev->mtu > 1500 || enable;
+ 
+ 		EL3WINDOW(3);
+ 		mac_ctrl = inw(ioaddr+Wn3_MAC_Ctrl);
+ 		if (vp->large_frames)
+ 			mac_ctrl |= 0x40;
+ 		else
+ 			mac_ctrl &= ~0x40;
+ 		outw(mac_ctrl, ioaddr+Wn3_MAC_Ctrl);
+ 	}
+ 
+ 	EL3WINDOW(old_window);
+ }
+ #endif
+ 
  /* MII transceiver control section.
     Read and write the MII registers using software-generated serial
     MDIO protocol.  See the MII specifications or DP83840A data sheet

--------------010408040406050300020604--
