From: Josh Hunt <johunt@akamai.com>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Fri, 22 Jun 2012 08:44:06 -0500
Message-ID: <4FE476A6.1050209@akamai.com>
References: <CAATkVEzTxT6d5nzt_qwCuFWM-WcN8hdhjGxFRPXJ4=L35wKbGw@mail.gmail.com>  <4FE37783.9000409@akamai.com> <1340310469.4604.6702.camel@edumazet-glaptop>  <4FE41570.4090803@akamai.com> <1340353746.4604.9502.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	Debabrata Banerjee <dbavatar@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340353746.4604.9502.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/22/2012 03:29 AM, Eric Dumazet wrote:
> On Fri, 2012-06-22 at 01:49 -0500, Josh Hunt wrote:
>> On 06/21/2012 03:27 PM, Eric Dumazet wrote:
>>> On Thu, 2012-06-21 at 14:35 -0500, Josh Hunt wrote:
>>>
>>>> Can anyone provide details of the crash which was intended to be fixed
>>>> by 2bec5a369ee79576a3eea2c23863325089785a2c? With this patch in and
>>>> doing concurrent adds/deletes and dumping the table via netlink causes
>>>> duplicate entries to be reported. Reverting this patch causes those
>>>> problems to go away. We can provide a more detailed test if that is
>>>> needed, but so far our testing has been unable to reproduce the crash
>>>> mentioned in the above commit with it reverted.
>>>
>>> A mere revert wont be enough.
>>>
>>> Looking at this code, it lacks proper synchronization
>>> between tree updaters and tree walkers.
>>>
>>> fib6_walker_lock rwlock is not enough to prevent races.
>>>
>>> Are you willing to fix this yourself ?
>>>
>>
>> Looking through the code a bit more it seems like we would need to have
>> a lock in fib6_walker_t to protect its contents. Mainly for when we
>> update the pointers in fib6_del_route and fib6_repair_tree. Right now
>> there is the fib6_walker_lock, but that appears to only be protecting
>> the elements of the list, not their contents. Is this what you had in
>> mind? I just coded up something along these lines and it works for the
>> most part, but I also got a message about unsafe lock ordering when I
>> stressed it so I am messing something up. If this sounds like it's on
>> the right track I can work out the kinks in the morning.
> 
> Hmm, it seems tb6_lock is held by a writer, so its safe :
> 
> a tree walker can run only holding a read_lock on tb6_lock

Ahh. That makes sense and is what Alexey said before I just didn't put
it all together. So we are OK reverting this patch? I cannot find a path
where the walker's pointers are updated without the tb6_lock write_lock.

Josh
