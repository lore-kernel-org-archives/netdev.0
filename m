From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 2/7] bpf: Allow cgroup sock filters to use get_current_uid_gid helper
Date: Thu, 31 Aug 2017 15:05:45 -0700
Message-ID: <1504217150-16151-3-git-send-email-dsahern@gmail.com>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35639 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdHaWGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:06:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id g13so532849pfm.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:06:10 -0700 (PDT)
In-Reply-To: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow BPF programs run on sock create to use the get_current_uid_gid
helper. IPv4 and IPv6 sockets are created in a process context so
there is always a valid uid/gid

Signed-off-by: David Ahern <dsahern@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index f51b9690adf3..9dad3e7e2e10 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3150,6 +3150,20 @@ bpf_base_func_proto(enum bpf_func_id func_id)
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
@@ -4233,7 +4247,7 @@ const struct bpf_verifier_ops lwt_xmit_prog_ops = {
 };
 
 const struct bpf_verifier_ops cg_sock_prog_ops = {
-	.get_func_proto		= bpf_base_func_proto,
+	.get_func_proto		= sock_filter_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
-- 
2.1.4
