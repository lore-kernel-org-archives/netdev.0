From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Extend netlink error codes
Date: Mon, 13 Sep 2004 22:36:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913203657.GF23686@postel.suug.ch>
References: <20040910225158.GO20088@postel.suug.ch> <20040911155839.GN4431@wotan.suse.de> <20040911162433.GC21181@postel.suug.ch> <3A0D075D-0423-11D9-BBE1-000A95AD0668@errno.com> <1094937035.2344.189.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Leffler <sam@errno.com>, Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094937035.2344.189.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1094937035.2344.189.camel@jzny.localdomain> 2004-09-11 17:10
> On Sat, 2004-09-11 at 14:48, Sam Leffler wrote:
> just reuse skb->cb[] and intepret it in rtnetlink in the case of
> failures.

Good idea, however it means to change a lot of APIs used by modules
to provide the skb or a pointer to the error string buffer.

I still think it would be best to transport the error code via
the return value in order to not change any static APIs, but
I guess that 32bit is not enough to store errno and the id
your propose below.

> I think we need to identify errors by IDs - dont think we can avoid
> that. The IDs could be the T in TLV; their scope is per socket level (eg
> at rtnetlink); This means there are 16 bits space per socket type.
> The next level to addressing is at each submodule level eg qdisc,
> ipv4route, etc. Assuming we have 8 bits there that leaves upto 8 bits
> per submodule for different error types. 256 error codes per submodule
> liek a qdisc sounds very reasonable to me. We could reserve the last
> entry for future extensions. Example:
> 
> socket: rtnetlink
> submodule: qdisc (module 1)
> error id: Q_NASTYTHING which is 0x10
> qdisc_errors[Q_NASTYTHING] is "something really nasty just happened"

Sounds reasonable to me.

> BTW, there was someone from IBM a while back who was talking about
> having drivers send error messages via netlink; someone needs to look at
> the ideas they have maybe we can borrow something.

http://lwn.net/Articles/39164/

I read trough the patch and what they basically provide is a way to send
data to a netlink socket. The data can be collected via an own netlink
socket by subscribing to it or use the user space daemon.

They provide stuff like:

int
evl_printf(const char *facility, int event_type, int severity,
	const char *fmt, ...)

usage could be something like:

evl_printf("qdisc", Q_NASTYTHING, ...

We could use it this way:
- Leave the existing error system as it is
- Make the netlink users send out error messages on their own.
  pid and sequence number of the original netlink message could be
  provided.
- User space applications could fetch error messages from that socket
  and assign them to their own actions by sequence number and pid.

Pros:
 - Almost no changes to the APIs
 - Easy to implement
 - No problem with distribution of error codes
 - Very easy to implement formatted error strings.

Cons:
 - More work for user space
 - How does user space know if there will be an extended error?
   If unknown, how long to wait?
 - Should we allow sending of errors to this socket while no
   netlink message is being processed?

Idea: Make user space applications poll on the socket and
just print the errors async. This would allow netlink users to
use it for more than just error handling.
