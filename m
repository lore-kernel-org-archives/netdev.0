From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: use-after-free in sixpack_close
Date: Thu, 17 Dec 2015 23:47:39 +0000
Message-ID: <20151217234739.651e7c5b@lxorguk.ukuu.org.uk>
References: <CACT4Y+YfPHHON7VywV_G-qOyQ0wv6UVB0uxFAGf1aGKpfAP-KA@mail.gmail.com>
	<20151217114104.6946d72b@lxorguk.ukuu.org.uk>
	<20151217.160532.999129498473749695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ajk@comnets.uni-bremen.de,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	jslaby@suse.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151217.160532.999129498473749695.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Dec 2015 16:05:32 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> Date: Thu, 17 Dec 2015 11:41:04 +0000
> 
> >> This report is then followed by a dozen of other use-after-free reports.
> >> 
> >> On commit edb42dc7bc0da0125ceacab810a553ce1f0cac8d (Dec 15).
> >> 
> >> Thank you
> > 
> > sixpack_close does unregister_netdev(sp->dev), which frees sp as sp is
> > actually allocated via alloc_netdev()
> > 
> > Then deletes two timers within sp
> > 
> > Then frees two buffers indexed off sp
> 
> This should fix it, the only thing I'm unsure of is if we should perhaps
> also use del_timer_sync() here.  Anyone?

I think you need to yes as the timers use the data you wil be freeing in
the unregister.

Also you are at the point the tty is closing so the net device may be
active. Don't you need to netif_stop_queue() or defer the buffer
kfrees until after the network device is unregistered so you don't pee
into free memory if you have a transmit occurring ?

Alan
