From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [RFC, PATCH] netlink based mq_notify(SIGEV_THREAD)
Date: Sat, 03 Apr 2004 22:43:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406F21FB.4010502@colorfullife.com>
References: <406F13A1.4030201@colorfullife.com> <1081023487.2037.19.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        Michal Wronski <wrona@mat.uni.torun.pl>,
        Krzysztof Benedyczak <golbi@mat.uni.torun.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1081023487.2037.19.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Sat, 2004-04-03 at 14:42, Manfred Spraul wrote:
>  
>
>>mq_notify(SIGEV_THREAD) must be implemented in user space. If an event 
>>is triggered, the kernel must send a notification to user space, and 
>>then glibc must create the thread with the requested attributes for the 
>>notification callback.
>>    
>>
>
>I am ignorant about SIGEV_THREAD but from what i gathered above: 
>
>- something (from user space??) attempts to create a thread in the
>kernel
>- the kernel sends notification to user space when said thread is
>created or done doing something it was asked
>
No - this part is wrong.

>- something (in glibc/userspace??) is signalled by the kernel to do
>something with the result
>  
>
This is correct.

mq_notify is a function from the posix message queue interface:
It allows user space to request that a notification should be sent if a 
new message is waiting in the message queue. There are two options for 
the notification: a signal or a callback that should be called in the 
context of a new thread.
Signals are trivial, but calling a function in the context of a new 
thread is tricky: the kernel can't create new user space threads.
Thus the kernel interface for mq_notify with sigev_notify==SIGEV_THREAD 
is an asynchroneous interface: the initial syscall just registers 
something and if a message arrives in the queue, then a notice is sent 
to user space. glibc must then create a SuS compatible interface on top 
of that.

The problem is how should I sent the information that a message is 
waiting to user space?

>> The current implementation in Andrew's -mm tree 
>>uses single shot file descriptor - it works, but it's resource hungry.
>>    
>>
>
>Essentially you attempt to open only a single fd via netlink as opposed
>to open/close behavior you are alluding to, is that correct? 
>
Yes.

>then all events are unicast to this fd. I am assuming you dont need to
>have more than one listener to these events? example, could one process
>create such a event which multiple processes may be interested in?
>  
>
Correct, always only one process interested in the notification.

>>Attached is a new proposal:
>>- split netlink_unicast into separate substeps
>>- use an AF_NETLINK socket for the message queue notification
>>    
>>
>
>I am trying to frob why you mucked around with AF_NETLINK; maybe your
>response will shed some light.
>  
>
I'm looking for the simplest interface to send 32 byte cookies from 
kernel to user space. The final send must be non-blocking, setup can 
block. Someone recommended that I should look at netlink. 
netlink_unicast was nearly perfect, except that I had to split setup and 
sending into two functions.

--
    Manfred
