From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
	buffer is large enough
Date: Wed, 05 Mar 2014 11:59:01 -0500
Message-ID: <7457128.6VP2v68V93@x2>
References: <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<87mwh5d1tf.fsf@xmission.com>
	<20140304.192152.1234652192226780071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rgb@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ebiederm@xmission.com, akpm@linux-foundation.org,
        David Miller <davem@davemloft.net>
To: linux-audit@redhat.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20140304.192152.1234652192226780071.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Tuesday, March 04, 2014 07:21:52 PM David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 04 Mar 2014 14:41:16 -0800
> 
> > If we really want the ability to always appened to the queue of skb's
> > is to just have a version of netlink_send_skb that ignores the queued
> > limits.  Of course an evil program then could force the generation of
> > enough audit records to DOS the kernel, but we seem to be in that
> > situation now.  Shrug.
> 
> There is never a valid reason to bypass the socket limits.
> 
> It protects the system from things going out of control.
> 
> Netlink packet sends can fail, and audit should cope with that
> event instead of trying to bludgeon it into not happening.

I am not sure what exactly is the problem with the code that was being 
patched. The audit code has been stable and working pretty well for everyone 
for the last 5-6 years. But lately there has been a lot of kernel code churn 
and I am concerned that the changes are being made without a complete 
understanding of the design goals.

The audit system has to be very reliable. It can't lose any event or record. 
The people that really depend on it would rather have access denied to the 
system than lose any event. This is the reason it goes to such lengths.

If I understand the patch, it looks like its affecting code that adds, deletes, 
or lists audit rules. This code is quite old and working well. It didn't at 
first. We found a lot of problems by writing scripts like:

#!/bin/bash
while [ 1 ] ;
do
        echo "Inserting syscalls..."
        sys=1
        while [ $sys -lt 100 ]
        do
                sys=`expr $sys + 1`
                echo "$sys"
                auditctl -a entry,always -S $sys
        done

        echo "Listing..."
        auditctl -l
        echo "Deleting..."
        auditctl -D
done

with another shell running:

#!/bin/bash
while [ 1 ] ; 
do
	echo "Listing..."
	auditctl -l
done

and another shell running:

#!/bin/bash
while [ 1 ] ; 
do
	echo "Disabling..."
	auditctl -e 0
	echo "Enabling..."
	auditctl -e 1
done

You can probably imagine more stress tests. But the proposed code should be 
well tested similar to this.

Thanks,
-Steve
