From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) skge -- handle proc_fs errors.
Date: Fri, 26 Sep 2003 11:17:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926111753.560f6bf3.shemminger@osdl.org>
References: <20030904160658.5ae22c0d.shemminger@osdl.org>
	<1220606764.18887.129.camel@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Ralph Roesler <rroesler@syskonnect.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
In-Reply-To: <1220606764.18887.129.camel@mlindner-lin>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Existing code does not 
	- check if proc_fs functions return error.
	- use proc_mkdir to make the directory.

Note pSkRootDir defined twice.

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	Fri Sep 26 11:09:24 2003
+++ b/drivers/net/sk98lin/skge.c	Fri Sep 26 11:09:24 2003
@@ -607,12 +607,6 @@
 static uintptr_t RxQueueAddr[SK_MAX_MACS] = {0x400, 0x480};
 
 
-#ifdef CONFIG_PROC_FS
-static struct proc_dir_entry	*pSkRootDir;
-#endif
-
-
-
 /*****************************************************************************
  *
  * 	skge_probe - find all SK-98xx adapters
@@ -638,7 +632,6 @@
 	SK_BOOL BootStringCount = SK_FALSE;
 	int			retval;
 #ifdef CONFIG_PROC_FS
-	int			proc_root_initialized = 0;
 	struct proc_dir_entry	*pProcFile;
 #endif
 
@@ -758,26 +751,28 @@
 				sizeof(SK_Root_Dir_entry) - 1);
 
 			/*Create proc (directory)*/
-			if(!proc_root_initialized) {
-				pSkRootDir = create_proc_entry(SK_Root_Dir_entry,
-					S_IFDIR | S_IWUSR | S_IRUGO | S_IXUGO, proc_net);
-				pSkRootDir->owner = THIS_MODULE;
-				proc_root_initialized = 1;
+			if(!pSkRootDir) {
+				pSkRootDir = proc_mkdir(SK_Root_Dir_entry, proc_net);
+				if (!pSkRootDir) 
+					printk(KERN_WARNING "%s: Unable to create /proc/net/%s",
+					       dev->name, SK_Root_Dir_entry);
+				else
+					pSkRootDir->owner = THIS_MODULE;
 			}
 		}
-
-		/* Create proc file */
-		pProcFile = create_proc_entry(dev->name,
-			S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
-			pSkRootDir);
-
 		
-		pProcFile->read_proc = sk_proc_read;
-		pProcFile->write_proc = NULL;
-		pProcFile->nlink = 1;
-		pProcFile->size = sizeof(dev->name + 1);
-		pProcFile->data = (void *)pProcFile;
-		pProcFile->owner = THIS_MODULE;
+		/* Create proc file */
+		if (pSkRootDir && 
+		    (pProcFile = create_proc_entry(dev->name,
+						  S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
+						   pSkRootDir))) {
+			pProcFile->read_proc = sk_proc_read;
+			pProcFile->write_proc = NULL;
+			pProcFile->nlink = 1;
+			pProcFile->size = sizeof(dev->name + 1);
+			pProcFile->data = (void *)pProcFile;
+			pProcFile->owner = THIS_MODULE;
+		}
 #endif
 
 		pNet->PortNr = 0;
@@ -831,17 +826,18 @@
 #endif
 
 #ifdef CONFIG_PROC_FS
-			pProcFile = create_proc_entry(dev->name,
-				S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
-				pSkRootDir);
-
+			if (pSkRootDir 
+			    && (pProcFile = create_proc_entry(dev->name,
+							      S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
+							      pSkRootDir))) {
 		
-			pProcFile->read_proc = sk_proc_read;
-			pProcFile->write_proc = NULL;
-			pProcFile->nlink = 1;
-			pProcFile->size = sizeof(dev->name + 1);
-			pProcFile->data = (void *)pProcFile;
-			pProcFile->owner = THIS_MODULE;
+				pProcFile->read_proc = sk_proc_read;
+				pProcFile->write_proc = NULL;
+				pProcFile->nlink = 1;
+				pProcFile->size = sizeof(dev->name + 1);
+				pProcFile->data = (void *)pProcFile;
+				pProcFile->owner = THIS_MODULE;
+			}
 #endif
 
 			memcpy((caddr_t) &dev->dev_addr,
@@ -1188,7 +1184,8 @@
 
 #ifdef CONFIG_PROC_FS
 	/* clear proc-dir */
-	remove_proc_entry(pSkRootDir->name, proc_net);
+	if (pSkRootDir) 
+		remove_proc_entry(pSkRootDir->name, proc_net);
 #endif
 
 } /* skge_cleanup_module */
