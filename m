From: Diego Calleja <diegocg@gmail.com>
Subject: [PATCH] Fix LAPB windowsize check
Date: Fri, 4 Aug 2006 13:41:14 +0200
Message-ID: <20060804134114.cf20fe6f.diegocg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.195]:27377 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932599AbWHDLl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:41:26 -0400
Received: by nz-out-0102.google.com with SMTP id n1so32507nzf
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2006 04:41:25 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In bug #6954, Norbert Reinartz reported the following issue:

"Function lapb_setparms() in file net/lapb/lapb_iface.c checks if the given
parameters are valid. If the given window size is in the range of 8 .. 127,
lapb_setparms() fails and returns an error value of LAPB_INVALUE, even if bit
LAPB_EXTENDED in parms->mode is set.
If bit LAPB_EXTENDED in parms->mode is set and the window size is in the range
of 8 .. 127, the first check "(parms->mode & LAPB_EXTENDED)" results true  and
the second check "(parms->window < 1 || parms->window > 127)" results false.
Both checks in conjunction result to false, thus the third check "(parms->window
< 1 || parms->window > 7)" is done by fault.
This third check results true, so that we leave lapb_setparms() by 'goto out_put'.
Seems that this bug doesn't cause any problems, because lapb_setparms() isn't
used to change the default values of LAPB. We are using kernel lapb in our
software project and also change the default parameters of lapb, so we found
this bug"


He also pasted a fix, that I've transformated into a patch:

Signed-off-by: Diego Calleja <diegocg@gmail.com>

Index: 2.6/net/lapb/lapb_iface.c
===================================================================
--- 2.6.orig/net/lapb/lapb_iface.c	2006-08-03 18:40:13.000000000 +0200
+++ 2.6/net/lapb/lapb_iface.c	2006-08-03 18:44:37.000000000 +0200
@@ -238,10 +238,13 @@
 		goto out_put;
 
 	if (lapb->state == LAPB_STATE_0) {
-		if (((parms->mode & LAPB_EXTENDED) &&
-		     (parms->window < 1 || parms->window > 127)) ||
-		    (parms->window < 1 || parms->window > 7))
-			goto out_put;
+		if (parms->mode & LAPB_EXTENDED) {
+			if (parms->window < 1 || parms->window > 127)
+				goto out_put;
+		}
+		else {
+			if (parms->window < 1 || parms->window > 7)
+				goto out_put;
 
 		lapb->mode    = parms->mode;
 		lapb->window  = parms->window;


