From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Thu, 7 Jan 2010 02:34:51 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001070231540.26362@melkinpaasi.cs.helsinki.fi>
References: <20100105.163911.10233438.davem@davemloft.net> <20100106.002328.141253811.davem@davemloft.net> <20100106.150453.186399201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34549 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab0AGAex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 19:34:53 -0500
In-Reply-To: <20100106.150453.186399201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jan 2010, David Miller wrote:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 06 Jan 2010 00:23:28 -0800 (PST)
> 
> > Special casing the seq == end_seq == tp->rcv_wup case using
> > something like:
> > 
> > 		(after(end_seq, tp->rcv_wup) ||
> > 		 (end_seq == tp->rcv_wup && seq == end_seq)) &&
> > 
> > might work, but I'm not confident that's exactly what we want at the
> > moment, as it partially defeats what this code is trying to do (let us
> > accept URG/FIN/RST after seq and end_seq are truncated to the window).
> 
> I did some more research and everything I've said here turns
> out to be moot.
> 
> We should be ACK'ing these things anyways.  Here is why:
> 
> 1) if tcp_sequence() accepts the sequence we continue on in
>    tcp_established()
> 
> 2) We make it to tcp_data_queue() unless tcp_ack() finds that the
>    ACK sequence is invalid (it covers data we never sent).
> 
> 3) tcp_data_queue() should make it to, and hit, this conditional:
> 
> 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
> 
>    which will schedule an ACK the same exact way we would if
>    tcp_sequence() rejected the sequence range.
> 
> So it's a mystery why we aren't responding to Windows 2000's
> BSD 4.2 style zero window probes.
> 
> Can someone please validate my analysis?

In 3) I don't see why we'd hit that one as peer's snd_una+1 would be 
larger than rcv_nxt.


-- 
 i.
