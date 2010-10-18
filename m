From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Mon, 18 Oct 2010 19:45:47 -0400
Message-ID: <20101018234547.GA5703@hmsreliant.think-freely.org>
References: <20101018150422.GV8781@llucax.com.ar>
	<20101018184628.GX8781@llucax.com.ar>
	<AANLkTimKbOreV4Fuyw3TbCrk9aa5yBZQSuRbo3Vdx=Q1@mail.gmail.com>
	<20101018.151708.193712688.davem@davemloft.net>
	<4CBCD429.8090306@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, luca@llucax.com.ar,
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

On Mon, Oct 18, 2010 at 07:11:37PM -0400, Paul Gortmaker wrote:
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
> 
> Based on Leandro's info, I think it comes down to userspace
> not knowing exactly where to find these bits anymore:
> 
> #define TIPC_SUB_SERVICE       0x00    /* Filter for service availability    */
> #define TIPC_SUB_PORTS         0x01    /* Filter for port availability  */
> #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
> 
That shouldn't be the case.  Prior to the above changes the tipc implementation
tracked the endianess of the hosts to which it was connected and swapped data
that it sent to those hosts accordingly.  With these changes the kernel client
simply swaps the data to network byte order on send and swaps it back to local
order on receive universally.  That second commit added a bit from the reserved
pool of one of the connection establishment messages to indicate that a peer was
using this new protocol.  If some non-local byte order information is making it
into user space, thats a bug that needs fixing.

What may be happening is some old client that doesn't know about the new bit
might be communicating with an new client that does.  IIRC the spec called for
clients that set bits in the reserved field to drop frames from that client, so
that condition shouldn't occur, but TIPC may just be ignoring reserved bits.  I
wouldn't be suprised.

Its also possible that the payload data between applications using tipc follow
the same broken byte swapping method that the protocol itself did, but if that
were the case I would expect the application to continue running normally,
unless user space had direct access to the protocol header in its entirety, and
read it directly, in which case I think I would just cry.

> ...because it doesn't know if there is the old auto endian
>  swap thing being done or not being done.
> 
> Assuming it is possible to do so in some non-kludgy way,
> it sounds like we want to be looking into an in-kernel change
> that ensures the older user space binaries get their
> functionality restored then?
> 
Lets try figure out exactly what data is getting mis-read first.  Maybe we can
fix it without having to go back to making a sending host figure out a receiving
hosts byte order.  That would be nice.  Can you describe the problem in more
detail?

Neil

> Thanks,
> Paul.
> 

------------------------------------------------------------------------------
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly 
Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
