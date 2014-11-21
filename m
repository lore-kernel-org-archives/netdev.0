From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Thu, 20 Nov 2014 20:17:54 -0800
Message-ID: <1416543474.27917.51.camel@haakon3.risingtidesystems.com>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
	 <20141119.161744.1661940121298888832.davem@davemloft.net>
	 <20141119213006.GE7996@ZenIV.linux.org.uk>
	 <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141120214753.GR7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al & Co,

On Thu, 2014-11-20 at 21:47 +0000, Al Viro wrote:
> On Wed, Nov 19, 2014 at 04:53:40PM -0500, David Miller wrote:
> 
> > Pulled, thanks Al.
> 
> Umm...  Not in net-next.git#master...  Anyway, the next portion is in
> vfs.git#iov_iter-net right now; I'll post it on netdev once I get some
> sleep.
> 

Thanks for your detailed analysis + work on this.

> It's getting close to really interesting parts.  Right now the main obstacle
> is in iscsit_do_rx_data/iscsit_do_tx_data; what happens there is reuse of
> iovec if kernel_sendmsg() gives a short write - it tries to send again, with
> the same iovec and decremented length.  Ditto on RX side (with kernel_recvmsg(),
> obviously).
> 
> As far as I can see, these retries on the send side are simply broken -
> normally we are talking to TCP sockets there and tcp_sendmsg() does *not*
> modify iovec in normal case.  IOW, if you get 8K sent out of 80K, the next
> time it'll try to send 72K - already sent piece + 64K following it, etc.
> 

AFAIK, short writes have not been actively getting triggered.

This is likely due to iscsit_do_tx_data() being used for sending 48 byte
PDU header, and small payloads in ISCSI_OP_LOGIN_RSP, ISCSI_OP_TEXT_RSP,
and ISCSI_OP_NOOP_IN control PDUs. 

All bulk data READ payloads are sent via iscsit_fe_sendpage_sg() and
only use iscsit_do_tx_data() for leading PDU header.

On the receive side, kernel_recvmsg() is called with MSG_WAITALL that
has been masking this bug..

> Could target-devel folks tell how realistic those resends are, in the
> first place?  Both with TX and RX sides...  Is there any sane limit on
> iovec size there, etc.
> 

Of the three control type PDU using this codepath, the transfer lengths
are currently limited to <= 32K + header across 2 kvecs.  The simplest
fix would probably be to fail the connection when send/recv returns a
value other than requested transfer length for these special cases.

For correctly handling short writes with your new work, what's the
preferred way to do this..?

--nab
