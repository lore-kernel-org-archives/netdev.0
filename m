From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Wed, 5 Mar 2014 17:57:01 +0200
Message-ID: <5317494D.5010907@mellanox.com>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com> <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz> <530F0C4F.9030200@mellanox.com> <alpine.LNX.2.00.1402271123410.21399@pobox.suse.cz> <alpine.LNX.2.00.1403042348050.30402@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1403042348050.30402@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/2014 00:48, Jiri Kosina wrote:
> On Thu, 27 Feb 2014, Jiri Kosina wrote:
>
>> On Thu, 27 Feb 2014, Or Gerlitz wrote:
>>
>>> ipoib is coded over the verbs API (include/rdma/ib_verbs.h)  --- so tracking
>>> the path from ipoib through the verbs api into mlx4 should be similar exercise
>>> as doing so for mlx5, but let's 1st treat the higher level elements involved
>>> with this patch.
>>>
>>> Can you shed some light why the problem happens only for NFS, and not for
>>> example with other IP/TCP storage protocols?
>>>
>>> For example, do you expect it to happen with iSCSI/TCP too? the Linux
>>> iSCSI initiator 1st open a TCP socket from user space to the target,
>>> next they do login exchange over this socket and later provide the
>>> socket to the kernel iscsi code to use as the back-end of a SCSI block
>>> device registered with the SCSI midlayer
>> Frankly, no idea. There was a problem with swapping over NFS, as writeback
>> was deadlocked with memory reclaim (memory needs to be allocated so that
>> swap could be accessed to reclaim memory). That's fixed by allocating the
>> buffers from PF_MEMALLOC reserve, introduced by Mel's and Peter's patchset
>> back in 3.9 or so. Oh, and the same has been done for swapping over NBD,
>> btw. Maybe iSCSI needs similar treatment, maybe it has it already, I
>> haven't checked. We haven't seen a bugreport for that though.
>>
>>>> I don't think we have, and it indeed should be rather easy to add. The
>>>> more challenging part of the problem is where (and based on which
>>>> data) the flag would actually be set up on the netdevice so that it's
>>>> not horrible layering violation.
>>> I assume that in the same manner netdevices advertize features to the
>>> networking core, the core can provide them operating directives after
>>> they register themselves.
>> Whatever suits you best. To sum it up:
>>
>> - mlx4 is confirmed to have this problem, and we know how that problem
>>    happens -- see the paragraph in the changelog explaining the dependency
>>    between memory reclaim and allocation of TX ring
>>
>> - we have a work around which requires human interaction in order
>>    to provide the information whether GFP_NOFS should be used or not
>>
>> - I can very well understand why Mellanox would see that as a hack, but if
>>    more comprehensive fix is necessary, I'd expect those who understand
>>    the code the best to come up with a solution/proposal. I'd assume that
>>    you don't  want to keep the code with known and easily triggerable
>>    deadlock out there unfixed.
>>
>> - where I see the potential for layering violation in any 'general'
>>    solution is that it's the filesystem that has to be "talking" to the
>>    underlying netdevice, i.e. you'll have to make filesystem
>>    netdevice-aware, right?
> Mellanox folks, do you have any plan how to proceed here please?
>

Hi Jiri,

Yep, we will look on that. I think we still have few directions to 
resolve here

1. (our task) deeper understanding of the problem

2. if the solution goes in the way you took it, look for

2.1 a more generic verbs interface, e.g QP creation flag  that dictates 
the GFP_YYY to use when allocating memory
for that QP, e.g NOIO, NOFS, ATOMIC, etc

2.2 a more programmable interface for the file-system to let the NIC 
know they are under constraint YYY for their memory
allocations, maybe per nieghbour? maybe use netdevice private flags?

Or.
