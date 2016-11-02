From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch net-next 0/2] Fixes for raw diag sockets handling
Date: Wed, 02 Nov 2016 15:36:30 +0300
Message-ID: <20161102123630.784612652@openvz.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36136 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753021AbcKBM4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 08:56:06 -0400
Received: by mail-lf0-f67.google.com with SMTP id o20so928297lfg.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 05:56:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi! Here are a few fixes for raw-diag sockets handling: missing
sock_put call and jump for exiting from nested cycle. I made
patches for iproute2 as well so will send them out soon.

Also I have a question about sockets lookup not for raw diag only
(though I didn't modify lookup procedure) but in general: the structure
inet_diag_req_v2 has inet_diag_sockid::idiag_if member which supposed to
carry interface index from userspace request.

Then for example in INET_MATCH (include/net/inet_hashtables.h),
the __dif parameter (which is @idiag_if) compared with @sk_bound_dev_if
*iif* the sk_bound_dev_if has been ever set. Thus if say someone
looks up for paticular device with specified index if the
rest of parameters match and SO_BINDTODEVICE never been called
for this device we return the socket even if idiag_if is not zero.
Is it supposed to be so? Or I miss something obvious?

I mean this snippet


	 (!(__sk)->sk_bound_dev_if	||				\
	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\

when someone calls for destory sockets on particular interface and
@__dif != 0 the match may return socket where sk_bound_dev_if = 0
instead of completely matching one. Isn't it?

	Cyrill
