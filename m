From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] veth: don't modify ip-summed; doing so treats packets
 with bad checksums as good.
Date: Sat, 19 Dec 2015 13:01:27 -0800
Message-ID: <CAM_iQpVAZ=C68f1BGNEV=e-WGaJrvR-pzu_6kqCGnJLo8gw6Pg@mail.gmail.com>
References: <CAKoqxG=R566bG2sQzWabAaaoUZjUJfoVP7k7dcYK4QuEcH0jrA@mail.gmail.com>
	<CAM_iQpUOKGoNNDF2Nbut8a0q2rGY6pCXBm3NVkBMe=63K7L9bg@mail.gmail.com>
	<CAKUBDd-VfaBvdMDJE8_mH2vXKn-66PM_0i-ioJLm6yQgwbrE4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Eric Biederman <ebiederm@aristanetworks.com>,
	Tom Herbert <tom@herbertland.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33884 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbbLSVB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 16:01:27 -0500
In-Reply-To: <CAKUBDd-VfaBvdMDJE8_mH2vXKn-66PM_0i-ioJLm6yQgwbrE4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 11:42 AM, Vijay Pandurangan <vijayp@vijayp.ca> wrote:
> Evan and I have demonstrated this bug on Kubernetes as well, so it's
> not just a problem in Mesos. (See
> https://github.com/kubernetes/kubernetes/issues/18898)
>

Interesting... then this problem is much more serious than I thought.

Looks like in RX path the bridge sets the checksum to CHECKSUM_NONE
too:

static inline void skb_forward_csum(struct sk_buff *skb)
{
        /* Unfortunately we don't support this one.  Any brave souls? */
        if (skb->ip_summed == CHECKSUM_COMPLETE)
                skb->ip_summed = CHECKSUM_NONE;
}

I guess this is probably why Docker/Kubernetes could be affected too.
