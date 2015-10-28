From: Jason Baron <jbaron@akamai.com>
Subject: Re: [RFC] unix: fix use-after-free in unix_dgram_poll()
Date: Wed, 28 Oct 2015 13:57:47 -0400
Message-ID: <56310C9B.1010608@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>
 <f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
 <87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
 <5612B9A9.8050301@akamai.com>
 <87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
 <561DCFA4.3010300@akamai.com>
 <87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
 <561F156E.9050905@akamai.com>
 <87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
 <5625073C.5010809@akamai.com>
 <87vba1i383.fsf@doppelsaurus.mobileactivedefense.com>
 <874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/28/2015 12:46 PM, Rainer Weikusat wrote:
> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
>> Jason Baron <jbaron@akamai.com> writes:
> 
> [...]
> 
>>> 2)
>>>
>>> For the case of epoll() in edge triggered mode we need to ensure that
>>> when we return -EAGAIN from unix_dgram_sendmsg() when unix_recvq_full()
>>> is true, we need to add a unix_peer_wake_connect() call to guarantee a
>>> wakeup. Otherwise, we are going to potentially hang there.
>>
>> I consider this necessary.
> 
> (As already discussed privately) just doing this would open up another
> way for sockets to be enqueued on the peer_wait queue of the peer
> forever despite no one wants to be notified of write space
> availability. Here's another RFC patch addressing the issues so far plus
> this one by breaking the connection to the peer socket from the wake up
> relaying function. This has the nice additional property that the
> dgram_poll code becomes somewhat simpler as the "dequeued where we
> didn't enqueue" situation can no longer occur and the not-so-nice
> additional property that the connect and disconnect functions need to
> take the peer_wait.lock spinlock explicitly so that this lock is used to
> ensure that no two threads modifiy the private pointer of the client
> wait_queue_t.

Hmmm...I thought these were already all guarded by unix_state_lock(sk).
In any case, rest of the patch overall looks good to me.

Thanks,

-Jason
