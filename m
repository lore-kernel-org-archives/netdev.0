From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 2/5] s390/bpf: Fix multiple macro expansions
Date: Wed, 29 Jul 2015 21:15:15 +0200
Message-ID: <1438197318-16903-3-git-send-email-holzheu@linux.vnet.ibm.com>
References: <1438197318-16903-1-git-send-email-holzheu@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:48070 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbG2TP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 15:15:28 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Wed, 29 Jul 2015 20:15:27 +0100
In-Reply-To: <1438197318-16903-1-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMIT6_DISP_LH macro passes the "disp" parameter to the _EMIT6_DISP_LH
macro. The _EMIT6_DISP_LH macro uses the "disp" parameter twice:

 unsigned int __disp_h = ((u32)disp) & 0xff000;
 unsigned int __disp_l = ((u32)disp) & 0x00fff;

The EMIT6_DISP_LH is used several times with EMIT_CONST_U64() as "disp"
parameter. Therefore always two constants are created per usage of
EMIT6_DISP_LH.

Fix this and add variable "_disp" to avoid multiple expansions.

* v2: Move "_disp" to _EMIT6_DISP_LH as suggested by Joe Perches

Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 01ad166..66926ab 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -214,8 +214,9 @@ static inline void reg_set_seen(struct bpf_jit *jit, u32 b1)
 
 #define _EMIT6_DISP_LH(op1, op2, disp)				\
 ({								\
-	unsigned int __disp_h = ((u32)disp) & 0xff000;		\
-	unsigned int __disp_l = ((u32)disp) & 0x00fff;		\
+	u32 _disp = (u32) disp;					\
+	unsigned int __disp_h = _disp & 0xff000;		\
+	unsigned int __disp_l = _disp & 0x00fff;		\
 	_EMIT6(op1 | __disp_l, op2 | __disp_h >> 4);		\
 })
 
-- 
2.3.8
