From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/2] bpf: sockmap state change warning fix
Date: Wed, 16 Aug 2017 15:02:12 -0700
Message-ID: <20170816220211.25438.24547.stgit@john-Precision-Tower-5810>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: daniel@iogearbox.net, davem@davemloft.net, eric.dumazet@gmail.com,
        dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33910 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdHPWC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:02:26 -0400
Received: by mail-pg0-f68.google.com with SMTP id y192so6582716pgd.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:02:26 -0700 (PDT)
In-Reply-To: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

psock will uninitialized in default case we need to do the same psock lookup
and check as in other branch. Fixes compile warning below.

kernel/bpf/sockmap.c: In function ‘smap_state_change’:
kernel/bpf/sockmap.c:156:21: warning: ‘psock’ may be used uninitialized in this function [-Wmaybe-uninitialized]
  struct smap_psock *psock;

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/sockmap.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 792f0ad..f7e5e6c 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -188,6 +188,9 @@ static void smap_state_change(struct sock *sk)
 			smap_release_sock(sk);
 		break;
 	default:
+		psock = smap_psock_sk(sk);
+		if (unlikely(!psock))
+			break;
 		smap_report_sk_error(psock, EPIPE);
 		break;
 	}
