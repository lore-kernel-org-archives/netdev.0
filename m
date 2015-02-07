From: Chen Gang S <gang.chen@sunrus.com.cn>
Subject: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead of
 'void *' for 2nd parameter of hci_test_bit()
Date: Sat, 07 Feb 2015 21:24:57 +0800
Message-ID: <54D61229.9010904@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Marcel Holtmann <marcel@holtmann.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hci_test_bit() does not modify 2nd parameter, so it is better to let it
be constant, or may cause build warning. The related warning (with
allmodconfig under xtensa):

  net/bluetooth/hci_sock.c: In function 'hci_sock_sendmsg':
  net/bluetooth/hci_sock.c:955:8: warning: passing argument 2 of 'hci_test_bit' discards 'const' qualifier from pointer target type [-Wdiscarded-array-qualifiers]
          &hci_sec_filter.ocf_mask[ogf])) &&
          ^
  net/bluetooth/hci_sock.c:49:19: note: expected 'void *' but argument is of type 'const __u32 (*)[4] {aka const unsigned int (*)[4]}'
   static inline int hci_test_bit(int nr, void *addr)
                     ^

hci_test_bit() always treats 2nd parameter is u32, and all callers also
know about it, so 2nd parameter of hci_test_bit() need use 'const u32 *'
instead of 'void *'.

C language treats the array function parameter as a pointer, so the
caller need not use '&' for the 2 demotion array, or it reports warning:
'const unsigned int (*)[4]' is different with 'const unsigned int *'.


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 net/bluetooth/hci_sock.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 1d65c5b..04124ec 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -46,9 +46,9 @@ struct hci_pinfo {
 	unsigned short    channel;
 };
 
-static inline int hci_test_bit(int nr, void *addr)
+static inline int hci_test_bit(int nr, const u32 *addr)
 {
-	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
+	return *(addr + (nr >> 5)) & ((u32) 1 << (nr & 31));
 }
 
 /* Security filter */
@@ -107,7 +107,7 @@ static bool is_filtered_packet(struct sock *sk, struct sk_buff *skb)
 
 	flt_event = (*(__u8 *)skb->data & HCI_FLT_EVENT_BITS);
 
-	if (!hci_test_bit(flt_event, &flt->event_mask))
+	if (!hci_test_bit(flt_event, (u32 *)&flt->event_mask))
 		return true;
 
 	/* Check filter only when opcode is set */
@@ -952,7 +952,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (((ogf > HCI_SFLT_MAX_OGF) ||
 		     !hci_test_bit(ocf & HCI_FLT_OCF_BITS,
-				   &hci_sec_filter.ocf_mask[ogf])) &&
+				   hci_sec_filter.ocf_mask[ogf])) &&
 		    !capable(CAP_NET_RAW)) {
 			err = -EPERM;
 			goto drop;
-- 
1.9.3
