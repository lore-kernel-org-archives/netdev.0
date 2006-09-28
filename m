From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: kernel: TKIP: replay detected:
Date: Thu, 28 Sep 2006 15:48:01 -0700
Message-ID: <20060928224801.GJ9615@instant802.com>
References: <20060924104053.GA6645@frodo.home.lxtec.de> <20060925144954.GC16949@tuxdriver.com> <20060928160834.GC9615@instant802.com> <451C41B2.4090209@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-51.dex002.intermedia.net ([64.78.21.150]:56387 "EHLO
	DHOST002-51.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1161355AbWI1WsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:48:07 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <451C41B2.4090209@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 04:42:10PM -0500, Larry Finger wrote:

> @@ -544,6 +548,14 @@ int bcm43xx_rx(struct bcm43xx_private *b
>  	}
> 
>  	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
> +	seq_ctl = le16_to_cpu(wlhdr->seq_ctl);
> +
> +	if ((frame_ctl == prev_frame) && (seq_ctl == prev_seq))
> +		return -EINVAL;
> +
> +	prev_frame = frame_ctl;
> +	prev_seq = seq_ctl;

> By dropping those packets with frame_ctl and seq_ctl the same as the values 
> in the previous packet, I was able to cut the number of TKIP replay 
> messages, but some still come through. Is this what you had in mind, or is 
> there somewhere else that I should be looking?

This is quite close to what I had in mind and is likely okay for
testing, but would not be generic enough to be something I would like to
see in the main kernel tree. See IEEE 802.11 clause 9.2.9 for the
details of what the receiver needs to do (mainly, the validation of
addr2 and per STA prev_seq is needed for AP and IBSS modes). In
addition, this should really be in the generic IEEE 802.11 code and
there are couple of optimizations which can be used when combining this
with defragmentation (see, e.g., net/d80211/ieee80211.c
ieee80211_rx_h_check).

Did the replay messages still show the same TSC/PN or did you get rid of
all messages that had the same number repeated?

-- 
Jouni Malinen                                            PGP id EFC895FA
