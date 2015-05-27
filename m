From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: __inet_hash_connect port_offset parameter
Date: Wed, 27 May 2015 18:25:54 +0300
Message-ID: <5565E202.8010202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37605 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbE0PZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 11:25:52 -0400
Received: by wifw1 with SMTP id w1so27088827wif.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 08:25:51 -0700 (PDT)
Received: from [10.205.20.121] ([109.100.41.154])
        by mx.google.com with ESMTPSA id bm9sm27406739wjc.21.2015.05.27.08.25.49
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 08:25:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm confused about the port_offset parameter to __inet_hash_connect.

When allocating the local port for an outgoing TCP connection the port search looks something like this:

    static u32 hint;
    u32 offset = hint + port_offset;

    inet_get_local_port_range(net, &low, &high);
    remaining = (high - low) + 1;

    for (i = 1; i <= remaining; i++) {
        port = low + (i + offset) % remaining;
        /* check port is free */

The port_offset is calculated for v4 and v6 based on a hash of src/dst addresses, presumably in order to improve security.

I see a few issues with this:
 - The port_offset is calculated even if the local port was already assigned via bind. This wastes a few cycles.
 - Keeping the last searched port as a static variable is a bad idea on multicore cpus. Starting a lot of connections to the same target will result in lock contention in the bind hash. This is probably only visible in highly synthetic tests.
 - When doing a port search at bind() time the search starts from "prandom_32()". Is this "less secure" for port allocation? I bet most applications are not aware of this difference.

Wouldn't it be better to use the same local port search mechanism at both bind (inet_csk_get_port) and connect (__inet_hash_connect) time, based on starting from a random point? It would also make connecting slightly faster.

Regards,
Leonard
