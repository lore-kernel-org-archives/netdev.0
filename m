From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 03 Aug 2016 14:43:43 +0200
Message-ID: <1882749.mb7lsAROoU@debian64>
References: <201608030349.u733nRPn000595@sdf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Al Viro <viro@zeniv.linux.org.uk>, alexmcwhirter@triadic.us,
	David Miller <davem@davemloft.net>, chunkeey@googlemail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Curry <rlwinm@sdf.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201608030349.u733nRPn000595@sdf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 3, 2016 3:49:26 AM CEST Alan Curry wrote:
> Al Viro wrote:
> > 
> > Which just might mean that we have *three* issues here -
> > 	(1) buggered __copy_to_user_inatomic() (and friends) on some sparcs
> > 	(2) your ssl-only corruption
> > 	(3) Alan's x86_64 corruption on plain TCP read - no ssl *or* sparc
> > anywhere, and no multi-segment recvmsg().  Which would strongly argue in
> > favour of some kind of copy_page_to_iter() breakage triggered when handling
> > a fragmented skb, as in (1).  Except that I don't see anything similar in
> > x86_64 uaccess primitives...
> > 
> 
> I think I've solved (3) at least...
> 
> Using the twin weapons of printk and stubbornness, I have built a working
> theory of the bug. I haven't traced it all the way through, so my explanation
> may be partly wrong. I do have a patch that eliminates the symptom in all my
> tests though. Here's what happens:
> 
> A corrupted packet somehow arrives in skb_copy_and_csum_datagram_msg().
> During downloads at reasonably high speed, about 0.1% of my incoming
> packets are bad. Probably because the access point is that suspicious
> Comcast thing.

Thanks for being very persistent with this. I think I'm able to reproduce
this now (on any hardware... like r8169 ethernet) as long as the following 
"traffic policy" is enacted on the HTTP - Server: 

# tc qdisc add dev eth0 root netem corrupt 0.1%

(This needs the "Network Emulation" Sched CONFIG_NET_SCH_NETEM [0].)

With your tool (changed to point to my apache local server). I'm seeing 
corruptions in the "noselect" case. Running it in "select" mode however
and the resulting files have no corruptions.

About AR9170 corruption issues: I know of one report that the AR9170's
Encryption Engine can cause corruptions [1]. In this case outgoing
data was corrupted which lead to deauths/disassocs since the AP was
basically sending out multicast deauths/disassocs with bad addresses.
However, "nohwcrypt" should have made a difference there since the
software decryption would discard the faulty package due the message
integrety checks.

Another source for corruptions could be the USB-PHY (FUSB200) in the
AR9170 [2]. I know it's causing problems for the ath9k_htc. However
not everyone is affected.

One thing I noticed in your previous post is that you "might" not have
draft-802.11n enabled. Do you see any "disabling HT/VHT due to WEP/TKIP use."
in your dmesg logs? If so, check if you can force your AP to use WPA2
with CCMP/AES only.

Regards,
Christian

[0] <http://www.spinics.net/lists/linux-wireless/msg60104.html>
[1] <https://wiki.linuxfoundation.org/networking/netem>
[2] <https://github.com/qca/open-ath9k-htc-firmware/wiki/usb-related-issues>
