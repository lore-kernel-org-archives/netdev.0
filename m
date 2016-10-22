From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] flow_dissector: fix vlan tag handling
Date: Sat, 22 Oct 2016 22:30:08 +0200
Message-ID: <3590200.oN5tv3ZPpc@wuerfel>
References: <20161021155626.4020344-1-arnd@arndb.de> <20161022155752.GD26044@egarver> <CALx6S35oHmGNw=7taBLxY8ZJHso-b8eRokz3QFA5j_8tW5N8yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        Amir Vadai <amir@vadai.me>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S35oHmGNw=7taBLxY8ZJHso-b8eRokz3QFA5j_8tW5N8yg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc warns about an uninitialized pointer dereference in the vlan
priority handling:

net/core/flow_dissector.c: In function '__skb_flow_dissect':
net/core/flow_dissector.c:281:61: error: 'vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]

As pointed out by Jiri Pirko, the variable is never actually used
without being initialized first as the only way it end up uninitialized
is with skb_vlan_tag_present(skb)==true, and that means it does not
get accessed.

However, the warning hints at some related issues that I'm addressing
here:

- the second check for the vlan tag is different from the first one
  that tests the skb for being NULL first, causing both the warning
  and a possible NULL pointer dereference that was not entirely fixed.
- The same patch that introduced the NULL pointer check dropped an
  earlier optimization that skipped the repeated check of the
  protocol type
- The local '_vlan' variable is referenced through the 'vlan' pointer
  but the variable has gone out of scope by the time that it is
  accessed, causing undefined behavior as the stack may have been
  overwritten.

Caching the result of the 'skb && skb_vlan_tag_present(skb)' check
in a local variable allows the compiler to further optimize the
later check. With those changes, the warning also disappears.

Fixes: 3805a938a6c2 ("flow_dissector: Check skb for VLAN only if skb specified.")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 44e6ba9d3a6b..17be1b66cc41 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -246,13 +246,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
 		const struct vlan_hdr *vlan;
+		struct vlan_hdr _vlan;
+		bool vlan_tag_present = (skb && skb_vlan_tag_present(skb));
 
-		if (skb && skb_vlan_tag_present(skb))
-			proto = skb->protocol;
-
-		if (eth_type_vlan(proto)) {
-			struct vlan_hdr _vlan;
-
+		if (!vlan_tag_present || eth_type_vlan(skb->protocol)) {
 			vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan),
 						    data, hlen, &_vlan);
 			if (!vlan)
@@ -270,7 +267,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 							     FLOW_DISSECTOR_KEY_VLAN,
 							     target_container);
 
-			if (skb_vlan_tag_present(skb)) {
+			if (vlan_tag_present) {
 				key_vlan->vlan_id = skb_vlan_tag_get_id(skb);
 				key_vlan->vlan_priority =
 					(skb_vlan_tag_get_prio(skb) >> VLAN_PRIO_SHIFT);
