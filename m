From: Jason Wang <jasowang@redhat.com>
Subject: Possible NULL dereference caused by -stable commit ef81bb40bf15f350fe865f31fa42f1082772a576
Date: Wed, 28 Sep 2011 18:51:58 +0800
Message-ID: <4E82FC4E.5010101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Amos Kong <akong@redhat.com>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	"David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
	Greg KH <gregkh@suse.de>, stable@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

A possible NULL dereference were noticed by the stable commit 
ef81bb40bf15f350fe865f31fa42f1082772a576 (which is a backport of 
87c48fa3b4630905f98268dde838ee43626a060c). The case happens when bridge 
froward a packet from guest to a physical nic, at this time no route is 
attached to the skb which may lead a NULL dereference in 
ipv6_select_ident(). -Next version have this check so it is fine. The 
following patch may be used to avoid this but may also lead the ip 
identification predicable, and this defect is also exist -next version 
when no route because we still depends on a global variable to generate 
the identification.  Any thought on this?

Thanks.

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4ea6e21..414e2f4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -622,7 +622,9 @@ static u32 __ipv6_select_ident(const struct in6_addr 
*addr)

  void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
  {
-       fhdr->identification = 
htonl(__ipv6_select_ident(&rt->rt6i_dst.addr));
+       const struct in6_addr addr = IN6ADDR_ANY_INIT;
+       fhdr->identification =
+               htonl(__ipv6_select_ident(rt ? &rt->rt6i_dst.addr : &addr));
  }

  int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
