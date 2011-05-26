From: Arun Sharma <asharma@fb.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Thu, 26 May 2011 14:48:11 -0700
Message-ID: <4DDECA9B.8080206@fb.com>
References: <201104250033.03401.maxi@daemonizer.de>	 <1303878240.2699.41.camel@edumazet-laptop>	 <1303878771.2699.44.camel@edumazet-laptop>	 <201104271352.00601.maxi@daemonizer.de>	 <20110512211033.GA3468@dev1756.snc6.facebook.com>	 <1305234953.2831.2.camel@edumazet-laptop>	 <20110524213327.GA3917@dev1756.snc6.facebook.com>	 <1306291469.3305.11.camel@edumazet-laptop>	 <20110525060609.GA32244@dev1756.snc6.facebook.com>	 <1306305331.3305.22.camel@edumazet-laptop>  <4DDEAA3C.7020502@fb.com> <1306439246.2543.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306439246.2543.10.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/26/11 12:47 PM, Eric Dumazet wrote:

> You dont get the problem. Problem is : We can do the empty() test only
> if protected by the lock.
>
> If not locked, result can be wrong. [ false positive or negative ]
>


Agreed. Failing to unlink from unused list when we should have sounds wrong.

>> The list modification under unused_peers.lock looks generally safe. But
>> the control flow (based on refcnt) done outside the lock might have races.
>>
>
> "might" is not a good word when dealing with this ;)

Potential race in the current code:

initial refcnt = 1

        T1:                                        T2

atomic_dec_and_lock(refcnt)
// refcnt == 0

                                        atomic_add_unless(refcnt)
                                        unlink_from_unused()

list_add_tail(unused)
                                        // T2 using "unused" entry


> Did you test my fix ?

I could try it on one or two machines - but it won't tell us anything 
for weeks if not months. Unfortunately my next window to try a new 
kernel on a large enough sample is several months away.

>
> Its doing the right thing : Using refcnt as the only marker to say if
> the item must be removed from unused list (and lock the central lock
> protecting this list only when needed)
>
> Since we already must do an atomic operation on refcnt, using
> atomic_inc_return [ or similar full barrier op ] is enough to tell us
> the truth.

Yeah - using the refcnt seems better than list_empty(), but I'm not sure 
that your patch addresses the race above.

  -Arun
