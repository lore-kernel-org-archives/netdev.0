From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] sock, diag: fix panic in sock_diag_put_filterinfo
Date: Wed,  2 Sep 2015 14:00:36 +0200
Message-ID: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59800 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbbIBMAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 08:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diag socket's sock_diag_put_filterinfo() dumps classic BPF programs
upon request to user space (ss -0 -b). However, native eBPF programs
attached to sockets (SO_ATTACH_BPF) cannot be dumped with this method:

Their orig_prog is always NULL. However, sock_diag_put_filterinfo()
unconditionally tries to access its filter length resp. wants to copy
the filter insns from there. Internal cBPF to eBPF transformations
attached to sockets don't have this issue, as orig_prog state is kept.

It's currently only used by packet sockets. If we would want to add
native eBPF support in the future, this needs to be done through
a different attribute than PACKET_DIAG_FILTER to not confuse possible
user space disassemblers that work on diag data.

Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/sock_diag.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index d79866c..817622f 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -90,6 +90,9 @@ int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 		goto out;
 
 	fprog = filter->prog->orig_prog;
+	if (!fprog)
+		goto out;
+
 	flen = bpf_classic_proglen(fprog);
 
 	attr = nla_reserve(skb, attrtype, flen);
-- 
1.9.3
