From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netconsole: queue console messages to send later
Date: Mon, 07 Jun 2010 15:21:31 -0500
Message-ID: <1275942091.26597.85.camel@calx>
References: <24059.1275417767@death.nxdomain.ibm.com>
	 <1275938692-26997-1-git-send-email-fleitner@redhat.com>
	 <1275940248.26597.70.camel@calx>  <20100607130015.15555744@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fleitner@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Flavio Leitner <fbl@sysclose.org>,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100607130015.15555744@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-06-07 at 13:00 -0700, Stephen Hemminger wrote:
> On Mon, 07 Jun 2010 14:50:48 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > On Mon, 2010-06-07 at 16:24 -0300, Flavio Leitner wrote:
> > > There are some networking drivers that hold a lock in the
> > > transmit path. Therefore, if a console message is printed
> > > after that, netconsole will push it through the transmit path,
> > > resulting in a deadlock.
> > 
> > This is an ongoing pain we've known about since before introducing the
> > netpoll code to the tree.
> > 
> > My take has always been that any form of queueing is contrary to the
> > goal of netpoll: timely delivery of messages even during machine-killing
> > situations like oopses. There may never be a second chance to deliver
> > the message as the machine may be locked solid. And there may be no
> > other way to get the message out of the box in such situations. Adding
> > queueing is a throwing-the-baby-out-with-the-bathwater fix.
> > 
> > I think Dave agrees with me here, and I believe he's said in the past
> > that drivers trying to print messages in such contexts should be
> > considered buggy.
> > 
> 
> Because it to hard to fix all possible device configurations.
> There should be any way to detect recursion and just drop the message to
> avoid deadlock.

Open to suggestions. The locks in question are driver-internal. There
also may not be any actual recursion taking place:

driver path a takes private lock x
driver path a attempts printk
printk calls into netconsole
netconsole calls into driver path b
driver path b attempts to take lock x -> deadlock

So we can't even try to walk back the stack looking for such nonsense.
Though we could perhaps force queuing of all messages -from- the driver
bound to netconsole. Tricky, and not quite foolproof.

-- 
Mathematics is the supreme nostalgia of our time.
