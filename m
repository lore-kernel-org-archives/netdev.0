From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH RFC 0/2] stap: Socket tap
Date: Mon,  7 Aug 2017 15:12:02 -0700
Message-ID: <20170807221204.15724-1-tom@quantonium.net>
Cc: rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34150 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdHGWMj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 18:12:39 -0400
Received: by mail-pg0-f43.google.com with SMTP id u185so6752655pgb.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 15:12:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces generic socket tap support. This allows a
means to run BPF programs or implement other functionality in both the
send and receive path of a socket.

The socket tap uses the ULP mechanism recently introduced for kTLS.
The data operations (sendmsg, recvmsg, sendpage, and splice_recv)
are intercepted. In both directions strparser is used to break the
stream into discrete application layer messages. Each message is
then run through a BPF verdict program that indicates the message
is okay, should be dropped, or should be dropped and the connection
terminated.

The data path for socket tap for TCP is illustrated below:

  +---------------------+
  |  Application        |
  |                     |
  |  sendmsg  recvmsg   |
  +---------------------+
        |         ^
        |         |
--------|---------|---------------------
        |         |
        |    +-------------+    +--------------+    +----------------+
        |    | Socket tap  |<---| Verdict prog |<---| strparser      |
	|    | recvmsg	   |	|	       |    | TCP data ready |
        |    +-------------+    +--------------+    +----------------+
        |						    ^
	|						    |
	|						TCP receive queue
        V
  +-------------+   +-----------+   +--------------+   +---------------+
  | Socket tap  |-->| strparser |-->| Verdict prog |-->| skb_send_sock |
  | sendmsg     |   | send mode |   |		   |   | locked	       |
  +-------------+   +-----------+   +--------------+   +---------------+
							     |
							     V
							TCP write queue

Interface:

A socket tap is enabled on socket using SO_ULP socket option with
ulp type "stap". The socket option takes ULP specific configuration
in the stap_params structure. The parameters consist of four file
descriptors for BPF programs. These are for the parser (strparser)
in the send path, the verdict program for send path, the parser
and verdict programs in the receive path.

Example configuration to set a socket tap. In this case the same 
parse and verdict programs are used on send and receive sides of the
socket.:

struct {
	struct ulp_config ulpc;
	struct stap_params sp;
} my_config;

load_bpf_file("parse_kern.o");
load_bpf_file("verdict_kern.o");

my_config.ulpc.ulp_name = "stap";
my_config.sp.bpf_send_parse_fd = prog_fd[0];
my_config.sp.bpf_send_verdict_fd = prog_fd[1];
my_config.sp.bpf_recv_parse_fd = prog_fd[0];
my_config.sp.bpf_recv_verdict_fd = prog_fd[1];

setsockopt(fd, SOL_SOCKET, SO_ULP, &my_config, sizeof(myconfig)

Future work:

  - Fill in all the expected semantics. A goal of socket tap is
    transparency with applications.
  - Performance evaluation.
  - Add a mechanism to allow an admin process to tap other users'
    sockets.
  - Add userpsace tap that can diverted applciation messages through
    userpsace. I'm thinking to connect tapped sockets to KCM to provide
    for interface.
  - Integrate with kTLS.
  - SUpport for BFP_REDIRECT. This would be useful to redirect messages
    to different sockets like in John Fasatabend's socket redirect.

Tom Herbert (2):
  bpf: Add a BPF return code to disconnect a connection
  stap: Socket tap

 include/net/stap.h        |  43 +++
 include/uapi/linux/bpf.h  |   1 +
 include/uapi/linux/stap.h |  21 ++
 net/Kconfig               |   1 +
 net/Makefile              |   1 +
 net/stap/Kconfig          |   8 +
 net/stap/Makefile         |   3 +
 net/stap/stap_main.c      | 769 ++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 847 insertions(+)
 create mode 100644 include/net/stap.h
 create mode 100644 include/uapi/linux/stap.h
 create mode 100644 net/stap/Kconfig
 create mode 100644 net/stap/Makefile
 create mode 100644 net/stap/stap_main.c

-- 
2.11.0
