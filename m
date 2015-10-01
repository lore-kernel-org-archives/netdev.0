From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v2 00/14] RDS: connection scalability and performance
 improvements
Date: Thu, 1 Oct 2015 12:00:16 -0700
Message-ID: <560D82C0.4020006@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBAA322@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ssantosh@kernel.org" <ssantosh@kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBAA322@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/1/15 9:19 AM, David Laight wrote:
> From: Santosh Shilimkar
>> Sent: 30 September 2015 18:24
> ...
>> This is being addressed by simply using per bucket rw lock which makes the
>> locking simple and very efficient. The hash table size is still an issue and
>> I plan to address it by using re-sizable hash tables as suggested on the list.
>
> If the hash chains are short do you need the expense of a rw lock
> for each chain?
Chains can be really long on larger systems with many databases.

> A simple spinlock may be faster.
>
> If you use the hash chain lock for the reference count on the hashed
> objects you should be able to release the lock before locking the
> object itself.
>
Because of the shared socket nature of RDS, the chain needs to be
protected for parallel accesses for add/removal/lookup. Hashing is
really used to get to the bucket which holds the hlist.

Just to give a bit of history, RDS bind code has evolved over
few years of time. It started with a rb tree and a global rw
lock which wasn't very efficient.Then it was converted to rcu
hlist with spin lock to make the look ups faster. But that
scheme as well exploded on larger systems with truckloads of
sockets with read/write lock failures because of excessive
contention. As high as almost ~25% of system load. Per bucket
lock actually solved most of those issues. Bucket or chain table
increase(1k to 8K) was actually relatively smaller gain though still 
helped to reduce the contention by almost to a nominal 1 or 2 %.

Am still getting my head around with rhashtable plumbing with
this usecase. Will CC you when I post the RFC patch for the
rhashtable conversion. Thanks for your comments so far.

Regards,
Santosh
