From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] staging: r8712u: fix bug in r8712_recv_indicatepkt()
Date: Mon, 10 Sep 2012 21:22:11 +0200
Message-ID: <1347304931.1234.2017.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	netdev <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47650 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097Ab2IJTWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:22:20 -0400
Received: by eaac11 with SMTP id c11so1090167eaa.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 12:22:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

64bit arches have a buggy r8712u driver, let's fix it.

skb->tail must be set properly or network stack behavior is undefined.

Addresses https://bugzilla.redhat.com/show_bug.cgi?id=847525
Addresses https://bugzilla.kernel.org/show_bug.cgi?id=45071

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Dave Jones <davej@redhat.com>
Cc: stable@vger.kernel.org [2.6.37+]
---
 drivers/staging/rtl8712/recv_linux.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
index 0e26d5f..495ee12 100644
--- a/drivers/staging/rtl8712/recv_linux.c
+++ b/drivers/staging/rtl8712/recv_linux.c
@@ -117,13 +117,8 @@ void r8712_recv_indicatepkt(struct _adapter *padapter,
 	if (skb == NULL)
 		goto _recv_indicatepkt_drop;
 	skb->data = precv_frame->u.hdr.rx_data;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->tail = (sk_buff_data_t)(precv_frame->u.hdr.rx_tail -
-		     precv_frame->u.hdr.rx_head);
-#else
-	skb->tail = (sk_buff_data_t)precv_frame->u.hdr.rx_tail;
-#endif
 	skb->len = precv_frame->u.hdr.len;
+	skb_set_tail_pointer(skb, skb->len);
 	if ((pattrib->tcpchk_valid == 1) && (pattrib->tcp_chkrpt == 1))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
