From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] wanrouter/wanmain: fix namespace, fixing the current problem with device_shutdown
Date: Wed, 21 May 2003 14:14:41 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521171441.GA10295@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	This makes wanrouter build again after device_shutdown was added to
linux/device.h, that ends up clashing with the non-namespaced function in
wanmain.c.

- Arnaldo


You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1210, 2003-05-21 14:04:23-03:00, acme@conectiva.com.br
  o wanrouter/wanmain: fix namespace, fixing the current problem with device_shutdown


 wanmain.c |  119 +++++++++++++++++++++++++++++++++-----------------------------
 1 files changed, 64 insertions(+), 55 deletions(-)


diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	Wed May 21 14:09:10 2003
+++ b/net/wanrouter/wanmain.c	Wed May 21 14:09:10 2003
@@ -127,18 +127,21 @@
  *	WAN device IOCTL handlers
  */
 
-static int device_setup(struct wan_device *wandev, wandev_conf_t *u_conf);
-static int device_stat(struct wan_device *wandev, wandev_stat_t *u_stat);
-static int device_shutdown(struct wan_device *wandev);
-static int device_new_if(struct wan_device *wandev, wanif_conf_t *u_conf);
-static int device_del_if(struct wan_device *wandev, char *u_name);
+static int wanrouter_device_setup(struct wan_device *wandev,
+				  wandev_conf_t *u_conf);
+static int wanrouter_device_stat(struct wan_device *wandev,
+				 wandev_stat_t *u_stat);
+static int wanrouter_device_shutdown(struct wan_device *wandev);
+static int wanrouter_device_new_if(struct wan_device *wandev,
+				   wanif_conf_t *u_conf);
+static int wanrouter_device_del_if(struct wan_device *wandev, char *u_name);
 
 /*
  *	Miscellaneous
  */
 
-static struct wan_device *find_device (char *name);
-static int delete_interface (struct wan_device *wandev, char *name);
+static struct wan_device *wanrouter_find_device(char *name);
+static int wanrouter_delete_interface(struct wan_device *wandev, char *name);
 void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
 void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
 
@@ -148,19 +151,18 @@
  *	Global Data
  */
 
-static char fullname[]	= "Sangoma WANPIPE Router";
-static char copyright[]	= "(c) 1995-2000 Sangoma Technologies Inc.";
-static char modname[]   = ROUTER_NAME;	/* short module name */
-struct wan_device* router_devlist;	/* list of registered devices */
-static int devcnt;
+static char wanrouter_fullname[]  = "Sangoma WANPIPE Router";
+static char wanrouter_copyright[] = "(c) 1995-2000 Sangoma Technologies Inc.";
+static char wanrouter_modname[] = ROUTER_NAME; /* short module name */
+struct wan_device* wanrouter_router_devlist; /* list of registered devices */
 
 /*
  *	Organize Unique Identifiers for encapsulation/decapsulation
  */
 
-static unsigned char oui_ether[] = { 0x00, 0x00, 0x00 };
+static unsigned char wanrouter_oui_ether[] = { 0x00, 0x00, 0x00 };
 #if 0
-static unsigned char oui_802_2[] = { 0x00, 0x80, 0xC2 };
+static unsigned char wanrouter_oui_802_2[] = { 0x00, 0x80, 0xC2 };
 #endif
 
 #ifndef MODULE
@@ -172,12 +174,13 @@
 	extern int sdladrv_init(void);
 
 	printk(KERN_INFO "%s v%u.%u %s\n",
-		fullname, ROUTER_VERSION, ROUTER_RELEASE, copyright);
+	       wanrouter_fullname, ROUTER_VERSION, ROUTER_RELEASE,
+	       wanrouter_copyright);
 
 	err = wanrouter_proc_init();
-	if (err){
-		printk(KERN_INFO "%s: can't create entry in proc filesystem!\n", modname);
-	}
+	if (err)
+		printk(KERN_INFO "%s: can't create entry in proc filesystem!\n",
+		       wanrouter_modname);
 
         /*
          *      Initialise compiled in boards
@@ -218,14 +221,14 @@
 	int err;
 
 	printk(KERN_INFO "%s v%u.%u %s\n",
-		fullname, ROUTER_VERSION, ROUTER_RELEASE, copyright);
+	       wanrouter_fullname, ROUTER_VERSION, ROUTER_RELEASE,
+	       wanrouter_copyright);
 
 	err = wanrouter_proc_init();
 
-	if (err){
-		printk(KERN_INFO
-		"%s: can't create entry in proc filesystem!\n", modname);
-	}
+	if (err)
+		printk(KERN_INFO "%s: can't create entry in proc filesystem!\n",
+		       wanrouter_modname);
 	return err;
 }
 
@@ -274,12 +277,12 @@
 	if (!namelen || (namelen > WAN_DRVNAME_SZ))
 		return -EINVAL;
 
-	if (find_device(wandev->name) != NULL)
+	if (wanrouter_find_device(wandev->name))
 		return -EEXIST;
 
 #ifdef WANDEBUG
 	printk(KERN_INFO "%s: registering WAN device %s\n",
-		modname, wandev->name);
+	       wanrouter_modname, wandev->name);
 #endif
 
 	/*
@@ -289,7 +292,7 @@
 	if (err) {
 		printk(KERN_INFO
 			"%s: can't create /proc/net/router/%s entry!\n",
-			modname, wandev->name);
+			wanrouter_modname, wandev->name);
 		return err;
 	}
 
@@ -300,9 +303,8 @@
 
 	wandev->ndev = 0;
 	wandev->dev  = NULL;
-	wandev->next = router_devlist;
-	router_devlist = wandev;
-	++devcnt;
+	wandev->next = wanrouter_router_devlist;
+	wanrouter_router_devlist = wandev;
         MOD_INC_USE_COUNT;	/* prevent module from unloading */
 	return 0;
 }
@@ -327,7 +329,7 @@
 	if (name == NULL)
 		return -EINVAL;
 
-	for (wandev = router_devlist, prev = NULL;
+	for (wandev = wanrouter_router_devlist, prev = NULL;
 		wandev && strcmp(wandev->name, name);
 		prev = wandev, wandev = wandev->next)
 		;
@@ -335,18 +337,18 @@
 		return -ENODEV;
 
 #ifdef WANDEBUG
-	printk(KERN_INFO "%s: unregistering WAN device %s\n", modname, name);
+	printk(KERN_INFO "%s: unregistering WAN device %s\n",
+	       wanrouter_modname, name);
 #endif
 
 	if (wandev->state != WAN_UNCONFIGURED)
-		device_shutdown(wandev);
+		wanrouter_device_shutdown(wandev);
 
 	if (prev)
 		prev->next = wandev->next;
 	else
-		router_devlist = wandev->next;
+		wanrouter_router_devlist = wandev->next;
 
-	--devcnt;
 	wanrouter_proc_delete(wandev);
         MOD_DEC_USE_COUNT;
 	return 0;
@@ -381,14 +383,15 @@
 		skb_push(skb, 7);
 		skb->data[0] = 0;
 		skb->data[1] = NLPID_SNAP;
-		memcpy(&skb->data[2], oui_ether, sizeof(oui_ether));
+		memcpy(&skb->data[2], wanrouter_oui_ether,
+		       sizeof(wanrouter_oui_ether));
 		*((unsigned short*)&skb->data[5]) = htons(type);
 		break;
 
 	default:		/* Unknown packet type */
 		printk(KERN_INFO
 			"%s: unsupported Ethertype 0x%04X on interface %s!\n",
-			modname, type, dev->name);
+			wanrouter_modname, type, dev->name);
 		hdr_len = -EINVAL;
 	}
 	return hdr_len;
@@ -418,10 +421,11 @@
 		break;
 
         case NLPID_SNAP:	/* SNAP encapsulation */
-		if (memcmp(&skb->data[cnt + 1], oui_ether, sizeof(oui_ether))){
+		if (memcmp(&skb->data[cnt + 1], wanrouter_oui_ether,
+			   sizeof(wanrouter_oui_ether))){
           		printk(KERN_INFO
 				"%s: unsupported SNAP OUI %02X-%02X-%02X "
-				"on interface %s!\n", modname,
+				"on interface %s!\n", wanrouter_modname,
 				skb->data[cnt+1], skb->data[cnt+2],
 				skb->data[cnt+3], dev->name);
 			return 0;
@@ -435,7 +439,7 @@
 	default:
 		printk(KERN_INFO
 			"%s: unsupported NLPID 0x%02X on interface %s!\n",
-			modname, skb->data[cnt], dev->name);
+			wanrouter_modname, skb->data[cnt], dev->name);
 		return 0;
 	}
 	skb->protocol = ethertype;
@@ -475,23 +479,23 @@
 
 	switch (cmd) {
 	case ROUTER_SETUP:
-		err = device_setup(wandev, (void*)arg);
+		err = wanrouter_device_setup(wandev, (void*)arg);
 		break;
 
 	case ROUTER_DOWN:
-		err = device_shutdown(wandev);
+		err = wanrouter_device_shutdown(wandev);
 		break;
 
 	case ROUTER_STAT:
-		err = device_stat(wandev, (void*)arg);
+		err = wanrouter_device_stat(wandev, (void*)arg);
 		break;
 
 	case ROUTER_IFNEW:
-		err = device_new_if(wandev, (void*)arg);
+		err = wanrouter_device_new_if(wandev, (void*)arg);
 		break;
 
 	case ROUTER_IFDEL:
-		err = device_del_if(wandev, (void*)arg);
+		err = wanrouter_device_del_if(wandev, (void*)arg);
 		break;
 
 	case ROUTER_IFSTAT:
@@ -519,7 +523,8 @@
  *	o call driver's setup() entry point
  */
 
-static int device_setup(struct wan_device *wandev, wandev_conf_t *u_conf)
+static int wanrouter_device_setup(struct wan_device *wandev,
+				  wandev_conf_t *u_conf)
 {
 	void *data = NULL;
 	wandev_conf_t *conf;
@@ -595,7 +600,7 @@
  *	o call driver's shutdown() entry point
  */
 
-static int device_shutdown(struct wan_device *wandev)
+static int wanrouter_device_shutdown(struct wan_device *wandev)
 {
 	struct net_device *dev;
 	int err=0;
@@ -606,7 +611,8 @@
 	printk(KERN_INFO "\n%s: Shutting Down!\n",wandev->name);
 
 	for (dev = wandev->dev; dev;) {
-		if ((err=delete_interface(wandev, dev->name)) != 0)
+		err = wanrouter_delete_interface(wandev, dev->name);
+		if (err)
 			return err;
 		/* The above function deallocates the current dev
 		 * structure. Therefore, we cannot use dev->priv
@@ -628,7 +634,8 @@
  *	Get WAN device status & statistics.
  */
 
-static int device_stat(struct wan_device *wandev, wandev_stat_t *u_stat)
+static int wanrouter_device_stat(struct wan_device *wandev,
+				 wandev_stat_t *u_stat)
 {
 	wandev_stat_t stat;
 
@@ -658,7 +665,8 @@
  *	o register network interface
  */
 
-static int device_new_if(struct wan_device *wandev, wanif_conf_t *u_conf)
+static int wanrouter_device_new_if(struct wan_device *wandev,
+				   wanif_conf_t *u_conf)
 {
 	wanif_conf_t conf;
 	struct net_device *dev = NULL;
@@ -718,7 +726,7 @@
 
 			#ifdef WANDEBUG
 			printk(KERN_INFO "%s: registering interface %s...\n",
-				modname, dev->name);
+				wanrouter_modname, dev->name);
 			#endif
 
 			err = register_netdev(dev);
@@ -775,7 +783,7 @@
  *	 o copy configuration data to kernel address space
  */
 
-static int device_del_if(struct wan_device *wandev, char *u_name)
+static int wanrouter_device_del_if(struct wan_device *wandev, char *u_name)
 {
 	char name[WAN_IFNAME_SZ + 1];
         int err = 0;
@@ -788,7 +796,7 @@
 	if (copy_from_user(name, u_name, WAN_IFNAME_SZ))
 		return -EFAULT;
 
-	err = delete_interface(wandev, name);
+	err = wanrouter_delete_interface(wandev, name);
 	if (err)
 		return err;
 
@@ -816,11 +824,12 @@
  *	Return pointer to the WAN device data space or NULL if device not found.
  */
 
-static struct wan_device *find_device(char *name)
+static struct wan_device *wanrouter_find_device(char *name)
 {
 	struct wan_device *wandev;
 
-	for (wandev = router_devlist;wandev && strcmp(wandev->name, name);
+	for (wandev = wanrouter_router_devlist;
+	     wandev && strcmp(wandev->name, name);
 		wandev = wandev->next);
 	return wandev;
 }
@@ -842,7 +851,7 @@
  *	sure that opened interfaces are not removed!
  */
 
-static int delete_interface(struct wan_device *wandev, char *name)
+static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 {
 	struct net_device *dev = NULL, *prev = NULL;
 	unsigned long smp_flags=0;

===================================================================


This BitKeeper patch contains the following changesets:
1.1210
## Wrapped with gzip_uu ##


M'XL( +:RRSX  ]58;7/:1A#^C'[%UIFFX/!R=Y*0A(=,W$!;3US;@^/V0YIA
M9'& QDABI,..&_K?NW<G,& $3IQTIK:'/>ENGWV_7?P"KC*>MDI^$''C!?R6
M9*)5"I*8!R*\]>M!$M6O4]SH)0EN-,9)Q!O7-XV8BQJKVP;N7/@B&,,M3[-6
MB=;-Y1MQ/^6M4J_[Z]7I<<\PVFUX._;C$;_D MIM0R3IK3\99&]\,9XD<5VD
M?IQ%7"B9\^71.2.$X:]-'9/8S3EM$LN9!W1 J6]1/B#,<IO6 YI4<!<6@C"*
M:$WJS(EIN8[1 5JG^ Z(V2!V@U&@5HM8+6;6B-DB!*1KWFRZ!%Y1J!'C9_BV
M=KPU DC@SH_39"9XVL!5Y(=Q"X;A)XC]B&=3/^!5^1C&(Q!C#L$L37DL8)HF
MUQ,>P5THQC#@MV' ^]EX)@;)76R\ ]/RB''Q$ .C]H4_AD%\8KS>8S F1N.1
M^O5@U7S/]N9-YE)O[C/'=9M#.K"IR8D9;'?U+DP53NH02KPY8RYQ5*(5,.Q/
MNV=I;WR-]A3UMQAQYJ9%;%,GH[V>BK1%O-VIV+2@9MO_HV34H3J'6GJG_C"[
M+HJB]A6)VJ$F =LXH:8%KI$)7X0!A*C6$KZ_T(F+V;2<B706J-W\/1SB&I=5
MHX0_ /JICYX?]@4<SM2J<K0;&O?V(N? \JP&EJM]P+D?B\'W ,3\KA\.]ULM
MM\+AEUD]X)/=V!",_52"R01"L ZU"#",E461Y-#;V7-)PS >Y*_+&BR'*M!K
MP@7OXTN>#C%=]ZNV5,RF*HEL&ZP%MCJQHLIL,I''/WP$:,/!)=97$OGPY_'9
MQ<E%%YNF/'5P5, =)-/[-!R-!;(C=SFH /4\NX;526"!]9X'XSB9)*.09W 2
M!_5"N"@9Y+JTH7=^];[;ZY\=_]X]@L8A9.,D%8 G9A.N2A<.&\8C3QRNH#V$
M=1)F0H'(!21#2/D(5SSE@[RT,XG6P9X*%/VE2*[B+,["48P'-W1-9F&?XX61
M*FT_ _E$2'7E$_Z1 6B:&M!\&J!+6)]M +KJ\RW3@(ZM )$P0R8XZ"3?B&9U
MX;X_NKW+D_.SY7.O>]H]ONQ6M_ N8ZDRQW'!1#DN05(*AU#F:5K!JIJFF(<W
MY7?=WEG_Y.R7<SCX,6M!X,<_"0A2[@L.>'NF]YC#\@H-\&J=\.P>G1W]\%=\
M( OSD>0\[%(N8RH"DGQ7^QB3)8%RW/_8/L=1]BFBY&Z_%70]UUXKO@KRN4SQ
M*5(HH0IK?%*>I_D4P2OQ"2PF,67HL:W*$"QW^2<<>HNKRR@5;6DN?)#8V-50
M'4U*PR2%W-(=T%7TLSIP=G5ZJC!<C>%*_;;':Q8O*ERV=;S,\C*''S,=I&(/
M+MU@*<]ILNJXS1ZV;%C(XF@69X.EP"':JXK10XZ.Z5J*'PE:5HIX%$SORR^S
MF^O:ZX$O_ _L8W7;#;22=%GX-T^&Y2V'*DI#3Y67)MO307[IJ<):1EBZ*"U=
ME"IKI6[1=%6W 'O6*Z#%&I;VJ%?Y+"596I*E]2L=)#$L&Q]&3]78EK AJTX+
M3;:;MJ;LQTTC'<WO:'Z\#M9R<FW:6G3;\FT2#@XK?CI2"+I&-2E&>)PW.*IJ
MQN9.1CF-%4CV5%EI4@B0#TU%$-KSGK4+(I^-MD/83-DO"?M^(RO*\52D-'GF
MF&ETFD36WHDD;*OA&\/7PO;5Y"D]=)!.TU3%(LD>+WS]=(U2]*0BR6XISYN4
MC8ZC:U^3TO:Z6JLC1]>1)M]PSD9D?7EI\O1 +13#+[R279-G3.F(Q-14)PE[
M:A<[RGM.?O#E2RE;7J&K[7=%64O->9I\RV\%#__O"L8\N,EF4=NBOD\LRHQ_
) 8:MM=)*$P  
 
