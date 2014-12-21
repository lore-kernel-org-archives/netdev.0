From: Eric Biggers <ebiggers3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [BUG] rtl8192se: panic accessing unmapped memory in skb
Date: Sun, 21 Dec 2014 11:25:16 -0600
Message-ID: <20141221172516.GA12784@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I have a RTL8192SE wireless card, attached via PCI.  Usually it works with no
issues, but I recently had a kernel panic occur in the rtl8192se driver.  The
kernel version is 3.18.  Based on my analysis of the panic dump, the panic was
caused by a memory access violation in this block of code in
rtl92se_rx_query_desc():

        if (stats->decrypted) {
                hdr = (struct ieee80211_hdr *)(skb->data +
                       stats->rx_drvinfo_size + stats->rx_bufshift);

                if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
                        (ieee80211_has_protected(hdr->frame_control)))
                        rx_status->flag &= ~RX_FLAG_DECRYPTED;
                else
                        rx_status->flag |= RX_FLAG_DECRYPTED;
        }

Specifically, the violation occurred the first time hdr->frame_control was
accessed, as part of _ieee80211_is_robust_mgmt_frame().

The panic occurred when the system was under heavy filesystem load but seemingly
is not easily reproducible.

There was recently a NULL check that was removed from this exact place in the
code, but it was certainly useless.  Instead, what's much more suspect to me is
that inside _rtl_pci_rx_interrupt(), there is no error checking of the return
value of _rtl_pci_init_one_rxdesc(), which might fail if the skb couldn't be
allocated.  I am wondering if this could be causing the problem.

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
