From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 14:27:50 -0700
Message-ID: <ada3al8k3l5.fsf@cisco.com>
References: <48A08145.6060703@hp.com>
	<20080811.141254.165409473.davem@davemloft.net>
	<adad4kfxm9v.fsf@cisco.com>
	<20080811.145313.178992274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, jgarzik@pobox.com, swise@opengridcomputing.com,
	divy@chelsio.com, kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080811.145313.178992274.davem@davemloft.net> (David Miller's
	message of "Mon, 11 Aug 2008 14:53:13 -0700 (PDT)")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > How can you place iSCSI data properly with only stateless offloads?

 > By teaching the stateless offload how to parse the iSCSI headers
 > on the flow and place the data into pages at the correct offsets
 > such that you can place the pages hanging off of the SKB directly
 > into the page cache.

I don't see how this could work.  First, it seems that you have to let
the adapter know which connections are iSCSI connections so that it
knows when to try and parse iSCSI headers.  So you're already not
totally stateless.  Then, since (AFAIK -- I'm not an expert on iSCSI and
especially I'm not an expert on what common practice is for current
implementations) the iSCSI PDUs can start at any offset in the TCP
stream, I don't see how a stateless adapter can even find the PDU
headers to parse -- there's not any way that I know of to recognize
where a PDU boundary is without keeping track of the lengths of all the
PDUs that go by (ie you need per-connection state).

Even if the adapter could find the PDUs, I don't see how it could come
up with the correct offset to place the data -- PDUs with response data
just carry an opaque tag assigned by the iSCSI initiator.  Finally, if
there are ways around all of those difficulties, we would still have to
do major surgery to our block layer to cope with read requests that
complete into random pages, rather than using a scatter list passed into
the low-level driver.


But I think all this argument is missing the point anyway.  The real
issue is not hand-waving about what someone might build someday, but how
we want to support iSCSI offload with the existing Chelsio, Broadcom,
etc adapters.  The answer might be, "we don't," but I disagree with that
choice because:

 a. "No upstream support" really ends up being "enterprise distros and
    customers end up using hacky out-of-tree drivers and blaming us."

 b. It sends a bad message to vendors who put a lot of effort into
    writing a clean, mergable driver and responding to review if the
    answer is, "Sorry, your hardware is wrong so no driver for you."

Maybe the answer is that we just add the iSCSI HBA drivers with no help
from the networking stack, and ignore the port collision problem.  For
iSCSI initiators, it's really not an issue: for a 4-tuple to collide,
someone would have to use both offloaded and non-offloaded connections
to the same target and be unlucky in the source port chosen.  It would
be nice to be able to discuss solutions to port collisions, but it may
be that this is too emotional an issue for that to be possible.

 - R.
