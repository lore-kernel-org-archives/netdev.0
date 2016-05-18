From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master] f_bpf: fix filling of handle when no further arg is provided
Date: Wed, 18 May 2016 11:58:41 +0200
Message-ID: <55bce23c05c03def46a6b5fd385766bcd5351dd7.1463565059.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41091 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcERJ6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 05:58:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to fill handle when provided by the user, even if no further
argument is provided. Thus, move the test for arg to the correct location,
so that it works correctly:

  # tc filter show dev foo egress
  filter protocol all pref 1 bpf
  filter protocol all pref 1 bpf handle 0x1 bpf.o:[classifier] direct-action
  filter protocol all pref 1 bpf handle 0x2 bpf.o:[classifier] direct-action
  # tc filter del dev foo egress prio 1 handle 2 bpf
  # tc filter show dev foo egress
  filter protocol all pref 1 bpf
  filter protocol all pref 1 bpf handle 0x1 bpf.o:[classifier] direct-action

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/f_bpf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index afc2e58..5c97c86 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -71,9 +71,6 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 	struct rtattr *tail;
 	int ret = 0;
 
-	if (argc == 0)
-		return 0;
-
 	if (handle) {
 		if (get_u32(&t->tcm_handle, handle, 0)) {
 			fprintf(stderr, "Illegal \"handle\"\n");
@@ -81,6 +78,9 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 		}
 	}
 
+	if (argc == 0)
+		return 0;
+
 	tail = (struct rtattr *)(((void *)n) + NLMSG_ALIGN(n->nlmsg_len));
 	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
 
-- 
1.9.3
