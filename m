From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 32872] New: LLC PDU is dropped if skb is not
 linear
Date: Mon, 11 Apr 2011 16:48:12 -0700
Message-ID: <20110411164812.8f84f995.akpm@linux-foundation.org>
References: <bug-32872-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: vitalyb@telenet.dn.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38374 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752903Ab1DKXsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 19:48:39 -0400
In-Reply-To: <bug-32872-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 8 Apr 2011 09:52:34 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=32872
> 
>            Summary: LLC PDU is dropped if skb is not linear
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: vitalyb@telenet.dn.ua
>         Regression: No
> 
> 
> If skb consists of several fragments this check fails
> net/llc/llc_input.c:
> =============================================
> llc_fixup_skb()
> ...
>     pdu = (struct llc_pdu_un *)skb->data;
> ...
>     __be16 pdulen = eth_hdr(skb)->h_proto;
>     s32 data_size = ntohs(pdulen) - llc_len;
> 
>     if (data_size < 0 ||
>         ((skb_tail_pointer(skb) -
>           (u8 *)pdu) - llc_len) < data_size)
>         return 0;
> =============================================
> 
> and packet is silently dropped.
> 
> This breaks GVRP protocol if received packet is large ( > 512 bytes on my
> system) and contains a Leave All message. Since Leave All is missed,
> corresponding JoinIns are not sent and switch unregisters VLANs from port.
> 
> Attached patch seems to resolve this issue, but I don't know if it's a correct
> solution.

--- linux-2.6.32.36/net/llc/llc_input.c.orig	2009-12-03 05:51:21.000000000 +0200
+++ linux-2.6.32.36/net/llc/llc_input.c	2011-04-08 08:57:29.000000000 +0300
@@ -105,6 +105,11 @@
 	if (unlikely(!pskb_may_pull(skb, sizeof(*pdu))))
 		return 0;
 
+	if (skb->data_len != 0){
+	    if (unlikely(skb_linearize(skb)))
+		return 0;
+	}
+
 	pdu = (struct llc_pdu_un *)skb->data;
 	if ((pdu->ctrl_1 & LLC_PDU_TYPE_MASK) == LLC_PDU_TYPE_U)
 		llc_len = 1;


2.6.32 is a pretty old kernel - we'll need to verify if current kernels
have the same problem.

Please don't send patches via bugzilla - it causes lots of problems
with our usual patch management and review processes.  It's preferred
that patches be sent via email as per Documentation/SubmittingPatches,
and that they include a Signed-off-by:, as described in that file.

Thanks.
