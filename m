From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: fix skb_copy_expand offset calculation
Date: Thu, 06 Nov 2003 18:21:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FAA832A.6000505@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080502050700020003090802"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080502050700020003090802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,
this patch fixes offset calculation in skb_copy_expand.

        head_copy_len = skb_headroom(skb);
        head_copy_off = 0;
        if (newheadroom < head_copy_len) {
                head_copy_off = head_copy_len - newheadroom;
                head_copy_len = newheadroom;
        }
 
        /* Copy the linear header and data. */
        if (skb_copy_bits(skb, -head_copy_len, n->head + head_copy_off,
                          skb->len + head_copy_len))


It looks like it is intended to copy as much as possible, cutting off
bytes at the beginning is there is not enough room. For the case
newheadroom < head_copy_len that means it needs to copy newheadroom
bytes from skb->data - newheadroom to n->head, so head_copy_off
needs to be 0. I don't know how the data copied is used later on
but I assume it is intended to stay continous. That means in
the case that newheadroom > skb_headroom(skb) we need to copy
skb_headroom(skb) bytes to n->head + newheadroom - skb_headroom(skb),
so head_copy_off becomes newheadroom - head_copy_len.

In the patch the case newheadroom == skb_headroom(skb) is handled with
the first condition to save either a jump or a subtraction.

The patch is verified to fix the problem that led me to this, ipt_REJECT
produced broken RSTs which triggered the "ipt_hook: happy cracking!"
line in ip_conntrack_standalone.c.

Best regards,
Patrick

--------------080502050700020003090802
Content-Type: text/plain;
 name="2.6-skb_copy_expand.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6-skb_copy_expand.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1413  -> 1.1414 
#	   net/core/skbuff.c	1.32    -> 1.33   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/06	kaber@trash.net	1.1414
# Fix skb_copy_expand offset calculation
# --------------------------------------------
#
diff -Nru a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c	Thu Nov  6 17:34:55 2003
+++ b/net/core/skbuff.c	Thu Nov  6 17:34:55 2003
@@ -595,10 +595,10 @@
 
 	head_copy_len = skb_headroom(skb);
 	head_copy_off = 0;
-	if (newheadroom < head_copy_len) {
-		head_copy_off = head_copy_len - newheadroom;
+	if (newheadroom <= head_copy_len)
 		head_copy_len = newheadroom;
-	}
+	else
+		head_copy_off = newheadroom - head_copy_len;
 
 	/* Copy the linear header and data. */
 	if (skb_copy_bits(skb, -head_copy_len, n->head + head_copy_off,

--------------080502050700020003090802--
