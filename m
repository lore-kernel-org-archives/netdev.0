From: "David S. Miller" <davem@redhat.com>
Subject: Re: NAPI note
Date: Tue, 18 Feb 2003 19:18:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218.191841.132918432.davem@redhat.com>
References: <20030217.185719.28797590.davem@redhat.com>
	<3E525FD8.1060009@colorfullife.com>
	<20030218212441.M25195@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, zaitcev@redhat.com,
   jbourne@mtroyal.ab.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <20030218212441.M25195@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: Tue, 18 Feb 2003 21:53:12 -0500 (EST)
   
   Theres other drivers which dont follow this rule and just shutdown
   all interupt sources. I know that the e1000 for example does this.
   I am not sure about the tg3. I think the doc says this but may not
   emphasize it as strongly.
   So if tg3 uses method 2 then its as Dave says - a bug.
   
Right, but I forgot that it's not a bug in the shared interrupt
case where we need to grab a lock to access the hardware and
fetch the interrupt status.

   Shared interupts should be interesting actually.
   However if you are in poll mode and you receive an interupt you should be
   able to quickly determine its not yours without much effect on shared
   locks, no?

As Jeff has responded already, often you do need locks to do this
sanely.

In tg3, it's really complicated even though the chip writes the
interrupt status to a piece of memory shared with the cpu.

Any time you want to enable/disable tg3 chip interrupts you must
flip and/or check a status bit in this piece of memory.  So it
really needs a lock.

I personally think Jeff is overly optimistic about lock removal in
the driver.  :-)  The last time I attempted to be clever here, we
ended up with all sorts of deadlocks in tg3.  It requires real brain
time and heavy testing to make any kinds of changes in this area.
I also don't want to accomplish this by splitting up into seperate
lines of development of tg3, that's nuts as it would split up our
testing and make both lines get less testing than a unified mainline
driver would (which is what we happily do now).
