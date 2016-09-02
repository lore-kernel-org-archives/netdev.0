From: Jarod Wilson <jarod@redhat.com>
Subject: Minimum MTU Mess
Date: Fri, 2 Sep 2016 13:07:42 -0400
Message-ID: <20160902170742.GA17677@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35608 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932845AbcIBRII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:08:08 -0400
Received: by mail-yw0-f176.google.com with SMTP id j12so73556344ywb.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:07:45 -0700 (PDT)
Received: from redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id t67sm4401958ywa.33.2016.09.02.10.07.44
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 10:07:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So... I had a bug reported, about a NIC that ceased to work, if it's MTU
was set to 0, then back to it's original value (1500). This got me
thinking... What does an MTU of 0 even mean? Why should it be allowed?

As it turns out, most (but not all) network drivers have a check in their
ndo_change_mtu function that returns -EINVAL if new_mtu < $magic_number,
which is often 68 (per page 25 of RFC 791), but is sometimes 64, or 60, or
46... Sometimes other manipulations are done. But the short version is
that it seems there's an almost universal need to check for a minimum MTU.
There's just some disagreement on what that minimum is.

So, rather than having nearly every ndo_change_mut callback do the exact
same thing, would it make sense to settle on one minimum MTU value, and
check that unilaterally (at least for certain netdev types) in
net/core/dev.c's dev_set_mtu()? Or is intentionally left vague, because
it's really up to the hardware to care?

Alternatively, perhaps each driver should set a netdev->min_mtu value, and
net/core/dev.c could check against that. Could even have a centralized
IP_MIN_MTU of 68 that all devices using ether_setup() and/or
alloc_etherdev() used by default.

In any case, the number of "mtu < 68" and "#define FOO_MIN_MTU 68", or
variations thereof, under drivers/net/ is kind of crazy.

In the interim, I think I'll just do a 3-line patch for this one driver
that mirrors all the existing drivers to keep it from going splat...

-- 
Jarod Wilson
jarod@redhat.com
