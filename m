From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 0/2] strp: Stream parser for messages
Date: Tue, 5 Jul 2016 12:03:32 -0700
Message-ID: <1467745414-2763835-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:61630 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750774AbcGETDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:03:41 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65J1Udc013154
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2016 12:03:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 240hvx8c9r-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 12:03:41 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 2e83447e42e311e6896f24be05956610-4b4f8af0 for <netdev@vger.kernel.org>;	Tue,
 05 Jul 2016 12:03:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces a utility for parsing application layer
protocol messages in a TCP stream. This is a generalization of the
mechanism implemented of Kernel Connection Multiplexor.

This patch set adapts KCM to use the strparser. We expect that kTLS
can use this mechanism also. RDS would probably be another candidate
to use a commone stream parsing mechanism.

The API includes a context structure, a set of callbacks, utility
functions, and a data ready function. The callbacks include
a parse_msg function that is called to perform parsing (e.g.
BPF parsing in case of KCM), and a rcv_msg funciton that is called
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
          assuming that synchronzation is lost and the stream
          is unrecoverable (application expected to close TCP socket)

There is one issue I haven't been able to fully resolve. If the
parse_msg return ESTRPIPE (wants control back to userspace)
the parser may have already ready some bytes of the message.
There is no way to put bytes back into the TCP receive queue and
tcp_read_sock does not allow an easy way to peek messages. In
lieu of a better solution, we return ENODATA on the socket to
indicate that the data stream is unrecoverable (application needs
to close socket). This condition should only happen if an application
layer message header is split across two skbuffs and parsing just
the first skbuff wasn't sufficient to determine the that transfer
to userspace is needed.

TBD: Need to document API.

Tom Herbert (2):
  strparser: Stream parser for messages
  kcm: Use stream parser

 include/net/kcm.h         |  36 +---
 include/net/strparser.h   | 146 ++++++++++++++
 net/Kconfig               |   1 +
 net/Makefile              |   1 +
 net/kcm/Kconfig           |   1 +
 net/kcm/kcmproc.c         |  41 ++--
 net/kcm/kcmsock.c         | 435 ++++++------------------------------------
 net/strparser/Kconfig     |   4 +
 net/strparser/Makefile    |   1 +
 net/strparser/strparser.c | 472 ++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 711 insertions(+), 427 deletions(-)
 create mode 100644 include/net/strparser.h
 create mode 100644 net/strparser/Kconfig
 create mode 100644 net/strparser/Makefile
 create mode 100644 net/strparser/strparser.c

-- 
2.8.0.rc2
