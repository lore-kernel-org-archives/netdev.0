From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Mon, 07 Jan 2013 08:17:23 -0800
Message-ID: <1357575443.6919.3105.camel@edumazet-glaptop>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
	 <55633610.20121219123427@eikelenboom.it>
	 <1355933869.21834.13.camel@edumazet-glaptop>
	 <1797374383.20121220135139@eikelenboom.it>
	 <1356017968.21834.2859.camel@edumazet-glaptop>
	 <1609010645.20121221122100@eikelenboom.it> <50D4AB87.8050601@hp.com>
	 <561084196.20130103214030@eikelenboom.it>
	 <1357566063.7989.68.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:35614 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab3AGQR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:17:27 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so10643804pbc.4
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 08:17:27 -0800 (PST)
In-Reply-To: <1357566063.7989.68.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 13:41 +0000, Ian Campbell wrote:

> > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
> >         Socket  Message  Elapsed      Messages
> >         Size    Size     Time         Okay Errors   Throughput
> >         bytes   bytes    secs            #      #   KBytes/sec
> > 
> > current 212992   65507   60.00      252586      0    269305.73
> > current   2280           60.00      229371           244553.96
> > patched 212992   65507   60.00      256209      0    273168.32
> > patched   2280           60.00      201670           215019.54
> 
> The recv numbers here aren't too pleasing either.

The number of packets that can be queued into UDP socket depends on
sk->sk_rcvbuf (SO_RCVBUF) and skb truesize.

So what we notice here are packet drops (netstat -s would give us the
total counters)

To absorb a burst of incoming messages, an application would have to set
an appropriate receive buffer.

In this case, RCVBUF value was set to a very minimum, basically not
allowing more than one queued packet.

TCP stack has a 'collapse' mode, which basically converts skbs in
receive queue (or ofo queue) to better filled ones (skb->len very close
to skb->truesize) when memory limits are about to be hit.

Its very expensive, as it adds one more copy stage, but it happens only
in rare circumstances. Of course, when a driver uses one page of 4096
bytes to store one 1514 bytes ethernet frame, it can happen more often.

netstat -s | grep collap
    25292 packets collapsed in receive queue due to low socket buffer
