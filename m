From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] NFC: llcp: two bugs in ->getname()
Date: Tue, 23 Apr 2013 09:24:52 +0300
Message-ID: <20130423062452.GD15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thierry Escande <thierry.escande@linux.intel.com>,
	Sasha Levin <levinsasha928@gmail.com>,
	linux-wireless@vger.kernel.org, linux-nfc@ml01.01.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30100 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab3DWGZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:25:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sockaddr_nfc_llcp struct has as hole between ->sa_family and
->dev_idx so I've added a memset() to clear it and prevent an
information leak.

Also the ->nfc_protocol element wasn't set so I've added that.

"uaddr->sa_family" and "llcp_addr->sa_family" are the same thing but
it's less confusing to use llcp_addr consistently throughout.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index c1101e6..c51e97d 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -476,12 +476,13 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
 	pr_debug("%p %d %d %d\n", sk, llcp_sock->target_idx,
 		 llcp_sock->dsap, llcp_sock->ssap);
 
-	uaddr->sa_family = AF_NFC;
-
+	memset(llcp_addr, 0, sizeof(*llcp_addr));
 	*len = sizeof(struct sockaddr_nfc_llcp);
 
+	llcp_addr->sa_family = AF_NFC;
 	llcp_addr->dev_idx = llcp_sock->dev->idx;
 	llcp_addr->target_idx = llcp_sock->target_idx;
+	llcp_addr->nfc_protocol = llcp_sock->nfc_protocol;
 	llcp_addr->dsap = llcp_sock->dsap;
 	llcp_addr->ssap = llcp_sock->ssap;
 	llcp_addr->service_name_len = llcp_sock->service_name_len;
