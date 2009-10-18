From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH 1/4 revised] TCPCT part 1a: extend struct
 tcp_request_sock
Date: Sun, 18 Oct 2009 11:57:52 -0400
Message-ID: <4ADB3B00.7040409@gmail.com>
References: <4AD8AFC0.1090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:51589 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715AbZJRP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 11:57:52 -0400
Received: by pzk26 with SMTP id 26so2715048pzk.4
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 08:57:56 -0700 (PDT)
In-Reply-To: <4AD8AFC0.1090101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> Pass additional parameters associated with sending SYNACK.  This
> is not as straightforward or architecturally clean as previously
> proposed, and has the unfortunate side effect of potentially
> including otherwise unneeded headers for related protocols, but
> that problem will affect very few files.
> ---
>  include/net/extend_request_sock.h |   37 
> +++++++++++++++++++++++++++++++++++++
>  1 files changed, 37 insertions(+), 0 deletions(-)
>  create mode 100644 include/net/extend_request_sock.h
> 
This technique appears to be unworkable:

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9971870..30c4808 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -71,6 +71,7 @@
  #include <net/timewait_sock.h>
  #include <net/xfrm.h>
  #include <net/netdma.h>
+#include <net/extend_request_sock.h>

  #include <linux/inet.h>
  #include <linux/ipv6.h>
@@ -1195,6 +1196,15 @@ struct request_sock_ops tcp_request_sock_ops __read_mostly = {
  	.send_reset	=	tcp_v4_send_reset,
  };

+struct request_sock_ops tcp4_extend_request_sock_ops __read_mostly = {
+	.family		=	PF_INET,
+	.obj_size	=	sizeof(struct extend_request_sock),
+	.rtx_syn_ack	=	tcp_v4_send_synack,
+	.send_ack	=	tcp_v4_reqsk_send_ack,
+	.destructor	=	tcp_v4_reqsk_destructor,
+	.send_reset	=	tcp_v4_send_reset,
+};
+

...

+		req = inet_reqsk_alloc(&tcp4_extend_request_sock_ops);
+		if (NULL == req)
+			goto drop;
+

Many hours of investigation demonstrated that the obj_size isn't actually
used to allocate the structure.  Heck, it's not even checked to determine
whether there's enough room!  Instead, the kernel crashes later, as the
extended variables are accessed!

Returning to the architecturally clean parameters of the previous patch
series, that has the distinct advantage of actually working....
