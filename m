From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 02 Oct 2015 14:32:40 -0700
Message-ID: <1443821560.32531.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443650383.13282.10.camel@daevel.fr>
	 <560D1223.3070606@googlemail.com>
	 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
	 <560D1C5A.3050508@googlemail.com>
	 <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
	 <alpine.DEB.2.11.1510022200130.4500@nanos>
	 <1443819583.32531.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.11.1510022302430.4500@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Holger =?ISO-8859-1?Q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1510022302430.4500@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-10-02 at 23:04 +0200, Thomas Gleixner wrote:
> On Fri, 2 Oct 2015, Eric Dumazet wrote:
> > On Fri, 2015-10-02 at 22:04 +0200, Thomas Gleixner wrote:
> > 
> > > What makes sure, that the timer cannot be readded while that timer
> > > callback is running?
> > 
> > What is exactly your question ?
> 
> CPU0   	  	       		CPU1
> 
> timer expires
>   callback
> 				add timer
>   timer_pending() == true
>   ===> del_timer_sync()
> 
> I was just curious how this is prevented as I got lost in the
> networking code as usual :)

Sure ;)

I believe this can not happen for following reasons :

mod_timer_pinned() is used only when req is created, while timer cannot
possibly be running on the same req. The _pinned part is critical
because we set the req->refcnt _after_ starting the timer,
to avoid being visible and caught from rcu lookups in hash tables.

Then, timer might be modified only by mod_timer_pending() from
tcp_check_req() : This should not re-start timer if another cpu is in
the timer callback.

Thanks
