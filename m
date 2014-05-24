From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Sat, 24 May 2014 08:13:36 +0200
Message-ID: <53803890.2000000@gmail.com>
References: <536101C9.9090601@gmail.com> <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com> <20140512143451.GB13801@kernel.org> <20140521210535.GA5414@kernel.org> <537E0961.8040005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, lkml <linux-kernel@vger.kernel.org>,
	"linux-man@vger.kernel.org" <linux-man@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1v?= =?UTF-8?B?bnQ=?=
	<remi.denis-courmont@nokia.com>, Paul Moore <paul@paul-moore.com>,
	Chris Friesen <chris.friesen@windriver.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E0961.8040005@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping!

On 05/22/2014 04:27 PM, Michael Kerrisk (man-pages) wrote:
> Hi Arnaldo,
> 
> On 05/21/2014 11:05 PM, Arnaldo Carvalho de Melo wrote:
>> Em Mon, May 12, 2014 at 11:34:51AM -0300, Arnaldo Carvalho de Melo escreveu:
>>> Em Mon, May 12, 2014 at 12:15:25PM +0200, Michael Kerrisk (man-pages) escreveu:
>>>> Hi Arnaldo,
>>  
>>>> Ping!
>>
>>> I acknowledge the problem, the timeout has to be passed to the
>>> underlying ->recvmsg() implementations that should return the time spent
>>> waiting for each packet, so that we can accrue that at recvmmsg level.
>>  
>>> We can do either passing an extra timeout parameter to the recvmsg
>>> implementations or using some struct sock member to specify that
>>> timeout.
>>  
>>> The first approach is intrusive, touches tons of files, so I'll try
>>> making it all mostly transparent by hooking into sock_rcvtimeo()
>>> somehow.
>>
>> But after thinking a bit more, looks like we need to do that, please
>> take a look at the attached patch to see if it addresses the problem.
>>
>> Mostly it adds a new timeop to the per protocol recvmsg()
>> implementations, that, if not NULL, should be used instead of
>> SO_RCVTIMEO.
>>
>> since the underlying recvmsg implementations already check that timeout,
>> return what is remaining, that will then be used in subsequent recvmsg
>> calls, at the end we just convert it back to timespec format.
>>
>> In most cases it is just passed to skb_recv_datagram, that will check
>> the pointer, use it and update if not NULL.
>>
>> Should have no problems, but I only did a boot with a system with this
>> patch applied, no problems noticed on a normal desktop session, ssh,
>> etc.
> 
> Thanks! I applied this patch against 3.15-rc6.
> 
> recvmmsg() now (mostly) does what I expect: 
> * it waits until either the timeout expires or vlen messages 
>   have been received
> * If no message is received before timeout, it returns -1/EAGAIN.
> * If vlen messages are received before the timeout expires, then
>   the remaining time is returned in timeout.
> 
> One question: in the event that the call is interrupted by a signal 
> handler, it fails (as expected) with EINTR, but the 'timeout' value is 
> not updated with the remaining time on the timer. Would it be desirable 
> to emulate the behavior of select() (and other syscalls) in this 
> respect, and instead return the remaining time if interrupted by 
> a signal?
> 
> Cheers,
> 
> Michael
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
