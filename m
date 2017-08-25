From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 3/8] bpf: Allow cgroup sock filters to use get_current_uid_gid helper
Date: Fri, 25 Aug 2017 12:05:36 -0700
Message-ID: <1503687941-626-4-git-send-email-dsahern@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37652 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756571AbdHYTFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:05:53 -0400
Received: by mail-pg0-f68.google.com with SMTP id a7so887807pgn.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:05:53 -0700 (PDT)
In-Reply-To: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow BPF programs run on sock create to use the get_current_uid_gid
helper. IPv4 and IPv6 sockets are created in a process context so
there is always a valid uid/gid

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/filter.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index d582d1b1e533..eb505842a77e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3139,6 +3139,20 @@ bpf_base_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
+sock_filter_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	/* inet and inet6 sockets are created in a process
+	 * context so there is always a valid uid/gid
+	 */
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	default:
+		return bpf_base_func_proto(func_id);
+	}
+}
+
+static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -4222,7 +4236,7 @@ const struct bpf_verifier_ops lwt_xmit_prog_ops = {
 };
 
 const struct bpf_verifier_ops cg_sock_prog_ops = {
-	.get_func_proto		= bpf_base_func_proto,
+	.get_func_proto		= sock_filter_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
-- 
2.1.4
