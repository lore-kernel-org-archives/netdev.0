From: "Angelo P. Castellani" <angelo.castellani+lkml@gmail.com>
Subject: [PATCH] reno sacked_out count fix
Date: Tue, 16 May 2006 11:24:00 +0200
Message-ID: <8dd26e70605160224i44bbaa8ei93eede75e71f6665@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_29537_19387604.1147771440126"
Cc: francesco@net.infocom.uniroma1.it, andrea.baiocchi@uniroma1.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.192]:39860 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751714AbWEPJYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 05:24:00 -0400
Received: by nz-out-0102.google.com with SMTP id x3so433459nzd
        for <netdev@vger.kernel.org>; Tue, 16 May 2006 02:24:00 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_29537_19387604.1147771440126
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Using NewReno, if a sk_buff is timed out and is accounted as lost_out,
it should also be removed from the sacked_out.

This is necessary because recovery using NewReno fast retransmit could
take up to a lot RTTs and the sk_buff RTO can expire without actually
being really lost.

left_out =3D sacked_out + lost_out
in_flight =3D packets_out - left_out + retrans_out

Using NewReno without this patch, on very large network losses,
left_out becames bigger than packets_out + retrans_out (!!).

For this reason unsigned integer in_flight overflows to 2^32 - something.

Regards,
Angelo P. Castellani

------=_Part_29537_19387604.1147771440126
Content-Type: text/x-patch; name=reno-fix.diff; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ena0lfxs
Content-Disposition: attachment; filename="reno-fix.diff"

diff -urd ../linux-2.6.16-orig/net/ipv4/tcp_input.c ./net/ipv4/tcp_input.c
--- ../linux-2.6.16-orig/net/ipv4/tcp_input.c	2006-05-15 15:42:39.000000000 +0200
+++ ./net/ipv4/tcp_input.c	2006-05-16 11:18:21.000000000 +0200
@@ -1676,6 +1676,8 @@
 			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 				tp->lost_out += tcp_skb_pcount(skb);
+				if (IsReno(tp)) 
+					tcp_remove_reno_sacks(sk, tp, tcp_skb_pcount(skb) + 1);
 
 				/* clear xmit_retrans hint */
 				if (tp->retransmit_skb_hint &&












------=_Part_29537_19387604.1147771440126--
