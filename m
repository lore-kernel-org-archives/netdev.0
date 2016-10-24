From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/5] genetlink improvements
Date: Mon, 24 Oct 2016 14:40:00 +0200
Message-ID: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51684 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935199AbcJXMkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:40:11 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <johannes@sipsolutions.net>)
        id 1byeXw-0004ro-Cq
        for netdev@vger.kernel.org; Mon, 24 Oct 2016 14:40:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains some generic netlink improvements, making
the API safer to use, and making the function pointers in the
family struct safer by allowing it to be __ro_after_init.

The first patch, introducing genl_family_attrbuf(), just ensures
that the users of family->attrbuf aren't actually racy, but making
them use the indirection function for obtaining a reference and
checking that the context can actually do so.

The second patch removes the more or less broken ability to have
a static family ID, the three IDs that need to be static because
it's simply needed (genl controller), or due to old API misused.
Everything else couldn't be static anyway, or could fail when the
family is registered, if somebody else already got a static ID.

The third patch statically initializes the families, mostly to save
some code. I wrote this initially because I thought I could make
them all const, but that ends up being very inefficient (it would
require always doing some kind of family -> id lookup), so now it's
just here because I had it already and it reduces the code size.

The fourth patch then, finally, lays the groundwork for what I had
really wanted - now with __ro_after_init instead of const; I remove
code there to do the ID->family hash table mapping in genetlink and
use IDR instead to both allocate and map the IDs, which again ends
up saving some code size.

Finally, the fifth patch updates all families, as it turns out, no
families exist that really dynamically register/unregister. This
last patch should perhaps be split up, I could submit it for each
subsystem separately, but it'd depend on the second and third to
go in first, so would take a while. I can do that though, if that
seems better to you.

johannes
