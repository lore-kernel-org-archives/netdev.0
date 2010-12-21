From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ppp: allow disabling multilink protocol ID compression
Date: Mon, 20 Dec 2010 19:58:33 -0800
Message-ID: <20101220195833.26786ec5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux would not connect to other router running old version Cisco IOS (12.0).
This is most likely a bug in that version of IOS, since it is fixed
in later versions. As a workaround this patch allows a module parameter
to be set to disable compressing the protocol ID.

See: https://bugzilla.vyatta.com/show_bug.cgi?id=3979

RFC 1990 allows an implementation to formulate MP fragments as if protocol
compression had been negotiated.  This allows us to always send compressed
protocol IDs.  But some implementations don't accept MP fragments with
compressed protocol IDs.  This parameter allows us to interoperate with
them.  The default value of the configurable parameter is the same as the
current behavior:  protocol compression is enabled.  If protocol compression
is disabled we will not send compressed protocol IDs.

This is based on an earlier patch by Bob Gilligan (using a sysctl).
Module parameter is writable to allow for enabling even if ppp
is already loaded for other uses.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ppp_generic.c	2010-12-17 10:01:42.004531762 -0800
+++ b/drivers/net/ppp_generic.c	2010-12-20 18:58:16.677310954 -0800
@@ -1283,6 +1283,11 @@ ppp_push(struct ppp *ppp)
 }
 
 #ifdef CONFIG_PPP_MULTILINK
+static bool mp_protocol_compress __read_mostly = true;
+module_param(mp_protocol_compress, bool, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(mp_protocol_compress,
+		 "compress protocol id in multilink fragments");
+
 /*
  * Divide a packet to be transmitted into fragments and
  * send them out the individual links.
@@ -1345,10 +1350,10 @@ static int ppp_mp_explode(struct ppp *pp
 	if (nfree == 0 || nfree < navail / 2)
 		return 0; /* can't take now, leave it in xmit_pending */
 
-	/* Do protocol field compression (XXX this should be optional) */
+	/* Do protocol field compression */
 	p = skb->data;
 	len = skb->len;
-	if (*p == 0) {
+	if (*p == 0 && mp_protocol_compress) {
 		++p;
 		--len;
 	}
