From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: 1.03Mpps on e1000 (was: Re: Transmission limit)
Date: Sun, 05 Dec 2004 17:23:25 -0800
Message-ID: <1102296205.3343.206.camel@sfeldma-mobl.dsl-verizon.net>
References: <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	 <20041201182943.GA14470@xi.wantstofly.org>
	 <20041201213550.GF14470@xi.wantstofly.org>
	 <1101967983.4782.9.camel@localhost.localdomain>
	 <20041205145051.GA647@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
	 <1102281141.3343.138.camel@sfeldma-mobl.dsl-verizon.net>
	 <20041205212559.GA4338@xi.wantstofly.org>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Martin Josefsson <gandalf@wlug.westbo.se>,
	jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
	P@draigBrady.com, mellia@prezzemolo.polito.it,
	e1000-devel@lists.sourceforge.net,
	Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
	Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041205212559.GA4338@xi.wantstofly.org>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 13:25, Lennert Buytenhek wrote:
> What your patch does is (correct me if I'm wrong):
> - Masking TXDW, effectively preventing it from delivering TXdone ints.
> - Not setting E1000_TXD_CMD_IDE in the TXD command field, which causes
>   the chip to 'ignore the TIDV' register, which is the 'TX Interrupt
>   Delay Value'.  What exactly does this?

A descriptor with IDE, when written back, starts the Tx delay timers
countdown.  Never setting IDE means the Tx delay timers never expire.

> - Not setting the "Report Packet Sent"/"Report Status" bits in the TXD
>   command field.  Is this the equivalent of the TXdone interrupt?
> 
> Just exactly which bit avoids the descriptor writeback?

As the name implies, Report Status (RS) instructs the controller to
indicate the status of the descriptor by doing a write-back (DMA) to the
descriptor memory.  The only status we care about is the "done"
indicator.  By reading TDH (Tx head), we can figure out where hardware
is without reading the status of each descriptor.  Since we don't need
status, we can turn off RS.

> I'm also a bit worried that only freeing packets 1ms later will mess up
> socket accounting and such.  Any ideas on that?

Well the timer solution is less than ideal, and any protocols that are
sensitive to getting Tx resources returned by the driver as quickly as
possible are not going to be happy.  I don't know if 1ms is quick enough.

You could eliminate the timer by doing the cleanup first thing in
xmit_frame, but then you have two problems: 1) you might end up reading
TDH for each send, and that's going to be expensive; 2) calls to
xmit_frame might stop, leaving uncleaned work until xmit_frame is called
again.

-scott



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
