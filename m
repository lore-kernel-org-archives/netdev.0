From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: potential buffer overflows
Date: Sat, 4 Sep 2010 20:38:59 +0200
Message-ID: <20100904183806.GO5437@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57949 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab0IDSjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 14:39:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cs->ics.parm.setup.phone is a 32 character array.  In each of these
cases we're copying from a 35 character array into a 32 character array
so we should use strlcpy() instead of strcpy().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
index 70cf6ba..48e6d22 100644
--- a/drivers/isdn/divert/isdn_divert.c
+++ b/drivers/isdn/divert/isdn_divert.c
@@ -77,7 +77,7 @@ static void deflect_timer_expire(ulong arg)
 
      case DEFLECT_ALERT:
        cs->ics.command = ISDN_CMD_REDIR; /* protocol */
-       strcpy(cs->ics.parm.setup.phone,cs->deflect_dest);
+       strlcpy(cs->ics.parm.setup.phone, cs->deflect_dest, sizeof(cs->ics.parm.setup.phone));
        strcpy(cs->ics.parm.setup.eazmsn,"Testtext delayed");
        divert_if.ll_cmd(&cs->ics);
        spin_lock_irqsave(&divert_lock, flags);
@@ -251,7 +251,7 @@ int deflect_extern_action(u_char cmd, ulong callid, char *to_nr)
 
      case 2: /* redir */
        del_timer(&cs->timer); 
-       strcpy(cs->ics.parm.setup.phone, to_nr);
+       strlcpy(cs->ics.parm.setup.phone, to_nr, sizeof(cs->ics.parm.setup.phone));
        strcpy(cs->ics.parm.setup.eazmsn, "Testtext manual");
        ic.command = ISDN_CMD_REDIR;
        if ((i = divert_if.ll_cmd(&ic)))
@@ -480,7 +480,7 @@ static int isdn_divert_icall(isdn_ctrl *ic)
                if (!cs->timer.expires)
 		 { strcpy(ic->parm.setup.eazmsn,"Testtext direct");
                    ic->parm.setup.screen = dv->rule.screen;
-                   strcpy(ic->parm.setup.phone,dv->rule.to_nr);
+                   strlcpy(ic->parm.setup.phone, dv->rule.to_nr, sizeof(ic->parm.setup.phone));
                    cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
                    cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
                    retval = 5; 
