From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [PATCH] (02/06/08 Linus git) Smack unlabeled outgoing ambient packets
Date: Thu, 07 Feb 2008 09:07:55 -0800
Message-ID: <47AB3AEB.5010308@schaufler-ca.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp129.plus.mail.sp1.yahoo.com ([69.147.95.92]:44956 "HELO
	smtp129.plus.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756075AbYBGROj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 12:14:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Schaufler <casey@schaufler-ca.com>

Smack uses CIPSO labeling, but allows for unlabeled packets
by specifying an "ambient" label that is applied to incoming
unlabeled packets. Because the other end of the connection
may dislike IP options, and ssh is one know application that
behaves thus, it is prudent to respond in kind. This patch
changes the network labeling behavior such that an outgoing
packet that would be given a CIPSO label that matches the
ambient label is left unlabeled.

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>

---

 security/smack/smack_lsm.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff -uprN -X linux-2.6.25-g0206-base//Documentation/dontdiff linux-2.6.25-g0206-base/security/smack/smack_lsm.c linux-2.6.25-g0206/security/smack/smack_lsm.c
--- linux-2.6.25-g0206-base/security/smack/smack_lsm.c	2008-02-06 16:01:43.000000000 -0800
+++ linux-2.6.25-g0206/security/smack/smack_lsm.c	2008-02-06 18:39:55.000000000 -0800
@@ -1276,6 +1276,12 @@ static void smack_to_secattr(char *smack
  * Convert the outbound smack value (smk_out) to a
  * secattr and attach it to the socket.
  *
+ * If the label is the ambient label do not set the secattr.
+ * Thus, all ambient packets are unlabeled and all unlabeled
+ * packets are ambient. This permits unlabeled responces to
+ * unlabeled requests without knowing on a per-packet basis
+ * if the packet was labeled ambient or was unlabeled.
+ *
  * Returns 0 on success or an error code
  */
 static int smack_netlabel(struct sock *sk)
@@ -1284,6 +1290,9 @@ static int smack_netlabel(struct sock *s
 	struct netlbl_lsm_secattr secattr;
 	int rc = 0;
 
+	if (strncmp(ssp->smk_out, smack_net_ambient, SMK_MAXLEN) == 0)
+		return 0;
+
 	netlbl_secattr_init(&secattr);
 	smack_to_secattr(ssp->smk_out, &secattr);
 	if (secattr.flags != NETLBL_SECATTR_NONE)

