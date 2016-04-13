From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ss: Fix accidental state filter override
Date: Wed, 13 Apr 2016 22:07:05 +0200
Message-ID: <1460578025-12224-3-git-send-email-phil@nwl.cc>
References: <20160329193242.GA28502@orbyte.nwl.cc>
 <1460578025-12224-1-git-send-email-phil@nwl.cc>
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53206 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbcDMUHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 16:07:34 -0400
In-Reply-To: <1460578025-12224-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passing a filter expression and selecting an address family using the
'-f' flag would overwrite the state filter by accident. Therefore
calling e.g. 'ss -nl -f inet '(sport = :22)' would not only print
listening sockets (as requested by '-l' flag) but connected ones, as
well.

Fix this by reusing the formerly ineffective call to filter_states_set()
to restore the state filter as it was before the call to
filter_af_set().

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index d6090018c5dbb..544def3f08ea8 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1556,9 +1556,10 @@ void *parse_hostcond(char *addr, bool is_port)
 
 out:
 	if (fam != AF_UNSPEC) {
+		int states = f->states;
 		f->families = 0;
 		filter_af_set(f, fam);
-		filter_states_set(f, 0);
+		filter_states_set(f, states);
 	}
 
 	res = malloc(sizeof(*res));
-- 
2.8.0
