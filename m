From: David Miller <davem@davemloft.net>
Subject: removing gotos considered harmful...
Date: Fri, 22 Dec 2006 12:04:32 -0800 (PST)
Message-ID: <20061222.120432.55508411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, arnaldo.melo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752513AbWLVUEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 15:04:33 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Because of massively painful regressions like the following,
I absolutely refuse to apply "cleanup" patches to remove gotos
for "clarity".  All such patches do is change the code and
potentially add bugs, they don't help in any way at all.

Gerrit, please be more careful next time, and resist the urge to "fix"
stuff that isn't broken just to satisfy your own personal coding
tastes during a conversion.  This is a locally exploitable hole,
all someone has to do is open a few hundred UDP sockets to a
particular destination port and then nobody, not even root, can
so much as run ping successfully.

Arnaldo, sorry I originally thought this bug was added by you, you're
totally innocent this time :-)))

I've submitted this fix to Linus and 2.6.19-stable.

Thanks.

[UDP]: Fix reversed logic in udp_get_port().

When this code was converted to use sk_for_each() the
logic for the "best hash chain length" code was reversed,
breaking everything.

The original code was of the form:

			size = 0;
			do {
				if (++size >= best_size_so_far)
					goto next;
			} while ((sk = sk->next) != NULL);
			best_size_so_far = size;
			best = result;
		next:;

and this got converted into:

			sk_for_each(sk2, node, head)
				if (++size < best_size_so_far) {
					best_size_so_far = size;
					best = result;
				}

Which does something very very different from the original.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9e1bd37..404dd21 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -167,11 +167,14 @@ int udp_get_port(struct sock *sk, unsigned short snum,
 				goto gotit;
 			}
 			size = 0;
-			sk_for_each(sk2, node, head)
-				if (++size < best_size_so_far) {
-					best_size_so_far = size;
-					best = result;
-				}
+			sk_for_each(sk2, node, head) {
+				if (++size >= best_size_so_far)
+					goto next;
+			}
+			best_size_so_far = size;
+			best = result;
+		next:
+			;
 		}
 		result = best;
 		for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result += UDP_HTABLE_SIZE) {
