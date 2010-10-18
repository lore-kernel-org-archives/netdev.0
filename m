From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Mon, 18 Oct 2010 20:38:09 -0300
Message-ID: <20101018233809.GY8781@llucax.com.ar>
References: <20101018150422.GV8781@llucax.com.ar>
	<20101018184628.GX8781@llucax.com.ar>
	<AANLkTimKbOreV4Fuyw3TbCrk9aa5yBZQSuRbo3Vdx=Q1@mail.gmail.com>
	<20101018.151708.193712688.davem@davemloft.net>
	<4CBCD429.8090306@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Neil Horman <nhorman@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <4CBCD429.8090306@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Paul Gortmaker, el 18 de octubre a las 19:11 me escribiste:
> On 10-10-18 06:17 PM, David Miller wrote:
> > From: Paul Gortmaker<paul.gortmaker@windriver.com>
> > Date: Mon, 18 Oct 2010 16:42:33 -0400
> > 
> >> If you have access to the user space code in question, you can just
> >> switch behaviour semantics based on the results of a uname call, knowing
> >> that this change was included in versions since approx last Feb.  There
> >> is also /proc/version which can be parsed manually if you prefer.
> > 
> > Requiring userspace to check kernel versioning information in order
> > to user an exported userspace API correctly is _ALWAYS_ _WRONG_.
> > 
> > You cannot and must not make backwards incompatible changes to
> > userspace interfaces.
> 
> What I think has happened here (and I'll double check this
> tomorrow, since it is before I started assisting with tipc)
> is that a backwards incompatible change *did* inadvertently
> creep in via these two (related) commits:
> 
> --------------
> commit d88dca79d3852a3623f606f781e013d61486828a
> Author: Neil Horman <nhorman@tuxdriver.com>
> Date:   Mon Mar 8 12:20:58 2010 -0800
> 
>     tipc: fix endianness on tipc subscriber messages
> --------------
> 
> and
> 
> ---------------
> commit c6537d6742985da1fbf12ae26cde6a096fd35b5c
> Author: Jon Paul Maloy <jon.maloy@ericsson.com>
> Date:   Tue Apr 6 11:40:52 2010 +0000
> 
>     TIPC: Updated topology subscription protocol according to latest spec
> ---------------

Exactly. The damage is already done, the thing now is how to proceed.
What I'm doing right now is exactly that, use uname(2) to see what
kernel version is running and act according. Act according means, check
how with which tipc.h header the program was compiled (pre or post
2.6.35), compare against the current running kernel version, fix the BO
of subscriptions and fix the filter flags using my own constants
TIPC_SUB_SERVICE_V1 and TIPC_SUB_SERVICE_V2. Is not trivial, is not
nice.

And worse, as I said, for other languages bindings, specially those that
can't directly include a .h, there is no easy solution at all.

> Based on Leandro's info, I think it comes down to userspace
> not knowing exactly where to find these bits anymore:
> 
> #define TIPC_SUB_SERVICE       0x00    /* Filter for service availability    */
> #define TIPC_SUB_PORTS         0x01    /* Filter for port availability  */
> #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
> 
> ...because it doesn't know if there is the old auto endian
>  swap thing being done or not being done.

There are, at least, 2 problems here. One is the auto endian swap (which
I knew it existed just because of this issue). But the auto endian swap
is not fully backward compatible either AFAIK, at least I tried Gentoo's
kernel 2.6.22 r5 and the topology services doesn't work with NBO (I
don't know if is a bug introduced by Gentoo, or a bug in the kernel or
what else). So just changing the BO and claiming backward compatibility
(even when is only at source code level) is not entirely true (unless is
a Gentoo issue of course, which I should probably check).

The other problem is TIPC_SUB_SERVICE changed it value from 2 to 0. In
TIPC 1.x it was a flag set in the filter member of a subscription. In
TIPC 2.0 is the absence of TIPC_SUB_PORTS. The change seems reasonable,
as TIPC_SUB_SERVICE and TIPC_SUB_PORTS were mutually exclusive and you
had to use one always, but the result is an API and *ABI* change. You
can't use an old TIPC application without changing the code and
recompiling using a tipc.h header from 2.6.35 or newer. And then, if you
need to reboot with an older kernel, the new compiled application won't
work with the old kernel.

A third problem, much less critical but which I find annoying, is that
an inconsistency was introduced. In kernels older than 2.6.35 (TIPC 1.6)
you used HBO for all the TIPC data structures, addresses, port names,
port sequences, port ids, subscriptions, events. Now, subscriptions and
events go in NBO (which contains port sequences and port ids), but when
binding a port name/sequence, you have to use HBO. Is true that
a subscription is supposed to be a network message and the port name you
bind to is not, but is at least inconsistent with AF_INET, where all you
do uses NBO.

> Assuming it is possible to do so in some non-kludgy way,
> it sounds like we want to be looking into an in-kernel change
> that ensures the older user space binaries get their
> functionality restored then?

I think the most reasonable way to do this was to use a different port
name for the topology service for TIPC 2.0, and keep the old TIPC 1.x
topology service at the same port name it was, and using the same
interface as it did. Adding new constants TIPC_TOP_SRV2 and
TIPC_SUB_SERVICE2 (for example) would have been enough to keep backward
compatibility and allow a new clean interface. The old topology service
could be deprecated and completely removed some time in a distant
future. You could even add some #ifdef TIPC_1_COMPATIBILITY to make sure
people using the old interface is aware of that and update to the new
one.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
If you do not change your beliefs
Your life will always be like this

------------------------------------------------------------------------------
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly 
Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
