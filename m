From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] hostap: avoid uninitialized variable use in
 hfa384x_get_rid
Date: Wed, 27 Jan 2016 19:26:13 +0000
Message-ID: <20160127192612.GD10826@n2100.arm.linux.org.uk>
References: <1453902342-3420391-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <j@w1.fi>, Kalle Valo <kvalo@codeaurora.org>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453902342-3420391-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 27, 2016 at 02:45:26PM +0100, Arnd Bergmann wrote:
> To ensure we get consistent error handling here, this changes the code
> to only set rlen if we actually read data correctly, which also takes
> care of the warning.

It may be a good idea to do the job better.  Looking at the code:

        struct hfa384x_rid_hdr rec;

        spin_lock_bh(&local->baplock);

        res = hfa384x_setup_bap(dev, BAP0, rid, 0);
        if (!res)
                res = hfa384x_from_bap(dev, BAP0, &rec, sizeof(rec));

The only thing which initialises any of "rec" is that function call.
The following lines are:

        if (le16_to_cpu(rec.len) == 0) {
                /* RID not available */
                res = -ENODATA;
        }

        rlen = (le16_to_cpu(rec.len) - 1) * 2;

So, why give the compiler a hard time as you're doing, why make the code
harder to read.  What's wrong with:

	spin_lock_bh(&local->baplock);

	res = hfa384x_setup_bap(dev, BAP0, rid, 0);
	if (res)
		goto unlock;

	res = hfa384x_from_bap(dev, BAP0, &rec, sizeof(rec));
	if (res)
		goto unlock;

	if (le16_to_cpu(rec.len) == 0) {
		/* RID not available */
		res = -ENODATA;
		goto unlock;
	}

	rlen = (le16_to_cpu(rec.len) - 1) * 2;
	if (exact_len && rlen != len) {
		printk(KERN_DEBUG "%s: hfa384x_get_rid - RID len mismatch: rid=0x%04x, len=%d (expected %d)\n",
		       dev->name, rid, rlen, len);
		res = -ENODATA;
		goto unlock;
	}

	res = hfa384x_from_bap(dev, BAP0, buf, len);
unlock:
	spin_unlock_bh(&local->baplock);

?

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
