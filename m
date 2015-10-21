From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH] netlink: fix locking around NETLINK_LIST_MEMBERSHIPS
Date: Wed, 21 Oct 2015 11:47:43 +0200
Message-ID: <1445420863-1476-1-git-send-email-dh.herrmann@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	"# 4 . 2+" <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, NETLINK_LIST_MEMBERSHIPS grabs the netlink table while copying
the membership state to user-space. However, grabing the netlink table is
effectively a write_lock_irq(), and as such we should not be triggering
page-faults in the critical section.

This can be easily reproduced by the following snippet:
    int s = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
    void *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0);
    int r = getsockopt(s, 0x10e, 9, p, (void*)((char*)p + 4092));

This should work just fine, but currently triggers EFAULT and a possible
WARN_ON below handle_mm_fault().

Fix this by reducing locking of NETLINK_LIST_MEMBERSHIPS to a read-side
lock. The write-lock was overkill in the first place, and the read-lock
allows page-faults just fine.

Cc: <stable@vger.kernel.org> # 4.2+
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 net/netlink/af_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8f060d7..2389602 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2371,7 +2371,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		int pos, idx, shift;
 
 		err = 0;
-		netlink_table_grab();
+		netlink_lock_table();
 		for (pos = 0; pos * 8 < nlk->ngroups; pos += sizeof(u32)) {
 			if (len - pos < sizeof(u32))
 				break;
@@ -2386,7 +2386,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		}
 		if (put_user(ALIGN(nlk->ngroups / 8, sizeof(u32)), optlen))
 			err = -EFAULT;
-		netlink_table_ungrab();
+		netlink_unlock_table();
 		break;
 	}
 	case NETLINK_CAP_ACK:
-- 
2.6.1
