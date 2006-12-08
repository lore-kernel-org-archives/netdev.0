From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : force a cache line split in hh_cache in SMP
Date: Fri, 08 Dec 2006 09:06:32 +0100
Message-ID: <45791D08.7070804@cosmosbay.com>
References: <45789534.1050703@cosmosbay.com>
 <20061207145300.3a5a21a6@localhost> <45789D94.3050509@cosmosbay.com>
 <20061207.150718.41636608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_G2IgoM13Inl21slLDoPtZQ)"
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:42076 "EHLO Smtp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1425142AbWLHIGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 03:06:35 -0500
Received: from [192.168.30.10] ([84.7.37.114]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J9Y00C3S3UEZTR0@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 08 Dec 2006 09:06:15 +0100 (CET)
In-reply-to: <20061207.150718.41636608.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_G2IgoM13Inl21slLDoPtZQ)
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7BIT

hh_lock was converted from rwlock to seqlock by Stephen.

To have a 100% benefit of this change, I suggest to place read mostly fields 
of hh_cache in a separate cache line, because hh_refcnt may be changed quite 
frequently on some busy machines.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--Boundary_(ID_G2IgoM13Inl21slLDoPtZQ)
Content-type: text/plain; name=hh_cache.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=hh_cache.patch

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 631cec4..6be767c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -193,7 +193,14 @@ struct hh_cache
 {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
-	__be16		hh_type;	/* protocol identifier, f.e ETH_P_IP
+/*
+ * We want hh_output, hh_len, hh_lock and hh_data be a in a separate
+ * cache line on SMP.
+ * They are mostly read, but hh_refcnt may be changed quite frequently,
+ * incurring cache line ping pongs.
+ */
+	__be16		hh_type ____cacheline_aligned_in_smp;
+					/* protocol identifier, f.e ETH_P_IP
                                          *  NOTE:  For VLANs, this will be the
                                          *  encapuslated type. --BLG
                                          */

--Boundary_(ID_G2IgoM13Inl21slLDoPtZQ)--
