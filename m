From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Fri, 24 Dec 2004 17:10:38 +0100
Message-ID: <5cac192f04122408102129af43@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca,
	"David S. Miller" <davem@davemloft.net>, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41CAF444.3000305@trash.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Dec 2004 17:37:24 +0100, Patrick McHardy <kaber@trash.net> wrote:
> Eric Lemoine wrote:
> > I still have one concern with the LLTX code (and it may be that the
> > correct patch is Jamal's) :
> >
> > Without LLTX we do : lock(queue_lock), lock(xmit_lock),
> > release(queue_lock), release(xmit_lock). With LLTX (without Jamal's
> > patch) we do : lock(queue_lock), release(queue_lock), lock(tx_lock),
> > release(tx_lock). LLTX doesn't look correct because it creates a race
> > condition window between the the two lock-protected sections. So you
> > may want to reconsider Jamal's patch or pull out LLTX...
> 
> You're right, it can cause packet reordering if something like this
> happens:
> 
> CPU1                    CPU2
> lock(queue_lock)
> dequeue
> unlock(queue_lock)
>                         lock(queue_lock)
>                         dequeue
>                         unlock(queue_lock)
>                         lock(xmit_lock)
>                         hard_start_xmit
>                         unlock(xmit_lock)
> lock(xmit_lock)
> hard_start_xmit
> unlock(xmit_lock)
> 
> Jamal's patch should fix this.

Yes but requiring drivers to release a lock that they should not even
be aware of doesn't sound good. Another way would be to keep
dev->queue_lock grabbed when entering start_xmit() and let the driver
drop it (and re-acquire it before it returns) only if it wishes so.
Although I don't like this too much either, that's the best way I can
think of up to now...

-- 
Eric
