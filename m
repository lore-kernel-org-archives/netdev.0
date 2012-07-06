From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH net-next] asix: avoid copies in tx path
Date: Fri, 6 Jul 2012 09:16:32 +0800
Message-ID: <CACVXFVOYgVG5cZE8YPn2z6_xu5akLvUURJ3_pE4Stbh7U8L_AA@mail.gmail.com>
References: <1341498661.2583.4162.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Allan Chou <allan@asix.com.tw>,
	Trond Wuellner <trond@chromium.org>,
	Grant Grundler <grundler@chromium.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34723 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab2GFBQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 21:16:35 -0400
Received: from mail-ob0-f174.google.com ([209.85.214.174])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1Smx9t-0003Kp-Dc
	for netdev@vger.kernel.org; Fri, 06 Jul 2012 01:16:33 +0000
Received: by obbuo13 with SMTP id uo13so14091456obb.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 18:16:32 -0700 (PDT)
In-Reply-To: <1341498661.2583.4162.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 5, 2012 at 10:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> I noticed excess calls to skb_copy_expand() or memmove() in asix driver.
>
> This driver needs to push 4 bytes in front of frame (packet_len)
> and maybe add 4 bytes after the end (if padlen is 4)
>
> So it should set needed_headroom & needed_tailroom to avoid
> copies. But its not enough, because many packets are cloned
> before entering asix_tx_fixup() and this driver use skb_cloned()
> as a lazy way to check if it can push and put additional bytes in frame.
>
> Avoid skb_copy_expand() expensive call, using following rules :
>
> - We are allowed to push 4 bytes in headroom if skb_header_cloned()
>   is false (and if we have 4 bytes of headroom)
>
> - We are allowed to put 4 bytes at tail if skb_cloned()
>   is false (and if we have 4 bytes of tailroom)
>
> TCP packets for example are cloned, but skb_header_release()
> was called in tcp stack, allowing us to use headroom for our needs.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Allan Chou <allan@asix.com.tw>
> Cc: Trond Wuellner <trond@chromium.org>
> Cc: Grant Grundler <grundler@chromium.org>
> Cc: Paul Stewart <pstew@chromium.org>
> Cc: Ming Lei <tom.leiming@gmail.com>

After testing the patch on beagle-xm with external DLINK DUB-E100 NIC,
the transmit performance is increased from ~75Mbps to ~91Mbps when
DEBUG_SLAB is enabled, follows the test command and result:

[root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
------------------------------------------------------------
Client connecting to 192.168.0.103, TCP port 5001
TCP window size:   256 KByte (WARNING: requested   128 KByte)
------------------------------------------------------------
[  3] local 192.168.0.102 port 57888 connected with 192.168.0.103 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec    109 MBytes  91.6 Mbits/sec

Tested-by: Ming Lei <ming.lei@canonical.com>

Thanks,
--
Ming Lei
