From: Joy Latten <latten@austin.ibm.com>
Subject: ipsec not working in 2.6.23-rc1-git10 when using pfkey
Date: Thu, 2 Aug 2007 13:58:38 -0500
Message-ID: <200708021858.l72IwbhE018683@faith.austin.ibm.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38887 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895AbXHBTBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 15:01:00 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l72J0vEQ028146
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 15:00:57 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l72J0vpF552018
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 15:00:57 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l72J0uXg014961
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 15:00:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Although an ipsec SA was established, kernel couldn't seem to find it.

I think since we are now using "x->sel.family" instead of "family" 
in the  xfrm_selector_match() called in xfrm_state_find(), af_key 
needs to set this field too, just as xfrm_user. 

In af_key.c, x->sel.family only gets set when there's an 
ext_hdrs[SADB_EXT_ADDRESS_PROXY-1] which I think is for tunnel.

I think pfkey needs to also set the x->sel.family field when it is 0.

Tested with below patch, and ipsec worked when using pfkey. 
Let me know if this is correct approach or not.

Regards,
Joy


diff -urpN linux-2.6.22/net/key/af_key.c linux-2.6.22.fp/net/key/af_key.c
--- linux-2.6.22/net/key/af_key.c	2007-08-02 12:32:02.000000000 -0500
+++ linux-2.6.22.fp/net/key/af_key.c	2007-08-02 12:40:57.000000000 -0500
@@ -1205,6 +1205,9 @@ static struct xfrm_state * pfkey_msg2xfr
 		x->sel.family = pfkey_sadb_addr2xfrm_addr(addr, &x->sel.saddr);
 		x->sel.prefixlen_s = addr->sadb_address_prefixlen;
 	}
+	
+	if (!x->sel.family)
+		x->sel.family = x->props.family;
 
 	if (ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1]) {
 		struct sadb_x_nat_t_type* n_type;
