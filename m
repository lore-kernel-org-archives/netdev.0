From: Benjamin Reed <br33d@yahoo.com>
Subject: [PATCH] Dynamic airo.c patch for 2.6.10
Date: Wed, 2 Feb 2005 09:59:54 -0800 (PST)
Message-ID: <20050202175955.4705.qmail@web51506.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-765586789-1107367194=:3794"
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-765586789-1107367194=:3794
Content-Type: text/plain; charset=us-ascii
Content-Id: 
Content-Disposition: inline

Here is a patch for the 2.6.10 aironet driver that
will enable dynamic wep keying without resetting the
MAC. It allows us to use xsupplicant with the driver.

There are two lines of ugliness (the ones with the 0
&&) where I ignore the flag that says wether we are
setting a permanent or a temporary key since
xsupplicant doesn't use the IW_ENCODE_TEMP flag.
--0-765586789-1107367194=:3794
Content-Type: text/x-diff; name="airo-dynkey.patch"
Content-Description: airo-dynkey.patch
Content-Disposition: inline; filename="airo-dynkey.patch"

--- /usr/src/kernel-source-2.6.10/drivers/net/wireless/airo.c	2004-12-24 13:33:59.000000000 -0800
+++ airo.c	2005-02-01 09:23:36.000000000 -0800
@@ -1739,9 +1739,12 @@
 	rc = PC4500_writerid(ai, RID_WEP_TEMP, &wkr, sizeof(wkr), lock);
 	if (rc!=SUCCESS) printk(KERN_ERR "airo:  WEP_TEMP set %x\n", rc);
 	if (perm) {
+		// We make these messages debug. They really should be error,
+		// but no one seems to use the TEMP flag and writing a PERM key
+		// with the MAC disable throws this error
 		rc = PC4500_writerid(ai, RID_WEP_PERM, &wkr, sizeof(wkr), lock);
 		if (rc!=SUCCESS) {
-			printk(KERN_ERR "airo:  WEP_PERM set %x\n", rc);
+			printk(KERN_DEBUG "airo:  WEP_PERM set %x\n", rc);
 		}
 	}
 	return rc;
@@ -3815,11 +3818,14 @@
 	pRsp->rsp1 = IN4500(ai, RESP1);
 	pRsp->rsp2 = IN4500(ai, RESP2);
 	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET) {
-		printk (KERN_ERR "airo: cmd= %x\n", pCmd->cmd);
-		printk (KERN_ERR "airo: status= %x\n", pRsp->status);
-		printk (KERN_ERR "airo: Rsp0= %x\n", pRsp->rsp0);
-		printk (KERN_ERR "airo: Rsp1= %x\n", pRsp->rsp1);
-		printk (KERN_ERR "airo: Rsp2= %x\n", pRsp->rsp2);
+		/* These really should be error, but supplicants don't seem
+		 * to use the TEMP flag when setting the keys, so this
+		 * error is common */
+		printk (KERN_DEBUG "airo: cmd= %x\n", pCmd->cmd);
+		printk (KERN_DEBUG "airo: status= %x\n", pRsp->status);
+		printk (KERN_DEBUG "airo: Rsp0= %x\n", pRsp->rsp0);
+		printk (KERN_DEBUG "airo: Rsp1= %x\n", pRsp->rsp1);
+		printk (KERN_DEBUG "airo: Rsp2= %x\n", pRsp->rsp2);
 	}
 
 	// clear stuck command busy if necessary
@@ -4048,10 +4054,12 @@
 		Cmd cmd;
 		Resp rsp;
 
+#if 0 /* This check is to catch bugs, not needed for WepRid with temp key */
 		if (test_bit(FLAG_ENABLED, &ai->flags))
 			printk(KERN_ERR
 				"%s: MAC should be disabled (rid=%04x)\n",
 				__FUNCTION__, rid);
+#endif
 		memset(&cmd, 0, sizeof(cmd));
 		memset(&rsp, 0, sizeof(rsp));
 
@@ -5096,7 +5104,7 @@
 		wkr.len = sizeof(wkr);
 		wkr.kindex = 0xffff;
 		wkr.mac[0] = (char)index;
-		if (perm) printk(KERN_INFO "Setting transmit key to %d\n", index);
+		if (perm) printk(KERN_DEBUG "Setting transmit key to %d\n", index);
 		if (perm) ai->defindex = (char)index;
 	} else {
 // We are actually setting the key
@@ -5105,12 +5113,16 @@
 		wkr.klen = keylen;
 		memcpy( wkr.key, key, keylen );
 		memcpy( wkr.mac, macaddr, ETH_ALEN );
-		printk(KERN_INFO "Setting key %d\n", index);
 	}
 
-	disable_MAC(ai, lock);
+	//We are supposed to disable MACs before we write Rids,
+	//but the WEP Key rid seems to be the exception when temporary.
+	//unfortunately, no one uses the temporary flag, so until then
+	//an error is going to get thrown... (remove the 0 && when the
+	//flag comes into use.
+	if (0 && perm) disable_MAC(ai, lock);
 	writeWepKeyRid(ai, &wkr, perm, lock);
-	enable_MAC(ai, &rsp, lock);
+	if (0 && perm) enable_MAC(ai, &rsp, lock);
 	return 0;
 }
 
@@ -5564,9 +5576,9 @@
 	}
 
 #ifdef CONFIG_PCI
-	printk( KERN_INFO "airo:  Probing for PCI adapters\n" );
+	printk( KERN_DEBUG "airo:  Probing for PCI adapters\n" );
 	pci_register_driver(&airo_driver);
-	printk( KERN_INFO "airo:  Finished probing for PCI adapters\n" );
+	printk( KERN_DEBUG "airo:  Finished probing for PCI adapters\n" );
 #endif
 
 	/* Always exit with success, as we are a library module
@@ -5578,7 +5590,7 @@
 static void __exit airo_cleanup_module( void )
 {
 	while( airo_devices ) {
-		printk( KERN_INFO "airo: Unregistering %s\n", airo_devices->dev->name );
+		printk( KERN_DEBUG "airo: Unregistering %s\n", airo_devices->dev->name );
 		stop_airo_card( airo_devices->dev, 1 );
 	}
 #ifdef CONFIG_PCI
@@ -6168,6 +6180,7 @@
 {
 	struct airo_info *local = dev->priv;
 	CapabilityRid cap_rid;		/* Card capability info */
+	u16 oldAuthType;
 
 	/* Is WEP supported ? */
 	readCapabilityRid(local, &cap_rid, 1);
@@ -6210,7 +6223,8 @@
 			/* Copy the key in the driver */
 			memcpy(key.key, extra, dwrq->length);
 			/* Send the key to the card */
-			set_wep_key(local, index, key.key, key.len, 1, 1);
+			set_wep_key(local, index, key.key, key.len,
+				    !(dwrq->flags&IW_ENCODE_TEMP), 1);
 		}
 		/* WE specify that if a valid key is set, encryption
 		 * should be enabled (user may turn it off later)
@@ -6224,13 +6238,15 @@
 		/* Do we want to just set the transmit key index ? */
 		int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 		if ((index >= 0) && (index < ((cap_rid.softCap & 0x80)?4:1))) {
-			set_wep_key(local, index, NULL, 0, 1, 1);
+			set_wep_key(local, index, NULL, 0,
+				    !(dwrq->flags&IW_ENCODE_TEMP), 1);
 		} else
 			/* Don't complain if only change the mode */
 			if(!dwrq->flags & IW_ENCODE_MODE) {
 				return -EINVAL;
 			}
 	}
+	oldAuthType = local->config.authType;
 	/* Read the flags */
 	if(dwrq->flags & IW_ENCODE_DISABLED)
 		local->config.authType = AUTH_OPEN;	// disable encryption
@@ -6239,7 +6255,7 @@
 	if(dwrq->flags & IW_ENCODE_OPEN)
 		local->config.authType = AUTH_ENCRYPT;	// Only Wep
 	/* Commit the changes to flags if needed */
-	if(dwrq->flags & IW_ENCODE_MODE)
+	if(oldAuthType != local->config.authType)
 		set_bit (FLAG_COMMIT, &local->flags);
 	return -EINPROGRESS;		/* Call commit handler */
 }

--0-765586789-1107367194=:3794--
