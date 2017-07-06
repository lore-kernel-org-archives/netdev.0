From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Thu, 6 Jul 2017 14:12:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "manfred@colorfullife.com" <manfred@colorfullife.com>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
To: "'paulmck@linux.vnet.ibm.com'" <paulmck@linux.vnet.ibm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170705232955.GA15992@linux.vnet.ibm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul E. McKenney
> Sent: 06 July 2017 00:30
> There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> and it appears that all callers could do just as well with a lock/unlock
> pair.  This series therefore removes spin_unlock_wait() and changes
> its users to instead use a lock/unlock pair.  The commits are as follows,
> in three groups:
> 
> 1-7.	Change uses of spin_unlock_wait() and raw_spin_unlock_wait()
> 	to instead use a spin_lock/spin_unlock pair.  These may be
> 	applied in any order, but must be applied before any later
> 	commits in this series.  The commit logs state why I believe
> 	that these commits won't noticeably degrade performance.

I can't help feeling that it might be better to have a spin_lock_sync()
call that is equivalent to a spin_lock/spin_unlock pair.
The default implementation being an inline function that does exactly that.
This would let an architecture implement a more efficient version.

It might even be that this is the defined semantics of spin_unlock_wait().

Note that it can only be useful to do a spin_lock/unlock pair if it is
impossible for another code path to try to acquire the lock.
(Or, at least, the code can't care if the lock is acquired just after.)
So if it can de determined that the lock isn't held (a READ_ONCE()
might be enough) the lock itself need not be acquired (with the
associated slow bus cycles).

	David
