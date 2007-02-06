From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 21:53:24 +0100
Message-ID: <45C8EAC4.9020803@cosmosbay.com>
References: <20070103163627.14635.88250.stgit@nienna.balabit>
 <45A48BEB.2070207@trash.net> <200702061536.18800@nienna>
 <20070206.114659.107250775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_PrvNd1DIodREhnBl7zJ1aA)"
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604002mt.neufgp.fr ([84.96.92.61]:35872 "EHLO sMtp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965460AbXBFVAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:00:25 -0500
Received: from [192.168.30.11] ([88.139.66.191]) by sp604002mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JD2006D17D4IL10@sp604002mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Tue, 06 Feb 2007 21:53:31 +0100 (CET)
In-reply-to: <20070206.114659.107250775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_PrvNd1DIodREhnBl7zJ1aA)
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7BIT

Hi David

During an oprofile session of linux-2.6.20 on a dual opteron system, I noticed 
an expensive divide was done in tg3_poll().

I am using gcc-4.1.1, so the following comment from drivers/net/tg3.c seems 
over-optimistic :

/* Do not place this n-ring entries value into the tp struct itself,
  * we really want to expose these constants to GCC so that modulo et
  * al.  operations are done with shifts and masks instead of with
  * hw multiply/modulo instructions.  Another solution would be to
  * replace things like '% foo' with '& (foo - 1)'.
  */
#define TG3_RX_RCB_RING_SIZE(tp)        \
         ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)

Assembly code before patch :
(oprofile results included)
   6434  0.0088 :ffffffff803684b9:       mov    0x6f0(%r15),%eax
    587 8.0e-04 :ffffffff803684c0:       and    $0x40000,%eax
   2170  0.0030 :ffffffff803684c5:       cmp    $0x1,%eax
                :ffffffff803684c8:       lea    0x1(%r13),%eax
                :ffffffff803684cc:       sbb    %ecx,%ecx
   2051  0.0028 :ffffffff803684ce:       xor    %edx,%edx
                :ffffffff803684d0:       and    $0x200,%ecx
     20 2.7e-05 :ffffffff803684d6:       add    $0x200,%ecx
   1986  0.0027 :ffffffff803684dc:       div    %ecx
103427  0.1410 :ffffffff803684de:       cmp    %edx,0xffffffffffffff7c(%rbp)


Assembly code after the suggested patch :


ffffffff803684b9:           mov    0x6f0(%r15),%eax
ffffffff803684c0:           and    $0x40000,%eax
ffffffff803684c5:           cmp    $0x1,%eax
ffffffff803684c8:           sbb    %eax,%eax
ffffffff803684ca:           inc    %r13d
ffffffff803684cd:           and    $0x200,%eax
ffffffff803684d2:           add    $0x1ff,%eax
ffffffff803684d7:           and    %eax,%r13d
ffffffff803684da:           cmp    %r13d,0xffffffffffffff7c(%rbp)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary_(ID_PrvNd1DIodREhnBl7zJ1aA)
Content-type: text/plain; name=tg3_avoid_divide.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=tg3_avoid_divide.patch

--- linux-2.6.20/drivers/net/tg3.c.orig	2007-02-06 22:30:39.000000000 +0100
+++ linux-2.6.20-ed/drivers/net/tg3.c	2007-02-06 22:32:42.000000000 +0100
@@ -3384,7 +3384,7 @@
 		}
 next_pkt_nopost:
 		sw_idx++;
-		sw_idx %= TG3_RX_RCB_RING_SIZE(tp);
+		sw_idx &= (TG3_RX_RCB_RING_SIZE(tp) - 1);
 
 		/* Refresh hw_idx to see if there is new work */
 		if (sw_idx == hw_idx) {

--Boundary_(ID_PrvNd1DIodREhnBl7zJ1aA)--
