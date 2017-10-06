From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 3/9] net/mac89x0: Fix and modernize log messages
Date: Thu, 05 Oct 2017 21:08:42 -0700 (PDT)
Message-ID: <20171005.210842.1348457661309929796.davem@davemloft.net>
References: <cover.1507211120.git.fthain@telegraphics.com.au>
        <e9fb341944d187cabf1ccef78cfdc9de64e3f158.1507211120.git.fthain@telegraphics.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e9fb341944d187cabf1ccef78cfdc9de64e3f158.1507211120.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Thu,  5 Oct 2017 21:11:05 -0400 (EDT)

> Fix misplaced newlines in conditional log messages.

Please don't do this, the way the author formatted the strings
was intentional, they intended to print out:

	NAME: cs89%c0%s rev %c found at %#8lx IRQ %d ADDR %pM

But now you are splitting it into multiple lines.  Also, you're
printing the IRQ information after register_netdev() which is
bad.  As soon as register_netdev() is called, the driver's
->open() routine can be invoked, and during which time some
log messages could be emitted during that operation.

And that would cut the probe messages up.

I know how you got to this state, you saw a reference to dev->name
before it had a real value.  You just removed the "eth%d" string
entirely.  And since you removed the dev->name reference, you had
no reason to move log messages after register_netdev() at all.

Anyways, you can also see the intention of the author here becuase
they have _explicit_ leading newlines in the error path messages that
come after the inital probe printk.

The real way to fix the early dev->name reference is to replace it
with a dev_info() call and have it use the struct device name rather
than the netdev device one.

Again, I think you really shouldn't be making these small weird
changes to these old drivers.
