From: Andy Gay <andy@andynet.net>
Subject: [IPROUTE]: Fix struct alignment with cris architecture
Date: Thu, 10 Aug 2006 20:25:40 -0400
Message-ID: <1155255940.7302.18.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:31164 "EHLO
	vms048pub.verizon.net") by vger.kernel.org with ESMTP
	id S932323AbWHKA0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 20:26:01 -0400
Received: from andyhp.tranquilitynj.net ([138.89.7.39])
 by vms048.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J3T000YV56TBKC2@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 10 Aug 2006 19:25:42 -0500 (CDT)
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Fix struct alignment with cris architecture

gcc for the cris arch does not pad structures to the next multiple of 4
bytes, as the i386 gcc does.

This causes errors like this when displaying xfrm policies:

# ip x p
!!!Deficit 3, rta_len=300
src 192.168.251.32/29 dst 192.168.251.32/29 
        dir in priority 0 
!!!Deficit 3, rta_len=180
src 0.0.0.0/0 dst 192.168.251.32/29 
        dir in priority 2208 
....

Similar errors are seen from ip x s.

This patch fixes the errors when printing. I'm not sure whether we
should worry about other uses of the affected structs, I've not seen any
other bad effects from this though, so hopefully this is enough.

(Thanks to Herbert Xu for pointing out that NLMSG_SPACE is the correct
macro to use here.)

Tested against 2.6.17.6 kernel on i386, and 2.6.16.1 kernel on cris.

Signed-off-by: Andy Gay <andy@andynet.net>

---

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 433b513..340e7df 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -354,15 +354,15 @@ int xfrm_policy_print(const struct socka
 
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)  {
 		xpid = NLMSG_DATA(n);
-		len -= NLMSG_LENGTH(sizeof(*xpid));
+		len -= NLMSG_SPACE(sizeof(*xpid));
 	} else if (n->nlmsg_type == XFRM_MSG_POLEXPIRE) {
 		xpexp = NLMSG_DATA(n);
 		xpinfo = &xpexp->pol;
-		len -= NLMSG_LENGTH(sizeof(*xpexp));
+		len -= NLMSG_SPACE(sizeof(*xpexp));
 	} else {
 		xpexp = NULL;
 		xpinfo = NLMSG_DATA(n);
-		len -= NLMSG_LENGTH(sizeof(*xpinfo));
+		len -= NLMSG_SPACE(sizeof(*xpinfo));
 	}
 
 	if (len < 0) {
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 3eefaff..1d61685 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -575,15 +575,15 @@ int xfrm_state_print(const struct sockad
 	if (n->nlmsg_type == XFRM_MSG_DELSA) {
 		/* Dont blame me for this .. Herbert made me do it */
 		xsid = NLMSG_DATA(n);
-		len -= NLMSG_LENGTH(sizeof(*xsid));
+		len -= NLMSG_SPACE(sizeof(*xsid));
 	} else if (n->nlmsg_type == XFRM_MSG_EXPIRE) {
 		xexp = NLMSG_DATA(n);
 		xsinfo = &xexp->state;
-		len -= NLMSG_LENGTH(sizeof(*xexp));
+		len -= NLMSG_SPACE(sizeof(*xexp));
 	} else {
 		xexp = NULL;
 		xsinfo = NLMSG_DATA(n);
-		len -= NLMSG_LENGTH(sizeof(*xsinfo));
+		len -= NLMSG_SPACE(sizeof(*xsinfo));
 	}
 
 	if (len < 0) {



