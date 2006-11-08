From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Wed, 8 Nov 2006 13:09:33 +0100
Message-ID: <20061108130933.7284558a@griffin.suse.cz>
References: <1162741174.24574.22.camel@johannes.berg>
	<20061106210145.6824bec6@griffin.suse.cz>
	<1162854394.1412.40.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30607 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1754553AbWKHMJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 07:09:36 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162854394.1412.40.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Nov 2006 00:06:34 +0100, Johannes Berg wrote:
> Keeping with the protocol theme, we need to rewrite the rx path to do
> the following in the order listed:
> 
>  1) if any monitor interfaces are up, copy the skb, add the
>     prism/radiotap/whatever header and then clone it to all monitor
>     interfaces (don't actually copy for each as we do now)
>  2) if it is a unicast frame, determine which interface the frame should
>     go to now, it can't be going to more than one afaik
>  2) decrypt the frame
>  3) defragment the frame
>  4) send the frame off to each sub_if that might care about it
>  5) do further device specific processing

Multicast and broadcast frames complicates this a bit but other than
that you're right. See below.

> If we're careful, we can probably get away with a lot less copying than
> we do now by pushing the copying down into those handlers that really
> need different data.

Correct.

> This would probably only be the crypto handlers,
> the others can live with just pskb_copy instead.

Unfortunately, in case of broadcast and multicast frames, we probably
need to go through decryption handlers for each interface individually.
At least I wasn't able to find a solution which allows to perform
decryption only once for each frame. But theoretically it should be
possible but I'm afraid it would be less effective than the current
situation in the end. Unfortunately, when you perform decryption in
each interface separately, you are tended to perform defragmentation
separately as well. This is something that could be possibly improved.

> Then again, we don't
> handle non-linear skbs anyway. Actually, we should be calling
> skb_linearize at least, no?
> 
> And if the frame is not encrypted at all, then we can even save the
> skb_copy for the monitor and just use skb_clone and later pskb_copy...

 Jiri

-- 
Jiri Benc
SUSE Labs
