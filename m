From: Henry Wong <v4l@stuffedcow.net>
Subject: ppp_generic: fix multilink fragment MTU calculation (again)
Date: Sun, 18 Sep 2011 19:41:49 -0400
Message-ID: <4E7681BD.2040902@stuffedcow.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000803000805090903030806"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stuffedcow.net ([206.248.137.124]:41555 "EHLO
	mail.stuffedcow.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620Ab1IRXwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 19:52:02 -0400
Received: from [192.168.0.112] (henry2.stuffedcow.lan [192.168.0.112])
	by mail.stuffedcow.net (Postfix) with ESMTP id 8F1A6723
	for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 19:42:07 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000803000805090903030806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When using MLPPP, the maximum size of a fragment is incorrectly 
calculated with an offset of -2.
This patch reverses the changes in the patch found here: 
http://marc.info/?l=linux-netdev&m=123541324010539&w=2

The value of hdrlen includes the size of both the 2-byte PPP protocol 
field and the 2- or 4-byte multilink header (2+4=6 for long sequence 
numbers, 2+2=4 for short sequence numbers). Section 2 of RFC1661 says 
that the MRU that is negotiated (i.e., the MTU of the sending system) 
includes only the PPP payload but not the protocol field, thus the 
correct MTU should be the link's MTU minus the multilink header (mtu - 
(hdrlen-2)).

The incorrect calculation causes Linux to fragment packets to a size two 
bytes smaller than the allowed MTU. While not technically illegal, this 
behaviour confounds MRU-tuning to avoid PPP-layer fragmentation.

Signed-off-by: Henry Wong <henry@stuffedcow.net>




--------------000803000805090903030806
Content-Type: text/x-patch;
 name="mlppp-frag-mtu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mlppp-frag-mtu.patch"

diff -urp linux-orig/drivers/net/ppp_generic.c linux-new/drivers/net/ppp_generic.c
--- linux-orig/drivers/net/ppp_generic.c	2011-09-18 17:59:18.000000000 -0400
+++ linux-new/drivers/net/ppp_generic.c	2011-09-18 18:05:29.000000000 -0400
@@ -1464,8 +1464,13 @@ static int ppp_mp_explode(struct ppp *pp
 			spin_unlock_bh(&pch->downl);
 			continue;
 		}
-
-		mtu = pch->chan->mtu - hdrlen;
+		
+		/* 
+		 * hdrlen includes the 2-byte PPP protocol field, but the
+		 * MTU counts only the payload excluding the protocol field.
+		 * (RFC1661 Section 2)
+		 */
+		mtu = pch->chan->mtu - (hdrlen - 2);
 		if (mtu < 4)
 			mtu = 4;
 		if (flen > mtu)


--------------000803000805090903030806--
