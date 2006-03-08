From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 07 Mar 2006 17:17:30 -0800
Message-ID: <adaacc1raz9.fsf@cisco.com>
References: <1141767891.6119.903.camel@localhost>
	<20060307134907.733d3d27@localhost.localdomain>
	<1141776697.6119.938.camel@localhost>
	<20060307.161808.60227862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org, shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060307.161808.60227862.davem@davemloft.net> (David S. Miller's
	message of "Tue, 07 Mar 2006 16:18:08 -0800 (PST)")
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

    David> How limited are the IPoIB devices, TX descriptor wise?

    David> One side effect of the TSO changes is that one extra
    David> descriptor will be used for outgoing packets.  This is
    David> because we have to put the headers as well as the user
    David> data, into page based buffers now.

We have essentially no limit on TX descriptors.  However I think
there's some confusion about TSO: IPoIB does _not_ do TSO -- generic
InfiniBand hardware does not have any TSO capability.  In the future
we might be able to implement TSO for certain hardware that does have
support, but even that requires some firmware help from the from the
HCA vendors, etc.  So right now the IPoIB driver does not do TSO.

The reason TSO comes up is that reverting the patch described below
helps (or helped at some point at least) IPoIB throughput quite a bit.
Clearly this was a bug fix so we can't revert it in general but I
think what Michael Tsirkin was suggesting at the beginning of this
thread is to do what the last paragraph of the changelog says -- find
some way to re-enable the trick.

diff-tree 3143241... (from e16fa6b...)
Author: David S. Miller <davem@davemloft.net>
Date:   Mon May 23 12:03:06 2005 -0700

    [TCP]: Fix stretch ACK performance killer when doing ucopy.

    When we are doing ucopy, we try to defer the ACK generation to
    cleanup_rbuf().  This works most of the time very well, but if the
    ucopy prequeue is large, this ACKing behavior kills performance.

    With TSO, it is possible to fill the prequeue so large that by the
    time the ACK is sent and gets back to the sender, most of the window
    has emptied of data and performance suffers significantly.

    This behavior does help in some cases, so we should think about
    re-enabling this trick in the future, using some kind of limit in
    order to avoid the bug case.

 - R.
