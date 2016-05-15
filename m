From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] ingress, clsact: don't add TCA_OPTIONS to nl msg
Date: Sun, 15 May 2016 18:36:03 +0200
Message-ID: <192c686bb5e277b9552fe1e5c39b14bed520dddd.1463329895.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42799 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbcEOQgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 12:36:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ingress and clsact qdisc TCA_OPTIONS are ignored, since it's
parameterless. In tc, we add an empty addattr_l(... TCA_OPTIONS,
NULL, 0) to the netlink message nevertheless. This has the
side effect that when someone tries a 'tc qdisc replace' and
already an existing such qdisc is present, tc fails with
EINVAL here.

Reason is that in the kernel, this invokes qdisc_change() when
such requested qdisc is already present. When TCA_OPTIONS are
passed to modify parameters, it looks whether qdisc implements
.change() callback, and if not present (like in both cases here)
it returns with error. Rather than adding an empty stub to the
kernel that ignores TCA_OPTIONS again, just don't add TCA_OPTIONS
to the netlink message in the first place.

Before:

  # tc qdisc replace dev foo clsact    # first try
  # tc qdisc replace dev foo clsact    # second one
  RTNETLINK answers: Invalid argument

After:

  # tc qdisc replace dev foo clsact
  # tc qdisc replace dev foo clsact
  # tc qdisc replace dev foo clsact

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/q_clsact.c  | 1 -
 tc/q_ingress.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/tc/q_clsact.c b/tc/q_clsact.c
index 0c05dbd..e2a1a71 100644
--- a/tc/q_clsact.c
+++ b/tc/q_clsact.c
@@ -18,7 +18,6 @@ static int clsact_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		return -1;
 	}
 
-	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	return 0;
 }
 
diff --git a/tc/q_ingress.c b/tc/q_ingress.c
index c3c9b40..31699a8 100644
--- a/tc/q_ingress.c
+++ b/tc/q_ingress.c
@@ -34,7 +34,6 @@ static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		}
 	}
 
-	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	return 0;
 }
 
-- 
1.9.3
