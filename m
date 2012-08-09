From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: tcp: unicast_sock should not land outside of TCP
 stack
Date: Fri, 10 Aug 2012 01:56:06 +0200
Message-ID: <1344556566.31104.808.camel@edumazet-glaptop>
References: <1344523833.28967.996.camel@edumazet-glaptop>
	 <CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw@mail.gmail.com>
	 <1344547743.31104.582.camel@edumazet-glaptop>
	 <20120809.163851.1182547052663187702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, paul@paul-moore.com, casey@schaufler-ca.com,
	johnstul@us.ibm.com, serge@hallyn.com,
	linux-kernel@vger.kernel.org, james.l.morris@oracle.com,
	selinux@tycho.nsa.gov, john.johansen@canonical.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20120809.163851.1182547052663187702.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

commit be9f4a44e7d41cee (ipv4: tcp: remove per net tcp_sock) added a
selinux regression, reported and bisected by John Stultz

selinux_ip_postroute_compat() expect to find a valid sk->sk_security
pointer, but this field is NULL for unicast_sock

It turns out that unicast_sock are really temporary stuff to be able
to reuse  part of IP stack (ip_append_data()/ip_push_pending_frames())

Fact is that frames sent by ip_send_unicast_reply() should be orphaned
to not fool LSM.

Note IPv6 never had this problem, as tcp_v6_send_response() doesnt use a
fake socket at all. I'll probably implement tcp_v4_send_response() to
remove these unicast_sock in linux-3.7

Reported-by: John Stultz <johnstul@us.ibm.com>
Bisected-by: John Stultz <johnstul@us.ibm.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paul Moore <paul@paul-moore.com>
Cc: Eric Paris <eparis@parisplace.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
---
 net/ipv4/ip_output.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 76dde25..ec410e0 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1536,6 +1536,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			  arg->csumoffset) = csum_fold(csum_add(nskb->csum,
 								arg->csum));
 		nskb->ip_summed = CHECKSUM_NONE;
+		skb_orphan(nskb);
 		skb_set_queue_mapping(nskb, skb_get_queue_mapping(skb));
 		ip_push_pending_frames(sk, &fl4);
 	}


