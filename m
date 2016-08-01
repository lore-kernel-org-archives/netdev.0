From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v2 0/3] strp: Stream parser for messages
Date: Mon, 1 Aug 2016 09:33:17 -0700
Message-ID: <1470069200-3279258-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:2513 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754003AbcHAQeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 12:34:22 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u71GUZtu005886
	for <netdev@vger.kernel.org>; Mon, 1 Aug 2016 09:33:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 24gqqm3f4t-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Aug 2016 09:33:28 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 ab65edc0580511e695eb24be05956610-30ffdaf0 for <netdev@vger.kernel.org>;	Mon,
 01 Aug 2016 09:33:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces a utility for parsing application layer
protocol messages in a TCP stream. This is a generalization of the
mechanism implemented of Kernel Connection Multiplexor.

This patch set adapts KCM to use the strparser. We expect that kTLS
can use this mechanism also. RDS would probably be another candidate
to use a common stream parsing mechanism.

The API includes a context structure, a set of callbacks, utility
functions, and a data ready function. The callbacks include
a parse_msg function that is called to perform parsing (e.g.
BPF parsing in case of KCM), and a rcv_msg function that is called
when a full message has been completed.

For strparser we specify the return codes from the parser to allow
the backend to indicate that control of the socket should be
transferred back to userspace to handle some exceptions in the
stream: The return values are:

      >0 : indicates length of successfully parsed message
       0  : indicates more data must be received to parse the message
       -ESTRPIPE : current message should not be processed by the
          kernel, return control of the socket to userspace which
          can proceed to read the messages itself
       other < 0 : Error is parsing, give control back to userspace
          assuming that synchronization is lost and the stream
          is unrecoverable (application expected to close TCP socket)

There is one issue I haven't been able to fully resolve. If parse_msg
returns ESTRPIPE (wants control back to userspace) the parser may
already have consumed some bytes of the message. There is no way to
put bytes back into the TCP receive queue and tcp_read_sock does not
allow an easy way to peek messages. In lieu of a better solution, we
return ENODATA on the socket to indicate that the data stream is
unrecoverable (application needs to close socket). This condition
should only happen if an application layer message header is split
across two skbuffs and parsing just the first skbuff wasn't sufficient
to determine the that transfer to userspace is needed.

This patch set contains:

  - strparser implementation
  - changes to kcm to use strparser
  - strparser.txt documentation

v2:
  - Add copyright notice to C files
  - Remove GPL module license from strparser.c
  - Add report of rxpause

Tested:
  - Ran a KCM thrash test for 24 hours. No behavioral or performance
    differences observed.


Tom Herbert (3):
  strparser: Stream parser for messages
  kcm: Use stream parser
  strparser: Documentation

 Documentation/networking/strparser.txt | 147 ++++++++++
 include/net/kcm.h                      |  37 +--
 include/net/strparser.h                | 147 ++++++++++
 net/Kconfig                            |   1 +
 net/Makefile                           |   1 +
 net/ipv6/ila/ila_common.c              |   1 -
 net/kcm/Kconfig                        |   1 +
 net/kcm/kcmproc.c                      |  44 ++-
 net/kcm/kcmsock.c                      | 464 +++++-------------------------
 net/strparser/Kconfig                  |   4 +
 net/strparser/Makefile                 |   1 +
 net/strparser/strparser.c              | 500 +++++++++++++++++++++++++++++++++
 12 files changed, 916 insertions(+), 432 deletions(-)
 create mode 100644 Documentation/networking/strparser.txt
 create mode 100644 include/net/strparser.h
 create mode 100644 net/strparser/Kconfig
 create mode 100644 net/strparser/Makefile
 create mode 100644 net/strparser/strparser.c

-- 
2.8.0.rc2
