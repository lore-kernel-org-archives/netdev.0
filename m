From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: smsc75xx & smsc95xx, setting skb->truesize correctly?
Date: Wed, 22 Aug 2012 08:34:46 +0200
Message-ID: <1345617286.5158.576.camel@edumazet-glaptop>
References: <20120820175706.12394vktsvm3yvqc@www.81.fi>
	 <1345542398.5158.446.camel@edumazet-glaptop>
	 <20120822083549.57260n3jdqfgxtj4@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51256 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab2HVGex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 02:34:53 -0400
Received: by bkwj10 with SMTP id j10so164272bkw.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 23:34:52 -0700 (PDT)
In-Reply-To: <20120822083549.57260n3jdqfgxtj4@www.81.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 08:35 +0300, Jussi Kivilinna wrote:
> Quoting Eric Dumazet <eric.dumazet@gmail.com>:
> 
> > On Mon, 2012-08-20 at 17:57 +0300, Jussi Kivilinna wrote:
> >> Hello,
> >>
> >> Is setting skb->truesize in smsc75xx and smsc95xx correct?
> >> In smsc75xx/smsc95xx_rx_fixup(), input skb containing multiple packets
> >> is cloned and truesize for each clone is set to packet-size +
> >> sizeof(struct sk_buff), but input skb has minimum allocation size of
> >> 9000 bytes (MAX_SINGLE_PACKET_SIZE) and maximum of 18944 bytes
> >> (DEFAULT_HS_BURST_CAP_SIZE) (+ NET_IP_ALIGN). Doesn't this cause
> >> truesize to be underestimated?
> >
> > This has been discussed in a "TCP transmit performance regression"
> > thread some weeks ago.
> >
> > More generally, skb_clone() is not a good idea in rx path.
> 
> So all skb_clone use in drivers/net/usb/ should be removed/replaced  
> with following?

Doing a copy might be expensive on some low end hardware, so I can
understand why this skb_clone() idea was deployed years ago.

Gigabit r8169 has to perform the copy because of security issue, and so
far nobody complained of performance impact.

Best thing would be to not use large buffers from the beginning,
and switch to a frag idea.

(A large frame would needs 2 or 3 medium buffers, as done in ath9k)

Check https://gerrit.chromium.org/gerrit/#/c/18412/ 
and commit 0d95521ea74735826cb2e28bebf6a07392c75bfa (ath9k: use split rx
buffers to get rid of order-1 skb allocations)
