From: Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>
Subject: Re: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Sun, 27 Sep 2009 21:58:38 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0909272139280.4061@sister.anvils>
References: <1254076075.6583.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254076075.6583.6.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 27 Sep 2009, Johannes Berg wrote:

> The point we assign dev->wireless_handlers at is too
> late, we need to do that before netdev_register_kobject()
> gets called, so use the new NETDEV_PRE_INIT notifier.
> The result of adding wireless_handlers too late is the
> disappearance of /sys/class/net/wlan0/wireless which a
> bunch of distro scripts still require.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

This 2/2 patch does indeed work: many thanks.  But...

> ---
> This should fix the regression Hugh reported (of course requires the
> other patch which unfortunately I forgot to CC you, Hugh, I'll send you
> a copy in private).

... the 1/2 patch has a couple of problems.

The trivial problem is that include/linux/notifier.h in Linus's git has
#define NETDEV_PRE_UP		0x000D
#define NETDEV_BONDING_OLDTYPE  0x000E
#define NETDEV_BONDING_NEWTYPE  0x000F

So it rejects the patch you posted: I changed it to add
#define NETDEV_PRE_INIT		0x0010
just after the NETDEV_BONDING_NEWTYPE line.

The more serious problem is that it stops both my machines from booting,
too early for framebuffer to show any messages, but vga=normal shows a
long stacktrace scrolling offscreen, with some notifier stuff in there.

I've experimented by moving your NETDEV_PRE_INIT hunk later in the
sequence, just before the netdev_initialize_kobject(dev) (so I also
changed the "goto out" to "goto err_uninit"): both* machines then boot
correctly, and this mail leaves me wirelessly.

I'll now experiment to see how early I can move that hunk.

Hugh

* I wrote that hoping the Aspire One build would complete soon,
but it's still going: assume it's fine unless I say otherwise.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
