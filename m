From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 3/3] strparser: Documentation
Date: Mon, 15 Aug 2016 14:51:03 -0700
Message-ID: <1471297863-1356555-4-git-send-email-tom@herbertland.com>
References: <1471297863-1356555-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <lancerchao@gmail.com>, <davejwatson@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49048 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752856AbcHOVvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 17:51:18 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7FLmxC1008772
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 14:51:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24uk5r9031-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 14:51:17 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 644085c6633211e6b6ec0002c992ebde-2bf6aa0 for <netdev@vger.kernel.org>;	Mon,
 15 Aug 2016 14:51:16 -0700
In-Reply-To: <1471297863-1356555-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/strparser.txt | 137 +++++++++++++++++++++++++++++++++
 1 file changed, 137 insertions(+)
 create mode 100644 Documentation/networking/strparser.txt

diff --git a/Documentation/networking/strparser.txt b/Documentation/networking/strparser.txt
new file mode 100644
index 0000000..f8cc25d
--- /dev/null
+++ b/Documentation/networking/strparser.txt
@@ -0,0 +1,137 @@
+Stream Parser
+-------------
+
+The stream parser (strparser) is a utility that parses messages of an
+application layer protocol running over a TCP connection. The stream
+parser works in conjunction with an upper layer in the kernel to provide
+kernel support for application layer messages. For instance, Kernel
+Connection Multiplexor (KCM) uses the Stream Parser to parse messages
+using a BPF program.
+
+Interface
+---------
+
+The API includes a context structure, a set of callbacks, utility
+functions, and a data_ready function. The callbacks include
+a parse_msg function that is called to perform parsing (e.g.
+BPF parsing in case of KCM), and a rcv_msg function that is called
+when a full message has been completed.
+
+A stream parser can be instantiated for a TCP connection. This is done
+by:
+
+strp_init(struct strparser *strp, struct sock *csk,
+	  struct strp_callbacks *cb)
+
+strp is a struct of type strparser that is allocated by the upper layer.
+csk is the TCP socket associated with the stream parser. Callbacks are
+called by the stream parser.
+
+Callbacks
+---------
+
+There are four callbacks:
+
+int (*parse_msg)(struct strparser *strp, struct sk_buff *skb);
+
+    parse_msg is called to determine the length of the next message
+    in the stream. The upper layer must implement this function. It
+    should parse the sk_buff as containing the headers for the
+    next application layer messages in the stream.
+
+    The skb->cb in the input skb is a struct strp_rx_msg. Only
+    the offset field is relevant in parse_msg and gives the offset
+    where the message starts in the skb.
+
+    The return values of this function are:
+
+    >0 : indicates length of successfully parsed message
+    0  : indicates more data must be received to parse the message
+    -ESTRPIPE : current message should not be processed by the
+          kernel, return control of the socket to userspace which
+          can proceed to read the messages itself
+    other < 0 : Error is parsing, give control back to userspace
+          assuming that synchronization is lost and the stream
+          is unrecoverable (application expected to close TCP socket)
+
+    In the case that an error is returned (return value is less than
+    zero) the stream parser will set the error on TCP socket and wake
+    it up. If parse_msg returned -ESTRPIPE and the stream parser had
+    previously read some bytes for the current message, then the error
+    set on the attached socket is ENODATA since the stream is
+    unrecoverable in that case.
+
+void (*rcv_msg)(struct strparser *strp, struct sk_buff *skb);
+
+    rcv_msg is called when a full message has been received and
+    is queued. The callee must consume the sk_buff; it can
+    call strp_pause to prevent any further messages from being
+    received in rcv_msg (see strp_pause below). This callback
+    must be set.
+
+    The skb->cb in the input skb is a struct strp_rx_msg. This
+    struct contains two fields: offset and full_len. Offset is
+    where the message starts in the skb, and full_len is the
+    the length of the message. skb->len - offset may be greater
+    then full_len since strparser does not trim the skb.
+
+int (*read_sock_done)(struct strparser *strp, int err);
+
+     read_sock_done is called when the stream parser is done reading
+     the TCP socket. The stream parser may read multiple messages
+     in a loop and this function allows cleanup to occur when existing
+     the loop. If the callback is not set (NULL in strp_init) a
+     default function is used.
+
+void (*abort_parser)(struct strparser *strp, int err);
+
+     This function is called when stream parser encounters an error
+     in parsing. The default function stops the stream parser for the
+     TCP socket and sets the error in the socket. The default function
+     can be changed by setting the callback to non-NULL in strp_init.
+
+Functions
+---------
+
+The upper layer calls strp_tcp_data_ready when data is ready on the lower
+socket for strparser to process. This should be called from a data_ready
+callback that is set on the socket.
+
+strp_stop is called to completely stop stream parser operations. This
+is called internally when the stream parser encounters an error, and
+it is called from the upper layer when unattaching a TCP socket.
+
+strp_done is called to unattach the stream parser from the TCP socket.
+This must be called after the stream processor has be stopped.
+
+strp_check_rcv is called to check for new messages on the socket. This
+is normally called at initialization of the a stream parser instance
+of after strp_unpause.
+
+Statistics
+----------
+
+Various counters are kept for each stream parser for a TCP socket.
+These are in the strp_stats structure. strp_aggr_stats is a convenience
+structure for accumulating statistics for multiple stream parser
+instances. save_strp_stats and aggregate_strp_stats are helper functions
+to save and aggregate statistics.
+
+Message assembly limits
+-----------------------
+
+The stream parser provide mechanisms to limit the resources consumed by
+message assembly.
+
+A timer is set when assembly starts for a new message. The message
+timeout is taken from rcvtime for the associated TCP socket. If the
+timer fires before assembly completes the stream parser is aborted
+and the ETIMEDOUT error is set on the TCP socket.
+
+Message length is limited to the receive buffer size of the associated
+TCP socket. If the length returned by parse_msg is greater than
+the socket buffer size then the stream parser is aborted with
+EMSGSIZE error set on the TCP socket. Note that this makes the
+maximum size of receive skbuffs for a socket with a stream parser
+to be 2*sk_rcvbuf of the TCP socket.
+
-- 
2.8.0.rc2
