From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [2.4] e1000 leaking pci mappings on rx errors?
Date: Mon, 12 Jan 2004 15:36:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229CCD@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, "cramerj" <cramerj@intel.com>, <milliner@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "Olof Johansson" <olof@austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Also, I noticed it's leaking quite fast, and even before any 
> RX errors are shown. So my previous guess w.r.t. cause and effect
might 
> have been wrong:

Ok, most of the changes to the driver are on the Tx side.  Add this to
5.2.20 and let's see if we're hitting this path.  Maybe there is still
something wrong with the Tx unwind case where we run out of resources:

diff -Nuarp e1000-5.2.20/src/e1000_main.c
e1000-5.2.20-mod/src/e1000_main.c
--- e1000-5.2.20/src/e1000_main.c       2003-09-30 23:22:19.000000000
-0700
+++ e1000-5.2.20-mod/src/e1000_main.c   2004-01-12 16:09:06.000000000
-0800
@@ -1837,6 +1837,8 @@ e1000_xmit_frame(struct sk_buff *skb, st
        if((count = e1000_tx_map(adapter, skb, first)))
                e1000_tx_queue(adapter, count, tx_flags);
        else {
+               static int stops = 0;
+               printk(KERN_ERR "stopping queue %d\n", ++stops);
                netif_stop_queue(netdev);
                return 1;
        }
