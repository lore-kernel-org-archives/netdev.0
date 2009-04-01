From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 01 Apr 2009 10:13:06 +0200
Message-ID: <49D32212.80607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Ingo Molnar <mingo@elte.hu>, Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50577 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759544AbZDAIN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 04:13:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing with new percpu_{read|write|add|sub} stuff in network tree,
I found x86 asm was a litle bit optimistic.

We need to tell gcc that percpu_{write|add|sub|or|xor} are modyfing
memory and possibly eflags. We could add another parameter to percpu_to_op()
to separate the plain "mov" case (not changing eflags),
but let keep it simple for the moment.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percpu.h
index aee103b..fd4f8ec 100644
--- a/arch/x86/include/asm/percpu.h
+++ b/arch/x86/include/asm/percpu.h
@@ -82,22 +82,26 @@ do {							\
 	case 1:						\
 		asm(op "b %1,"__percpu_arg(0)		\
 		    : "+m" (var)			\
-		    : "ri" ((T__)val));			\
+		    : "ri" ((T__)val)			\
+		    : "memory", "cc");			\
 		break;					\
 	case 2:						\
 		asm(op "w %1,"__percpu_arg(0)		\
 		    : "+m" (var)			\
-		    : "ri" ((T__)val));			\
+		    : "ri" ((T__)val)			\
+		    : "memory", "cc");			\
 		break;					\
 	case 4:						\
 		asm(op "l %1,"__percpu_arg(0)		\
 		    : "+m" (var)			\
-		    : "ri" ((T__)val));			\
+		    : "ri" ((T__)val)			\
+		    : "memory", "cc");			\
 		break;					\
 	case 8:						\
 		asm(op "q %1,"__percpu_arg(0)		\
 		    : "+m" (var)			\
-		    : "re" ((T__)val));			\
+		    : "re" ((T__)val)			\
+		    : "memory", "cc");			\
 		break;					\
 	default: __bad_percpu_size();			\
 	}						\
