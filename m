From: Ani Sinha <ani@arista.com>
Subject: [PATCH] net: socket: do not validate msg_namelen unless msg_name is non-NULL
Date: Fri, 5 Sep 2014 14:00:39 -0700
Message-ID: <CAOxq_8O=8epuyj2+V8RFep2tHVwk06q5gEK1ho0RUSV4GQV0Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, fenner <fenner@arista.com>,
	fruggeri <fruggeri@arista.com>, travisb <travisb@arista.com>
To: David Miller <davem@davemloft.net>, matthew.leach@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:56481 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbaIEVBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:01:00 -0400
Received: by mail-ie0-f170.google.com with SMTP id tp5so1271397ieb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 14:00:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys :

I am looking at the thread :

 [PATCH] net: socket: error on a negative msg_namelen

and the patch that was submitted in that thread :

commit dbb490b96584d4e958533fb637f08b557f505657
Author: Matthew Leach <matthew.leach@arm.com>
Date:   Tue Mar 11 11:58:27 2014 +0000

    net: socket: error on a negative msg_namelen


According to the linux recvmsg manpage, the caller of recvmsg() may
set msg_name to NULL if he does not care about source address but the
manpage does not say that one has to set msg_namelen to 0 in this
case. Essentially msg_namelen is a don't care if msg_name is NULL. I
think in the kernel, we should validate msg_namelen only if the caller
has also set msg_name and return EINVAL only when msg_name is non-null
and msg_namelen is negative.

The following patch will do the intended :


>From ef8e8bd78635ac677f2d4b76fec9990ed1db763c Mon Sep 17 00:00:00 2001
From: Ani Sinha <ani@aristanetworks.com>
Date: Fri, 5 Sep 2014 13:25:22 -0700
Subject:[PATCH] net: socket: do not validate msg_namelen unless
msg_name is non-NULL

The value of msg_namelen in msghdr structure is irrelevant
 when msg_name is NULL. We should not validate the value
 passed in msg_namelen unless msg_name is non-NULL.

Signed-off-by: Ani Sinha <ani@aristanetworks.com>
---
 net/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 95ee7d8..a5dfe01 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1997,7 +1997,7 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
  if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
  return -EFAULT;

- if (kmsg->msg_namelen < 0)
+ if (kmsg->msg_name && kmsg->msg_namelen < 0)
  return -EINVAL;

  if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
-- 
1.7.4.4
