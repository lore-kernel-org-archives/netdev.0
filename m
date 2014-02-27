From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Thu, 27 Feb 2014 11:58:39 +0200
Message-ID: <530F0C4F.9030200@mellanox.com>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com> <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>, Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/02/2014 11:48, Jiri Kosina wrote:
> On Wed, 26 Feb 2014, Or Gerlitz wrote:
>
>>> But let's make sure that we don't diverge from the original problem too
>>> much. Simple fact is that the deadlock is there when using connected mode,
>>> and there is nothing preventing users from using it this way, therefore I
>>> believe it should be fixed one way or another.
>> the patch is titled with "mlx4:" -- do you expect the problem to come
>> into play only when ipoib connected mode runs over the mlx4 driver?
>> what's about mlx5 or other upstream IB drivers?
> Honestly, I have no idea. I am pretty sure that Mellanox folks have much
> better understanding of the mlx* driver internals than I do. I tried to
> figure out where mlx5 is standing in this respect, but I don't even see
> where ipoib_cm_tx->tx_ring is being allocated there.

ipoib is coded over the verbs API (include/rdma/ib_verbs.h)  --- so 
tracking the path from ipoib through the verbs api into mlx4 should be 
similar exercise as doing so for mlx5, but let's 1st treat the higher 
level elements involved with this patch.

Can you shed some light why the problem happens only for NFS, and not 
for example with other IP/TCP storage protocols?

For example, do you expect it to happen with iSCSI/TCP too? the Linux 
iSCSI initiator 1st open a TCP socket from user space to the target, 
next they do login exchange over this socket and later provide the 
socket to the kernel iscsi code to use as the back-end of  a SCSI block 
device registered with the SCSI midlayer


>
>> I'll be looking on the details of the problem/solution,
> Awesome, thanks a lot, that's highly appreciated.
>
>> Do we have a way to tell a net-device instance they should do their
>> memory allocations in a NOFS manner? if not, shouldn't we come up with
>> more general injection method?
> I don't think we have, and it indeed should be rather easy to add. The
> more challenging part of the problem is where (and based on which data)
> the flag would actually be set up on the netdevice so that it's not
> horrible layering violation.
>

I assume that in the same manner netdevices advertize features to the 
networking core, the core can provide them
operating directives after they register themselves.
