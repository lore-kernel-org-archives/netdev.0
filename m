From: cliff white <cliffw@osdl.org>
Subject: complie problem - zd1201.c
Date: Mon, 28 Mar 2005 13:51:10 -0800
Message-ID: <20050328135110.03d2c393@es175>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, pe1rxq@amsat.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Looks like it's looking for the former location of some things.

Complie error:
---------------
drivers/usb/net/zd1201.c:24:24: ieee802_11.h: No such file or directory
drivers/usb/net/zd1201.c: In function `zd1201_usbrx':
drivers/usb/net/zd1201.c:340: error: `IEEE802_11_SCTL_FRAG' undeclared (first use in this function)
drivers/usb/net/zd1201.c:340: error: (Each undeclared identifier is reported only once
drivers/usb/net/zd1201.c:340: error: for each function it appears in.)
drivers/usb/net/zd1201.c:341: error: `IEEE802_11_FCTL_MOREFRAGS' undeclared (first use in this function)
drivers/usb/net/zd1201.c:352: error: `IEEE802_11_DATA_LEN' undeclared (first use in this function)
drivers/usb/net/zd1201.c:358: error: `IEEE802_11_SCTL_SEQ' undeclared (first use in this function)
  CC      drivers/scsi/in2000.o
-----------------------

Is this the right way?
------------------------
diff -Nur a/drivers/usb/net/zd1201.c b/drivers/usb/net/zd1201.c
--- a/drivers/usb/net/zd1201.c  2005-03-28 13:31:03.000000000 -0800
+++ b/drivers/usb/net/zd1201.c  2005-03-28 13:48:59.013988789 -0800
@@ -21,7 +21,7 @@
 #include <linux/string.h>
 #include <linux/if_arp.h>
 #include <linux/firmware.h>
-#include <ieee802_11.h>
+#include <net/ieee80211.h>
 #include "zd1201.h"

 static struct usb_device_id zd1201_table[] = {
@@ -337,25 +337,25 @@
                        goto resubmit;
                }

-               if ((seq & IEEE802_11_SCTL_FRAG) ||
-                   (fc & IEEE802_11_FCTL_MOREFRAGS)) {
+               if ((seq & IEEE80211_SCTL_FRAG) ||
+                   (fc & IEEE80211_FCTL_MOREFRAGS)) {
                        struct zd1201_frag *frag = NULL;
                        char *ptr;

                        if (datalen<14)
                                goto resubmit;
-                       if ((seq & IEEE802_11_SCTL_FRAG) == 0) {
+                       if ((seq & IEEE80211_SCTL_FRAG) == 0) {
                                frag = kmalloc(sizeof(struct zd1201_frag*),
                                    GFP_ATOMIC);
                                if (!frag)
                                        goto resubmit;
-                               skb = dev_alloc_skb(IEEE802_11_DATA_LEN +14+2);
+                               skb = dev_alloc_skb(IEEE80211_DATA_LEN +14+2);
                                if (!skb) {
                                        kfree(frag);
                                        goto resubmit;
                                }
                                frag->skb = skb;
-                               frag->seq = seq & IEEE802_11_SCTL_SEQ;
+                               frag->seq = seq & IEEE80211_SCTL_SEQ;
                                skb_reserve(skb, 2);
                                memcpy(skb_put(skb, 12), &data[datalen-14], 12);
                                memcpy(skb_put(skb, 2), &data[6], 2);
@@ -364,7 +364,7 @@
                                goto resubmit;
                        }
                        hlist_for_each_entry(frag, node, &zd->fraglist, fnode)
-                               if(frag->seq == (seq&IEEE802_11_SCTL_SEQ))
+                               if(frag->seq == (seq&IEEE80211_SCTL_SEQ))
                                        break;
                        if (!frag)
                                goto resubmit;
@@ -372,7 +372,7 @@
                        ptr = skb_put(skb, len);
                        if (ptr)
                                memcpy(ptr, data+8, len);
-                       if (fc & IEEE802_11_FCTL_MOREFRAGS)
+                       if (fc & IEEE80211_FCTL_MOREFRAGS)
                                goto resubmit;
                        hlist_del_init(&frag->fnode);
                        kfree(frag);
---------------------------------
cliffw


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
