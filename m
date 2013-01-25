From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] irda: buffer overflow in irnet_ctrl_read()
Date: Fri, 25 Jan 2013 09:40:56 +0300
Message-ID: <20130125064056.GA4882@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17492 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab3AYGlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 01:41:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comments here say that the /* Max event is 61 char */ but in 2003 we
changed the event format and now the max event size is 75.  The longest
event is:

	"Discovered %08x (%s) behind %08x {hints %02X-%02X}\n",
         12345678901    23  456789012    34567890    1    2 3
	            +8    +21        +8          +2   +2     +1
         = 75 characters.

There was a check to return -EOVERFLOW if the user gave us a "count"
value that was less than 64.  Raising it to 75 might break backwards
compatability.  Instead I removed the check and now it returns a
truncated string if "count" is too low.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 2bb2beb..3c83a1e 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -214,8 +214,7 @@ irnet_get_discovery_log(irnet_socket *	ap)
  * After reading :    discoveries = NULL ; disco_index = Y ; disco_number = -1
  */
 static inline int
-irnet_read_discovery_log(irnet_socket *	ap,
-			 char *		event)
+irnet_read_discovery_log(irnet_socket *ap, char *event, int buf_size)
 {
   int		done_event = 0;
 
@@ -237,12 +236,13 @@ irnet_read_discovery_log(irnet_socket *	ap,
   if(ap->disco_index < ap->disco_number)
     {
       /* Write an event */
-      sprintf(event, "Found %08x (%s) behind %08x {hints %02X-%02X}\n",
-	      ap->discoveries[ap->disco_index].daddr,
-	      ap->discoveries[ap->disco_index].info,
-	      ap->discoveries[ap->disco_index].saddr,
-	      ap->discoveries[ap->disco_index].hints[0],
-	      ap->discoveries[ap->disco_index].hints[1]);
+      snprintf(event, buf_size,
+	       "Found %08x (%s) behind %08x {hints %02X-%02X}\n",
+	       ap->discoveries[ap->disco_index].daddr,
+	       ap->discoveries[ap->disco_index].info,
+	       ap->discoveries[ap->disco_index].saddr,
+	       ap->discoveries[ap->disco_index].hints[0],
+	       ap->discoveries[ap->disco_index].hints[1]);
       DEBUG(CTRL_INFO, "Writing discovery %d : %s\n",
 	    ap->disco_index, ap->discoveries[ap->disco_index].info);
 
@@ -282,27 +282,24 @@ irnet_ctrl_read(irnet_socket *	ap,
 		size_t		count)
 {
   DECLARE_WAITQUEUE(wait, current);
-  char		event[64];	/* Max event is 61 char */
+  char		event[75];
   ssize_t	ret = 0;
 
   DENTER(CTRL_TRACE, "(ap=0x%p, count=%Zd)\n", ap, count);
 
-  /* Check if we can write an event out in one go */
-  DABORT(count < sizeof(event), -EOVERFLOW, CTRL_ERROR, "Buffer to small.\n");
-
 #ifdef INITIAL_DISCOVERY
   /* Check if we have read the log */
-  if(irnet_read_discovery_log(ap, event))
+  if (irnet_read_discovery_log(ap, event, sizeof(event)))
     {
-      /* We have an event !!! Copy it to the user */
-      if(copy_to_user(buf, event, strlen(event)))
+      count = min(strlen(event), count);
+      if (copy_to_user(buf, event, count))
 	{
 	  DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
 	  return -EFAULT;
 	}
 
       DEXIT(CTRL_TRACE, "\n");
-      return strlen(event);
+      return count;
     }
 #endif /* INITIAL_DISCOVERY */
 
@@ -339,79 +336,81 @@ irnet_ctrl_read(irnet_socket *	ap,
   switch(irnet_events.log[ap->event_index].event)
     {
     case IRNET_DISCOVER:
-      sprintf(event, "Discovered %08x (%s) behind %08x {hints %02X-%02X}\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].saddr,
-	      irnet_events.log[ap->event_index].hints.byte[0],
-	      irnet_events.log[ap->event_index].hints.byte[1]);
+      snprintf(event, sizeof(event),
+	       "Discovered %08x (%s) behind %08x {hints %02X-%02X}\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].saddr,
+	       irnet_events.log[ap->event_index].hints.byte[0],
+	       irnet_events.log[ap->event_index].hints.byte[1]);
       break;
     case IRNET_EXPIRE:
-      sprintf(event, "Expired %08x (%s) behind %08x {hints %02X-%02X}\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].saddr,
-	      irnet_events.log[ap->event_index].hints.byte[0],
-	      irnet_events.log[ap->event_index].hints.byte[1]);
+      snprintf(event, sizeof(event),
+	       "Expired %08x (%s) behind %08x {hints %02X-%02X}\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].saddr,
+	       irnet_events.log[ap->event_index].hints.byte[0],
+	       irnet_events.log[ap->event_index].hints.byte[1]);
       break;
     case IRNET_CONNECT_TO:
-      sprintf(event, "Connected to %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
+      snprintf(event, sizeof(event), "Connected to %08x (%s) on ppp%d\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].unit);
       break;
     case IRNET_CONNECT_FROM:
-      sprintf(event, "Connection from %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
+      snprintf(event, sizeof(event), "Connection from %08x (%s) on ppp%d\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].unit);
       break;
     case IRNET_REQUEST_FROM:
-      sprintf(event, "Request from %08x (%s) behind %08x\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].saddr);
+      snprintf(event, sizeof(event), "Request from %08x (%s) behind %08x\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].saddr);
       break;
     case IRNET_NOANSWER_FROM:
-      sprintf(event, "No-answer from %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
+      snprintf(event, sizeof(event), "No-answer from %08x (%s) on ppp%d\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].unit);
       break;
     case IRNET_BLOCKED_LINK:
-      sprintf(event, "Blocked link with %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
+      snprintf(event, sizeof(event), "Blocked link with %08x (%s) on ppp%d\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].unit);
       break;
     case IRNET_DISCONNECT_FROM:
-      sprintf(event, "Disconnection from %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
+      snprintf(event, sizeof(event), "Disconnection from %08x (%s) on ppp%d\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name,
+	       irnet_events.log[ap->event_index].unit);
       break;
     case IRNET_DISCONNECT_TO:
-      sprintf(event, "Disconnected to %08x (%s)\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name);
+      snprintf(event, sizeof(event), "Disconnected to %08x (%s)\n",
+	       irnet_events.log[ap->event_index].daddr,
+	       irnet_events.log[ap->event_index].name);
       break;
     default:
-      sprintf(event, "Bug\n");
+      snprintf(event, sizeof(event), "Bug\n");
     }
   /* Increment our event index */
   ap->event_index = (ap->event_index + 1) % IRNET_MAX_EVENTS;
 
   DEBUG(CTRL_INFO, "Event is :%s", event);
 
-  /* Copy it to the user */
-  if(copy_to_user(buf, event, strlen(event)))
+  count = min(strlen(event), count);
+  if (copy_to_user(buf, event, count))
     {
       DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
       return -EFAULT;
     }
 
   DEXIT(CTRL_TRACE, "\n");
-  return strlen(event);
+  return count;
 }
 
 /*------------------------------------------------------------------*/
