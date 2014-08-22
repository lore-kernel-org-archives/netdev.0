From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 03/17] tipc: introduce new
	function tipc_msg_create()
Date: Fri, 22 Aug 2014 18:09:06 -0400
Message-ID: <1408745360-23560-4-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_msg_init() has turned out to be of limited value
in many cases. It take too few parameters to be usable for creating
a complete message, it makes too many assumptions about what the
message should be used for, and it does not allocate any buffer to
be returned to the caller.

Therefore, we now introduce the new function tipc_msg_create(), which
takes all the parameters needed to create a full message, and returns
a buffer of the requested size. The new function will be very useful
for the changes we will be doing in later commits in this series.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/msg.c |   31 +++++++++++++++++++++++++++++--
 net/tipc/msg.h |    4 ++++
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 9680be6..fdb92e2 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -56,8 +56,35 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 	msg_set_size(m, hsize);
 	msg_set_prevnode(m, tipc_own_addr);
 	msg_set_type(m, type);
-	msg_set_orignode(m, tipc_own_addr);
-	msg_set_destnode(m, destnode);
+	if (hsize > SHORT_H_SIZE) {
+		msg_set_orignode(m, tipc_own_addr);
+		msg_set_destnode(m, destnode);
+	}
+}
+
+struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
+				uint data_sz, u32 dnode, u32 onode,
+				u32 dport, u32 oport, int errcode)
+{
+	struct tipc_msg *msg;
+	struct sk_buff *buf;
+
+	buf = tipc_buf_acquire(hdr_sz + data_sz);
+	if (unlikely(!buf))
+		return NULL;
+
+	msg = buf_msg(buf);
+	tipc_msg_init(msg, user, type, hdr_sz, dnode);
+	msg_set_size(msg, hdr_sz + data_sz);
+	msg_set_prevnode(msg, onode);
+	msg_set_origport(msg, oport);
+	msg_set_destport(msg, dport);
+	msg_set_errcode(msg, errcode);
+	if (hdr_sz > SHORT_H_SIZE) {
+		msg_set_orignode(msg, onode);
+		msg_set_destnode(msg, dnode);
+	}
+	return buf;
 }
 
 /* tipc_buf_append(): Append a buffer to the fragment list of another buffer
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 462fa19..3045b2c 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -732,6 +732,10 @@ int tipc_msg_eval(struct sk_buff *buf, u32 *dnode);
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
 
+struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
+				uint data_sz, u32 dnode, u32 onode,
+				u32 dport, u32 oport, int errcode);
+
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 
 bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
