From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/4] [RTNETLINK] Routing attribute related shortcuts
Date: Thu, 26 May 2005 20:54:49 +0200
Message-ID: <20050526185449.GY15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526185306.GW15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 RTA_GET_U(32|64)(tlv)
   Assumes TLV is a u32/u64 field and returns its value.

 RTA_GET_[M]SECS(tlv)
   Assumes TLV is a u64 and transports jiffies converted
   to seconds or milliseconds and returns its value.

 RTA_PUT_U(32|64)(skb, type, value)
   Appends %value as fixed u32/u64 to %skb as TLV %type.

 RTA_PUT_[M]SECS(skb, type, jiffies)
   Converts %jiffies to secs/msecs and appends it as u64
   to %skb as TLV %type.

 RTA_PUT_STRING(skb, type, string)
   Appends %NUL terminated %string to %skb as TLV %type.

 RTA_NEST(skb, type)
   Starts a nested TLV %type and returns the nesting handle.

 RTA_NEST_END(skb, nesting_handle)
   Finishes the nested TLV %nesting_handle, must be called
   symmetric to RTA_NEST(). Returns skb->len

 RTA_NEST_CANCEL(skb, nesting_handle)
   Cancel the nested TLV %nesting_handle and trim nested TLV
   from skb again, returns -1.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit d24c37db15b6cd790459d9d91ee6331ce17264b4
tree 52e7990f6dee710624f823014c40c14e0e5ccf39
parent 88e04e26d887e806372014a2f7b33c6a7ea64741
author Thomas Graf <tgraf@suug.ch> Thu, 26 May 2005 18:22:23 +0200
committer Thomas Graf <tgraf@suug.ch> Thu, 26 May 2005 18:22:23 +0200

 include/linux/rtnetlink.h |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+)

Index: include/linux/rtnetlink.h
===================================================================
--- 031c0e0d63096ca2dff2203940b90460f1db5c68/include/linux/rtnetlink.h  (mode:100644)
+++ 52e7990f6dee710624f823014c40c14e0e5ccf39/include/linux/rtnetlink.h  (mode:100644)
@@ -789,6 +789,51 @@
 ({	if (unlikely(skb_tailroom(skb) < (int)(attrlen))) \
 		goto rtattr_failure; \
 	memcpy(skb_put(skb, RTA_ALIGN(attrlen)), data, attrlen); })
+
+#define RTA_PUT_U32(skb, attrtype, value) \
+({	u32 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u32), &_tmp); })
+
+#define RTA_PUT_U64(skb, attrtype, value) \
+({	u64 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u64), &_tmp); })
+
+#define RTA_PUT_SECS(skb, attrtype, value) \
+	RTA_PUT_U64(skb, attrtype, (value) / HZ)
+
+#define RTA_PUT_MSECS(skb, attrtype, value) \
+	RTA_PUT_U64(skb, attrtype, jiffies_to_msecs(value))
+
+#define RTA_PUT_STRING(skb, attrtype, value) \
+	RTA_PUT(skb, attrtype, strlen(value) + 1, value)
+
+#define RTA_NEST(skb, type) \
+({	struct rtattr *__start = (struct rtattr *) (skb)->tail; \
+	RTA_PUT(skb, type, 0, NULL); \
+	__start;  })
+
+#define RTA_NEST_END(skb, start) \
+({	(start)->rta_len = ((skb)->tail - (unsigned char *) (start)); \
+	(skb)->len; })
+
+#define RTA_NEST_CANCEL(skb, start) \
+({	skb_trim(skb, (unsigned char *) (start) - (skb)->data); \
+	-1; })
+
+#define RTA_GET_U32(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u32)) \
+		goto rtattr_failure; \
+	*(u32 *) RTA_DATA(rta); })
+
+#define RTA_GET_U64(rta) \
+({	u64 _tmp; \
+	if (!rta || RTA_PAYLOAD(rta) < sizeof(u64)) \
+		goto rtattr_failure; \
+	memcpy(&_tmp, RTA_DATA(rta), sizeof(_tmp)); \
+	_tmp; })
+
+#define RTA_GET_SECS(rta) ((unsigned long) RTA_GET_U64(rta) * HZ)
+#define RTA_GET_MSECS(rta) (msecs_to_jiffies((unsigned long) RTA_GET_U64(rta)))
 		
 static inline struct rtattr *
 __rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)
