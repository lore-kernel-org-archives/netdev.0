From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v4 [PATCH 7/9] ipv4: Fix ipmr unregister device oops
Date: Tue, 15 Jul 2008 10:59:40 +0800
Message-ID: <487C129C.1020105@cn.fujitsu.com>
References: <487C0ABA.1070506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56502 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756037AbYGODEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 23:04:43 -0400
In-Reply-To: <487C0ABA.1070506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I test the patch 6/9, oops happened during device
unregister.

The following oops happened when I add two tunnels, which
use a same device, and then delete one tunnel.
Obviously deleting tunnel "A" causes device unregister, which
send a notification, and after receiving notification, ipmr do
unregister again for tunnel "B" which also use same device.
That is wrong.
After receiving notification, ipmr only needs to decrease reference
count and don't do duplicated unregister.
Fortunately, IPv6 side doesn't add tunnel in ip6mr, so it's clean.

This patch fixs:
- unregister device oops
- using after dev_put()

Here is the oops:
===
Jul 11 15:39:29 wangchen kernel: ------------[ cut here ]------------
Jul 11 15:39:29 wangchen kernel: kernel BUG at net/core/dev.c:3651!
Jul 11 15:39:29 wangchen kernel: invalid opcode: 0000 [#1] 
Jul 11 15:39:29 wangchen kernel: Modules linked in: ipip tunnel4 nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs ipv6 snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device af_packet binfmt_misc button battery ac loop dm_mod usbhid ff_memless pcmcia firmware_class ohci1394 8139too mii ieee1394 yenta_socket rsrc_nonstatic pcmcia_core ide_cd_mod cdrom snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm i2c_i801 snd_timer snd i2c_core soundcore snd_page_alloc rng_core shpchp ehci_hcd uhci_hcd pci_hotplug intel_agp agpgart usbcore ext3 jbd ata_piix ahci libata dock edd fan thermal processor thermal_sys piix sd_mod scsi_mod ide_disk ide_core [last unloaded: freq_table]
Jul 11 15:39:29 wangchen kernel: 
Jul 11 15:39:29 wangchen kernel: Pid: 4102, comm: mroute Not tainted (2.6.26-rc9-default #69)
Jul 11 15:39:29 wangchen kernel: EIP: 0060:[<c024636b>] EFLAGS: 00010202 CPU: 0
Jul 11 15:39:29 wangchen kernel: EIP is at rollback_registered+0x61/0xe3
Jul 11 15:39:29 wangchen kernel: EAX: 00000001 EBX: ecba6000 ECX: 00000000 EDX: ffffffff
Jul 11 15:39:29 wangchen kernel: ESI: 00000001 EDI: ecba6000 EBP: c03de2e8 ESP: ed8e7c3c
Jul 11 15:39:29 wangchen kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Jul 11 15:39:29 wangchen kernel: Process mroute (pid: 4102, ti=ed8e6000 task=ed41e830 task.ti=ed8e6000)
Jul 11 15:39:29 wangchen kernel: Stack: ecba6000 c024641c 00000028 c0284e1a 00000001 c03de2e8 ecba6000 eecff360 
Jul 11 15:39:29 wangchen kernel:        c0284e4c c03536f4 fffffff8 00000000 c029a819 ecba6000 00000006 ecba6000 
Jul 11 15:39:29 wangchen kernel:        00000000 ecba6000 c03de2c0 c012841b ffffffff 00000000 c024639f ecba6000 
Jul 11 15:39:29 wangchen kernel: Call Trace:
Jul 11 15:39:29 wangchen kernel:  [<c024641c>] unregister_netdevice+0x2f/0x51
Jul 11 15:39:29 wangchen kernel:  [<c0284e1a>] vif_delete+0xaf/0xc3
Jul 11 15:39:29 wangchen kernel:  [<c0284e4c>] ipmr_device_event+0x1e/0x30
Jul 11 15:39:29 wangchen kernel:  [<c029a819>] notifier_call_chain+0x2a/0x47
Jul 11 15:39:29 wangchen kernel:  [<c012841b>] raw_notifier_call_chain+0x9/0xc
Jul 11 15:39:29 wangchen kernel:  [<c024639f>] rollback_registered+0x95/0xe3
Jul 11 15:39:29 wangchen kernel:  [<c024641c>] unregister_netdevice+0x2f/0x51
Jul 11 15:39:29 wangchen kernel:  [<c0284e1a>] vif_delete+0xaf/0xc3
Jul 11 15:39:29 wangchen kernel:  [<c0285eee>] ip_mroute_setsockopt+0x47a/0x801
Jul 11 15:39:29 wangchen kernel:  [<eea5a70c>] do_get_write_access+0x2df/0x313 [jbd]
Jul 11 15:39:29 wangchen kernel:  [<c01727c4>] __find_get_block_slow+0xda/0xe4
Jul 11 15:39:29 wangchen kernel:  [<c0172a7f>] __find_get_block+0xf8/0x122
Jul 11 15:39:29 wangchen kernel:  [<c0172a7f>] __find_get_block+0xf8/0x122
Jul 11 15:39:29 wangchen kernel:  [<eea5d563>] journal_cancel_revoke+0xda/0x110 [jbd]
Jul 11 15:39:29 wangchen kernel:  [<c0263501>] ip_setsockopt+0xa9/0x9ee
Jul 11 15:39:29 wangchen kernel:  [<eea5d563>] journal_cancel_revoke+0xda/0x110 [jbd]
Jul 11 15:39:29 wangchen kernel:  [<eea5a70c>] do_get_write_access+0x2df/0x313 [jbd]
Jul 11 15:39:29 wangchen kernel:  [<eea69287>] __ext3_get_inode_loc+0xcf/0x271 [ext3]
Jul 11 15:39:29 wangchen kernel:  [<eea743c7>] __ext3_journal_dirty_metadata+0x13/0x32 [ext3]
Jul 11 15:39:29 wangchen kernel:  [<c0116434>] __wake_up+0xf/0x15
Jul 11 15:39:29 wangchen kernel:  [<eea5a424>] journal_stop+0x1bd/0x1c6 [jbd]
Jul 11 15:39:29 wangchen kernel:  [<eea703a7>] __ext3_journal_stop+0x19/0x34 [ext3]
Jul 11 15:39:29 wangchen kernel:  [<c014291e>] get_page_from_freelist+0x94/0x369
Jul 11 15:39:29 wangchen kernel:  [<c01408f2>] filemap_fault+0x1ac/0x2fe
Jul 11 15:39:29 wangchen kernel:  [<c01a605e>] security_sk_alloc+0xd/0xf
Jul 11 15:39:29 wangchen kernel:  [<c023edea>] sk_prot_alloc+0x36/0x78
Jul 11 15:39:29 wangchen kernel:  [<c0240037>] sk_alloc+0x3a/0x40
Jul 11 15:39:29 wangchen kernel:  [<c0276062>] raw_hash_sk+0x46/0x4e
Jul 11 15:39:29 wangchen kernel:  [<c0166aff>] d_alloc+0x1b/0x157
Jul 11 15:39:29 wangchen kernel:  [<c023e4d1>] sock_common_setsockopt+0x12/0x16
Jul 11 15:39:29 wangchen kernel:  [<c023cb1e>] sys_setsockopt+0x6f/0x8e
Jul 11 15:39:29 wangchen kernel:  [<c023e105>] sys_socketcall+0x15c/0x19e
Jul 11 15:39:29 wangchen kernel:  [<c0103611>] sysenter_past_esp+0x6a/0x99
Jul 11 15:39:29 wangchen kernel:  [<c0290000>] unix_poll+0x69/0x78
Jul 11 15:39:29 wangchen kernel:  =======================
Jul 11 15:39:29 wangchen kernel: Code: 83 e0 01 00 00 85 c0 75 1f 53 53 68 12 81 31 c0 e8 3c 30 ed ff ba 3f 0e 00 00 b8 b9 7f 31 c0 83 c4 0c 5b e9 f5 26 ed ff 48 74 04 <0f> 0b eb fe 89 d8 e8 21 ff ff ff 89 d8 e8 62 ea ff ff c7 83 e0 
Jul 11 15:39:29 wangchen kernel: EIP: [<c024636b>] rollback_registered+0x61/0xe3 SS:ESP 0068:ed8e7c3c
Jul 11 15:39:29 wangchen kernel: ---[ end trace c311acf85d169786 ]---
===

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a55a23a..9b35566 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -186,6 +186,7 @@ struct net_device *ipmr_new_tunnel(struct vifctl *v)
 
 			if (dev_open(dev))
 				goto failure;
+			dev_hold(dev);
 		}
 	}
 	return dev;
@@ -259,6 +260,8 @@ static struct net_device *ipmr_reg_vif(void)
 	if (dev_open(dev))
 		goto failure;
 
+	dev_hold(dev);
+
 	return dev;
 
 failure:
@@ -273,9 +276,10 @@ failure:
 
 /*
  *	Delete a VIF entry
+ *	@notify: Set to 1, if the caller is a notifier_call
  */
 
-static int vif_delete(int vifi)
+static int vif_delete(int vifi, int notify)
 {
 	struct vif_device *v;
 	struct net_device *dev;
@@ -318,7 +322,7 @@ static int vif_delete(int vifi)
 		ip_rt_multicast_event(in_dev);
 	}
 
-	if (v->flags&(VIFF_TUNNEL|VIFF_REGISTER))
+	if (v->flags&(VIFF_TUNNEL|VIFF_REGISTER) && !notify)
 		unregister_netdevice(dev);
 
 	dev_put(dev);
@@ -444,6 +448,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
 			unregister_netdevice(dev);
+			dev_put(dev);
 			return err;
 		}
 		break;
@@ -455,6 +460,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
 			ipmr_del_tunnel(dev, vifc);
+			dev_put(dev);
 			return err;
 		}
 		break;
@@ -462,10 +468,11 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
 		if (!dev)
 			return -EADDRNOTAVAIL;
-		dev_put(dev);
 		err = dev_set_allmulti(dev, 1);
-		if (err)
+		if (err) {
+			dev_put(dev);
 			return err;
+		}
 		break;
 	default:
 		return -EINVAL;
@@ -496,7 +503,6 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
-	dev_hold(dev);
 	v->dev=dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
@@ -843,7 +849,7 @@ static void mroute_clean_tables(struct sock *sk)
 	 */
 	for (i=0; i<maxvif; i++) {
 		if (!(vif_table[i].flags&VIFF_STATIC))
-			vif_delete(i);
+			vif_delete(i, 0);
 	}
 
 	/*
@@ -956,7 +962,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		if (optname==MRT_ADD_VIF) {
 			ret = vif_add(&vif, sk==mroute_socket);
 		} else {
-			ret = vif_delete(vif.vifc_vifi);
+			ret = vif_delete(vif.vifc_vifi, 0);
 		}
 		rtnl_unlock();
 		return ret;
@@ -1135,7 +1141,7 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	v=&vif_table[0];
 	for (ct=0;ct<maxvif;ct++,v++) {
 		if (v->dev==dev)
-			vif_delete(ct);
+			vif_delete(ct, 1);
 	}
 	return NOTIFY_DONE;
 }





