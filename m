From: "David S. Miller" <davem@davemloft.net>
Subject: Re: local_bh_enable & hard_start_xmit
Date: Mon, 18 Apr 2005 15:14:21 -0700
Message-ID: <20050418151421.41a8f64a.davem@davemloft.net>
References: <42642892.2040300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42642892.2040300@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Apr 2005 14:37:22 -0700
Ben Greear <greearb@candelatech.com> wrote:

> So, two questions:
> 
> 1)  Why is it bad to have interrupts disabled when calling
>      the local_bh_enable() method?

Because it creates a deadlock.  You can always take hard IRQ disabling
locks inside of BH disabling ones, but _never_ the other way around.

local_bh_enable() potentially runs BH handlers, and this must occur with
hard IRQs enabled.

> 2)  Should there be a hard requirement that one must never have IRQs disabled
>      when calling dev->hard_start_xmit  (this requirement seems to currently
>      be in effect because VLANs can call dev_queue_xmit from their hard_start_xmit
>      method, and it appears that dev_queue_xmit must not be called with IRQs disabled).

Yes, it is another true requirement.

I even tried to disable hard IRQs during ->hard_start_xmit() to fix a
LLTX locking bug and it totally broke things.

There are ->hard_start_xmit() routines for very slow
devices which expect that jiffies continues to increment via timer
interrupts so that they can timeout feeding bytes to the chip properly.
Also, again with slow devices, it is expected that hard IRQs are enabled
so that your serial ports don't overrun.

In general, it's anti-social to IRQ response time sensitive devices in the
machine to disable hard IRQs for any non-trivial stretch of code.
