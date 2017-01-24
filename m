From: David Miller <davem@davemloft.net>
Subject: Re: Reference counting struct inet_peer
Date: Tue, 24 Jan 2017 14:20:35 -0500 (EST)
Message-ID: <20170124.142035.1532512255377175036.davem@davemloft.net>
References: <CAEXv5_j1cz1EUPgmAKO5OHxKcoHVLuPPVRs316CWyMpw8UtpRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keescook@chromium.org,
        elena.reshetova@intel.com, ishkamiel@gmail.com
To: dwindsor@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXTUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 14:20:41 -0500
In-Reply-To: <CAEXv5_j1cz1EUPgmAKO5OHxKcoHVLuPPVRs316CWyMpw8UtpRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Windsor <dwindsor@gmail.com>
Date: Mon, 23 Jan 2017 07:42:51 -0500

> struct inet_peer objects get freed when their reference count
> becomes -1, not 0 as is the usual case.  Is there a reason why this
> is so?

inet peer entries that sit in the tree, but have no other reference
taken, have a reference count of zero.

Therefore, any entry which has a reference count of zero can be
safely garbage collected from the tree.

When the garbage collector purges entries with a zero refcnt, it
atomically sets the refcnt to -1 so that other threads of control
in RCU protected sections that still see this entry in the tree
will not be able to grab it for use.

The -1 marker is used as a synchronization mechanism between the
GC and lookup paths.

Once -1 is atomically set, the GC code knows that no external
reference can be created.
