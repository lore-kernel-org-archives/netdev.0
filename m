From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH] tcp: fix compiler array bounds warning on selective_acks[]
Date: Thu, 10 Apr 2014 15:30:29 -0600
Message-ID: <20140410213029.24916.93892.stgit@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	linux-kernel@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With -Werror=array-bounds, gcc v4.8.x warns that in tcp_sack_remove(), a
selective_acks[] "array subscript is above array bounds".

I don't understand how gcc figures this out, or why we don't see similar
problems many other places, but this is the only fix I can figure out.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 65cf90e063d5..65133b108236 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4047,7 +4047,8 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 
 			/* Zap this SACK, by moving forward any other SACKS. */
 			for (i = this_sack+1; i < num_sacks; i++)
-				tp->selective_acks[i-1] = tp->selective_acks[i];
+				if (i < ARRAY_SIZE(tp->selective_acks))
+					tp->selective_acks[i-1] = tp->selective_acks[i];
 			num_sacks--;
 			continue;
 		}
