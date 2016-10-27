From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next] net: inet: Support UID-based routing
Date: Fri, 28 Oct 2016 02:20:38 +0900
Message-ID: <1477588841-140767-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32833 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933406AbcJ0RUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 13:20:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id 197so21464061pfu.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 10:20:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for per-UID routing. It allows the
administrator to configure rules such as:

  ip rule add uidrange 100-200 lookup 123

This functionality has been in use by all Android devices since
5.0, which was released in late 2014. It is primarily used to
impose per-app routing policies (on Android, every app has its
own UID) without having to resort to rerouting packets in
iptables, which breaks getsockname() and MTU/MSS calculation,
and generally disrupts end-to-end connectivity.

This patch series is similar to the code currently used on
Android, but has better correctness and performance because
it stores the UID in the socket instead of calling sock_i_uid.
This avoids contention on sk->sk_callback_lock, and makes it
possible to correctly route a socket on which userspace has
called close(), for which sock_i_uid will return 0.
