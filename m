From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 00:49:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414E0CE6.107@eurodev.net>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <20040919120730.GA6005@gondor.apana.org.au> <414DF111.3080409@eurodev.net> <20040919215328.GA9573@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919215328.GA9573@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Sorry, if i repeat things, I'm not willing to be annoying, just clarifying.

I'm always talking all the time about sending information from kernel 
space to user space where I found the problem. There's no problem in 
doing on the other way, in that case buffer never gets full.

Herbert Xu wrote:

>Workaround for what? Please define your problem.
>  
>
Two problems:

a) if you request information via nl sockets from user space and a 
kernel module doesn't use the dontwait flag (I know, *nobody* is doing 
this at the moment, so currently broadcast/unicast never wait as you 
remarked).

When we request info from user space (sendmsg), you execute the callback 
from a module which usually replies with some information 
(netlink_unicast). The problem happens if the size of the information is 
too big for the buffer. In that case, before using applying my patch, it 
hangs (in <2.6.9-rc1, it puts it to sleep if buffer gets full). I'm 
talking about using unicast/broadcast without dontwait flag.

b) A module needs to send a lot of information from kernel space to user 
space, if buffer gets full quickly, buffer overruns and 
netlink_unicast/broadcast never wait, so they drop packets.

Why someone could call netlink_unicast/broadcast from a module telling 
them to wait if necessary? if that module want to care about a possible 
message drop. This happens if you stress nl sockets. This way netlink 
sockets behave well with an important workload without dropping 
messages. So the user space part doesn't get that annoying -enobufs error.

>Your original message mentioned a dead-lock, which is now obviously non-existant.
>  
>

it exists if you use netlink_unicast/broadcast telling them to wait, so 
it's not a real problem for current applications because they tell 
netlink_unicast/broadcast not to wait.

regards,
Pablo
