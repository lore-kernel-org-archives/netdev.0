From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: af_rose.c
Date: Fri, 21 Oct 2005 00:12:50 +0200
Message-ID: <43581662.7040208@ccr.jussieu.fr>
References: <20051018203932.GA11053@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030504060103060604060705"
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	dann frazier <dannf@hp.com>, chrisw@osdl.org,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Jean-Paul ROUBELAT <jpr@f6fbb.org>
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20051018203932.GA11053@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030504060103060604060705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Concerning rose module, here is a patch proposed by Jean-Paul F6FBB for 
af_rose.c

It is against linux-2.6.14-rc5

This patch only adds a loop near the end of rose_connect() in order to 
make it try to connect rose next_neighbour node in case of connect 
failure, until we reach the true end of the neighbour list.

With the guys of FADCA and other french hams using ROSE/FPAC we found 
that ROSE did not scan the alternate routes even when there was one 
available.

This could be an important point in case of catastrophic events with 
telecommunication failure. The possibility to handle emergency traffic 
via alternate routes could be a vital necessity.

The principle of this patch has been tested with kernel 2.2 and 2.6 and 
it works well using F6FBB ROSE/FPAC packet switch application.

I suggest that it should be included into the next kernel rose module.

73 de Bernard, f6bvp


--------------030504060103060604060705
Content-Type: text/x-patch;
 name="af_rose.c.2.6.14-rc5.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_rose.c.2.6.14-rc5.diff"

--- net/rose/af_rose.c	2005-10-20 23:27:15.000000000 +0200
+++ net/rose/af_rose.c	2005-10-20 23:38:20.000000000 +0200
@@ -751,7 +751,7 @@
 
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
-
+rose_try_next_neigh:
 	rose->dest_addr   = addr->srose_addr;
 	rose->dest_call   = addr->srose_call;
 	rose->rand        = ((long)rose & 0xFFFF) + rose->lci;
@@ -809,6 +809,11 @@
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
+	/* Try next neighbour */
+		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic);
+		if (rose->neighbour)
+			goto rose_try_next_neigh;
+	/* No more neighbour */
 		sock->state = SS_UNCONNECTED;
 		return sock_error(sk);	/* Always set at this point */
 	}

--------------030504060103060604060705--
