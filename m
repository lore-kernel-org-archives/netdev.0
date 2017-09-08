From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: make error reporting in bpf_warn_invalid_xdp_action more clear
Date: Sat,  9 Sep 2017 01:40:35 +0200
Message-ID: <a89dbb43f7196f6ba8c5fd1f07c7e4bcc97726c3.1504913751.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36659 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753011AbdIHXkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:40:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Differ between illegal XDP action code and just driver
unsupported one to provide better feedback when we throw
a one-time warning here. Reason is that with 814abfabef3c
("xdp: add bpf_redirect helper function") not all drivers
support the new XDP return code yet and thus they will
fall into their 'default' case when checking for return
codes after program return, which then triggers a
bpf_warn_invalid_xdp_action() stating that the return
code is illegal, but from XDP perspective it's not.

I decided not to place something like a XDP_ACT_MAX define
into uapi i) given we don't have this either for all other
program types, ii) future action codes could have further
encoding there, which would render such define unsuitable
and we wouldn't be able to rip it out again, and iii) we
rarely add new action codes.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 4 ++--
 net/core/filter.c        | 6 +++++-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ba848b7..43ab5c4 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -766,8 +766,8 @@ struct bpf_sock {
 
 /* User return codes for XDP prog type.
  * A valid XDP program must return one of these defined values. All other
- * return codes are reserved for future use. Unknown return codes will result
- * in packet drop.
+ * return codes are reserved for future use. Unknown return codes will
+ * result in packet drops and a warning via bpf_warn_invalid_xdp_action().
  */
 enum xdp_action {
 	XDP_ABORTED = 0,
diff --git a/net/core/filter.c b/net/core/filter.c
index 0848df2..adac4eb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3609,7 +3609,11 @@ static bool xdp_is_valid_access(int off, int size,
 
 void bpf_warn_invalid_xdp_action(u32 act)
 {
-	WARN_ONCE(1, "Illegal XDP return value %u, expect packet loss\n", act);
+	const u32 act_max = XDP_REDIRECT;
+
+	WARN_ONCE(1, "%s XDP return value %u, expect packet loss!\n",
+		  act > act_max ? "Illegal" : "Driver unsupported",
+		  act);
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
-- 
1.9.3
