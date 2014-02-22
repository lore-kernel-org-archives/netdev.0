From: Timo Teras <timo.teras@iki.fi>
Subject: probe netlink app in NUD_PROBE
Date: Sat, 22 Feb 2014 10:44:19 +0200
Message-ID: <20140222104419.6b4daa44@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:52720 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaBVInc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 03:43:32 -0500
Received: by mail-la0-f43.google.com with SMTP id pv20so3270456lab.2
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 00:43:30 -0800 (PST)
Received: from vostro ([83.145.235.194])
        by mx.google.com with ESMTPSA id jt7sm5758221lbc.15.2014.02.22.00.43.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Feb 2014 00:43:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a stale or delayed neigh entry is being re-validated the entry
goes to NUD_PROBE state. At the moment only unicast probes are sent.
This is basically because neigh_max_probes() limits the probe amount so.

Now, opennhrp intentionally configures UCAST_PROBES and MCAST_PROBES to
zero and APP_PROBES to something meaningful. The idea is that opennhrp
replaces arp completely with NHRP implemented in userland.

Due to this it seems there is a very small time window, when the
NUD_PROBE times out and the neighbour entry gets invalidated, and
packets get lost.

To remedy this, I would like to have these NUD_PROBE validations sent
via netlink too.

First choice is to change to just use both unicast and application
probes:

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b9e9e0d..36d3f8c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -836,10 +836,10 @@ out:
 static __inline__ int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p = n->parms;
-	return (n->nud_state & NUD_PROBE) ?
-		NEIGH_VAR(p, UCAST_PROBES) :
-		NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) +
-		NEIGH_VAR(p, MCAST_PROBES);
+	int max_probes = NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES);
+	if (!(n->nud_state & NUD_PROBE))
+		max_probes += NEIGH_VAR(p, MCAST_PROBES);
+	return max_probes;
 }
 
 static void neigh_invalidate(struct neighbour *neigh)

On default configuration there is no behaviour change, as APP_PROBES
defaults zero. I'm not sure if other ARPD programs than opennhrp are
currently commonly used.

If that feels risky, alternative would be:

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b9e9e0d..8bb320b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -836,9 +836,11 @@ out:
 static __inline__ int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p = n->parms;
-	return (n->nud_state & NUD_PROBE) ?
-		NEIGH_VAR(p, UCAST_PROBES) :
-		NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) +
+
+	if (n->nud_state & NUD_PROBE)
+		return NEIGH_VAR(p, UCAST_PROBES) ? : NEIGH_VAR(p, APP_PROBES);
+
+	return NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) + 
 		NEIGH_VAR(p, MCAST_PROBES);
 }
 
In which the netlink would be used only if unicast probes are turned
off.

Any preference which to send formatted formally?

- Timo
