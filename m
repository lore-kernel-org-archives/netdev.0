From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] LSM: Add post accept() hook.
Date: Wed, 21 Jul 2010 12:06:47 -0400
Message-ID: <4C471B17.9070202@hp.com>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <201007191815.52124.paul.moore@hp.com> <201007200136.o6K1aVc5015269@www262.sakura.ne.jp> <201007201552.29539.paul.moore@hp.com> <201007210200.o6L20qjv025112@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jmorris@namei.org,
	sam@synack.fr, serge@hallyn.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007210200.o6L20qjv025112@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/10 22:00, Tetsuo Handa wrote:
> Paul Moore wrote:
>> On Monday, July 19, 2010 09:36:31 pm Tetsuo Handa wrote:
>>> One is for dropping connections from unwanted hosts. Administrators define
>>> policy before enabling enforcing mode (the mode which connections are
>>> dropped if operation was not granted by policy). Administrators specify
>>> acceptable hosts (i.e. hosts which this host needs to communicate with)
>>> and unacceptable hosts (i.e. hosts which this host needn't to communicate
>>> with).
>>
>> You can enforce per-host access controls without the need for a post-accept() 
>> hooks, e.g. security_sock_rcv_skb() and the netfilter hooks 
>> (NF_INET_POST_ROUTING, NF_INET_FORWARD, NF_INET_LOCAL_OUT).  Or are you 
>> interested in controlling which hosts an _application_ can communicate with?
> 
> I'm interested in controlling which ports on which hosts a _process_ can
> communicate with. In TOMOYO's words, "processes that belong to which TOMOYO's
> domain can communicate with which ports on which hosts".

...

>>> Dropping connections would happen if some process was hijacked and the
>>> process attempted to communicate with other processes using TCP
>>> connections. But dropping connections should not happen in normal
>>> circumstance.
>>
>> It doesn't matter if dropping connections is normal or not, what matters is 
>> that it can happen.
>>
>>> The other is for updating process's state variable upon accept() operation.
>>> LKM version of TOMOYO has per a task_struct variable that is used for
>>> implementing stateful permissions. (As of now, not implemented for LSM
>>> version of TOMOYO.)
>>
>> I'm open to re-introducing a post-accept() hook that does not have a return 
>> value, in other words, a hook that can only be used to update LSM state and 
>> not affect the connection.  Although I do think you could probably achieve the 
>> same thing using some of the existing LSM hooks (look at how SELinux updates 
>> its state upon accept()) but that is something you would have to look it and 
>> see if it works for TOMOYO.
> 
> I can't figure out why the hook must not affect the connection.
> Is it possible to clarify using below players?

I understand what you are trying to accomplish and my concern is that
(using the example below) ClientApp1 has it's connection with Server1
dropped suddenly _after_ Server1 successfully completes the TCP
handshake.  I've stated this concern several times.  I would much prefer
you reject the incoming connection during the initial TCP handshake.

> Server1 and Client1 are hosts which are connected on TCP/IP network.
> ServerApp1 and ServerApp2 are applications running on Server1 which might call
> socket(), bind(), listen(), accept(), send(), recv(), shutdown(), close() and
> execute().
> ClientApp1 and ClientApp2 are applications running on Client1 which might call
> socket(), connect(), send(), recv(), shutdown(), close().
> Router1 and Router2 are routers which exist between Server1 and Client1.
> 
>   +-------+   +-------+   +-------+   +-------+
>   |Server1|---|Router1|---|Router2|---|Client1|
>   +-------+   +-------+   +-------+   +-------+

...

> Router1 and Router2 can inject RST into the already established connections
> at any time (if they are IDS/IPS or broken or malicious).
> How does security_socket_post_accept() returning an error differs from these
> routers injecting RST?

We can't control all of the different intermediate nodes on a given
network path and it is true that some of these intermediate nodes
sometimes do "Bad Things" to network traffic (due either to limitations
in the design, placement in the network or poor implementation).
However, just because other nodes do "Bad Things" does not mean we need
to allow "Bad Things" to happen in the Linux end nodes.

-- 
paul moore
linux @ hp
