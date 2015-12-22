From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [iproute PATCH v2 2/2] ss: support closing inet sockets via SOCK_DESTROY.
Date: Tue, 22 Dec 2015 17:31:32 +0900
Message-ID: <1450773094-7978-1-git-send-email-lorenzo@google.com>
References: <20151221214222.5ee87383@xeon-e3>
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36125 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbbLVIcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 03:32:13 -0500
Received: by mail-pa0-f51.google.com with SMTP id q3so93237967pav.3
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 00:32:13 -0800 (PST)
In-Reply-To: <20151221214222.5ee87383@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just uploaded a new version. The changes from v2 are as
follows:

- Removed the superfluous inline keyword.
- The code now ignores ENOENT from kill_inet_sock. This can
  happen if something else closed the socket during the scan, or
  if the user requests killing a socket that is not in the hash
  tables and thus cannot be found by inet_diag_find_one_icsk.
- The semantics of rtnl_send_check_ack are clearer. If the caller
  passes in ack=1, the function blocks until a response is
  received (unlike v2 which passed in MSG_PEEK). Also, an
  NLMSG_ERROR with an err of 0 is not treated as a failure.
- kill_inet_sock always requests an ACK when closing a socket.

This version is also tested on real hardware. The following work:

- Passing in -K as non-root immediately stops with EPERM.
- Running "ss -a -K dport = :22" closes SSH.
- Running ss -a -K dport = :5222 closes my XMPP connections,
  interrupts my chat client, and sends RSTs to the server.
- The above command silently skips TIME_WAIT sockets, which
  cannot be destroyed, without interrupting the dump.
