From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: use-after-free in sixpack_close
Date: Fri, 18 Dec 2015 22:02:04 +0000
Message-ID: <20151218220204.6faf8e93@lxorguk.ukuu.org.uk>
References: <20151217114104.6946d72b@lxorguk.ukuu.org.uk>
	<20151217.160532.999129498473749695.davem@davemloft.net>
	<20151217234739.651e7c5b@lxorguk.ukuu.org.uk>
	<20151218.155954.26632223306803039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ajk@comnets.uni-bremen.de,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	jslaby@suse.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20151218.155954.26632223306803039.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Also you are at the point the tty is closing so the net device may be
> > active. Don't you need to netif_stop_queue() or defer the buffer
> > kfrees until after the network device is unregistered so you don't pee
> > into free memory if you have a transmit occurring ?
> 
> I'm pretty sure that's what the semaphore down above this sequence is
> accomplishing.  But if we do need the netif_stop_queue() let's do that
> as a separate patch.

Follow the code path for sp_xmit(). If sp_xmit is called it digs out sp
from the ndetdev, locks sp->lock and stops the queue then calls sp_encaps
which touches sp->xbuff.

So if one thread of execution hits sp_xmit and another closes the ldisc
at just the wrong moment then we have no protection.

Alan
