From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Thu, 11 Jul 2013 01:14:11 -0700 (PDT)
Message-ID: <20130711.011411.251674726351429354.davem@davemloft.net>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
	<1373503334.4600.27.camel@edumazet-glaptop>
	<CALnjE+rA4kPiwemZ+A0GfSMw8OsS=ssRw0S_1i75jyF2HB2D0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	joseph.gasparakis@intel.com, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618Ab3GKIOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:14:14 -0400
In-Reply-To: <CALnjE+rA4kPiwemZ+A0GfSMw8OsS=ssRw0S_1i75jyF2HB2D0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Thu, 11 Jul 2013 00:45:19 -0700

> I did some digging and found following commit causing problem with GRE
> TSO on bnx setup.
> 
> c957d09ffda417f6c8e3d1f10e2b05228607d6d7 is the first bad commit
> commit c957d09ffda417f6c8e3d1f10e2b05228607d6d7
> Author: Yuval Mintz <yuvalmin@broadcom.com>
> Date:   Tue Jun 25 08:50:11 2013 +0300
> 
>     bnx2x: Remove sparse and coccinelle warnings

Yeah it's this change:

@@ -3543,9 +3543,12 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 	/* outer IP header info */
 	if (xmit_type & XMIT_CSUM_V4) {
 		struct iphdr *iph = ip_hdr(skb);
+		u16 csum = (__force u16)(~iph->check) -
+			   (__force u16)iph->tot_len -
+			   (__force u16)iph->frag_off;
+
 		pbd2->fw_ip_csum_wo_len_flags_frag =
-			bswab16(csum_fold((~iph->check) -
-					  iph->tot_len - iph->frag_off));
+			bswab16(csum_fold((__force __wsum)csum));

Way too aggressive with the u16 casting.  These two expressions are
not equivalent:

	csum_fold((~iph->check) - iph->tot_len - iph->frag_off)

	csum_fold((__wsum) ((u16)(~iph->check) - (u16)iph->tot_len - (u16)iph->frag_off))

In the first case, the entire expression is computed as 32-bit, in
the second the ~iph->check is truncated to 16-bits before tot_len
and frag_off are subtracted from it.
