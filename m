From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v2] net: inet: Support UID-based routing
Date: Fri,  4 Nov 2016 02:23:40 +0900
Message-ID: <1478193823-60516-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36210 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754218AbcKCRXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:23:50 -0400
Received: by mail-pf0-f169.google.com with SMTP id 189so35010532pfz.3
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:23:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for per-UID routing. It allows the
administrator to configure rules such as:

  ip rule add uidrange 100-200 lookup 123

This functionality has been in use by all Android devices since
5.0. It is primarily used to impose per-app routing policies (on
Android, every app has its own UID) without having to resort to
rerouting packets in iptables, which breaks getsockname() and
MTU/MSS calculation, and generally disrupts end-to-end
connectivity.

This patch series is similar to the code currently used on
Android, but has better correctness and performance because
it stores the UID in the socket instead of calling sock_i_uid.
This avoids contention on sk->sk_callback_lock, and makes it
possible to correctly route a socket on which userspace has
called close(), for which sock_i_uid will return 0.

Changes from v1:
- Don't set the UID in sk_clone_lock, it's already set by
  sock_copy.
- For packets originated by kernel sockets, don't use the socket
  UID. This is the UID that created the namespace, but it might
  not be mapped in the namespace at all. Instead, use UID 0 in
  the namespace, which is less surprising and consistent with
  what happens in the root namespace.
- Fix UID routing of IPv4 and IPv6 SYN_RECV sockets.
- Fix UID routing of received IPv6 redirects.
