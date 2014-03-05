From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket buffer is large enough
Date: Wed, 05 Mar 2014 10:06:23 -0800
Message-ID: <87wqg8zfj4.fsf@xmission.com>
References: <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<87mwh5d1tf.fsf@xmission.com>
	<20140304.192152.1234652192226780071.davem@davemloft.net>
	<7457128.6VP2v68V93@x2>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-audit@redhat.com, David Miller <davem@davemloft.net>,
	rgb@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: Steve Grubb <sgrubb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7457128.6VP2v68V93@x2> (Steve Grubb's message of "Wed, 05 Mar
	2014 11:59:01 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Grubb <sgrubb@redhat.com> writes:

> On Tuesday, March 04, 2014 07:21:52 PM David Miller wrote:
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Tue, 04 Mar 2014 14:41:16 -0800
>> 
>> > If we really want the ability to always appened to the queue of skb's
>> > is to just have a version of netlink_send_skb that ignores the queued
>> > limits.  Of course an evil program then could force the generation of
>> > enough audit records to DOS the kernel, but we seem to be in that
>> > situation now.  Shrug.
>> 
>> There is never a valid reason to bypass the socket limits.
>> 
>> It protects the system from things going out of control.
>> 
>> Netlink packet sends can fail, and audit should cope with that
>> event instead of trying to bludgeon it into not happening.
>
> I am not sure what exactly is the problem with the code that was being 
> patched. The audit code has been stable and working pretty well for everyone 
> for the last 5-6 years. But lately there has been a lot of kernel code churn 
> and I am concerned that the changes are being made without a complete 
> understanding of the design goals.

The problem is that the audit code in the kernel is not using netlink
correctly and which leads to mistakes when the code is updated because
the code in the kernel is unnecessarily complex, and inefficient.

> The audit system has to be very reliable. It can't lose any event or record. 
> The people that really depend on it would rather have access denied to the 
> system than lose any event. This is the reason it goes to such
> lengths.

But the designers of the code didn't really go to any lengths at all.
There are enormous and cumbersome hacks to avoid fixing the kernel
interfaces to do what audit wants to use the kernel interfaces for.
That is the audit code for transmitting replies is stupid and is causing
serious maintenance issues, by growing hacks upon hacks instead of
dealing with the core issues.

The first approximation of what you want should have been be to set the
netlink socket recvbuf to as large as the can be:
setsockopt(sk, SOL_SOCKET, SO_RCVBUFFORCE, INTMAX);

If/when 2GiB is shown to be not enough people should should have worked
on the netlink layer to allow even larger piles of audit messages to be
in flight, assuming you really do want to bring down the system when the
audit client is just too slow.

> If I understand the patch, it looks like its affecting code that adds, deletes, 
> or lists audit rules. This code is quite old and working well. It didn't at 
> first. We found a lot of problems by writing scripts like:

Working well does not mean implemented well, and for a security feature
not implemented well means broken.  And frankly since I can't see a
single setsockopt to set the received buffer size for audit netlink
sockets I have to stronlgy suspect that people were working around
userpsace bugs with stupid kernel code.

> #!/bin/bash
> while [ 1 ] ;
> do
>         echo "Inserting syscalls..."
>         sys=1
>         while [ $sys -lt 100 ]
>         do
>                 sys=`expr $sys + 1`
>                 echo "$sys"
>                 auditctl -a entry,always -S $sys
>         done
>
>         echo "Listing..."
>         auditctl -l
>         echo "Deleting..."
>         auditctl -D
> done
>
> with another shell running:
>
> #!/bin/bash
> while [ 1 ] ; 
> do
> 	echo "Listing..."
> 	auditctl -l
> done
>
> and another shell running:
>
> #!/bin/bash
> while [ 1 ] ; 
> do
> 	echo "Disabling..."
> 	auditctl -e 0
> 	echo "Enabling..."
> 	auditctl -e 1
> done
>
> You can probably imagine more stress tests. But the proposed code should be 
> well tested similar to this.

Honestly since no one cares enough to maintain the kernel code properly
I really think we should just rip audit out instead trying to present
userspace with the delusion that the code works, and will continue to
work properly.

My apologies for being grumpy.  I have no intention of breaking
userspace (which is why my last patch was an rfc) but at the same time
I care absolutely nothing about audit.  It solves none of my problems
and works at all of the wrong layers to be interesting for me.

I just happened to notice that the code has been broken since 3.14-rc1
and no one understands or cares enough about audit to even accept
trivial kernel patches to fix the bugs.  No offense but I am not
interested in testing code I care nothing about, especially when there
is no one to pick up the patches.  My RFC patch was supposed to be a
word to the wise.

Eric
