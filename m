From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK. (fwd)
Date: Wed, 07 Jan 2009 22:54:54 -0800
Message-ID: <m1eizez3r5.fsf@frodo.ebiederm.org>
References: <alpine.LRH.1.10.0901081542580.13212@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
In-Reply-To: <alpine.LRH.1.10.0901081542580.13212@tundra.namei.org> (James
	Morris's message of "Thu, 8 Jan 2009 15:44:07 +1100 (EST)")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris <jmorris@namei.org> writes:

> Would you be able to help answer these queries on the list?
>
> I'm not sure what the network namespace semantics are in (2) below.
>
> ---------- Forwarded message ----------
> Date: Wed, 7 Jan 2009 22:34:54 -0500
> From: Michael Stone <michael@laptop.org>
> To: James Morris <jmorris@namei.org>
> Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
>     linux-security-module@vger.kernel.org
> Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
>
> On Thu, Jan 08, 2009 at 12:22:17PM +1100, James Morris wrote:
>> Have you considered utilizing network namespaces [1] ?  A process created with
>> a private network namespace has no network interfaces configured, except
>> loopback, which is down.  Does this do what you want?  The launcher could
>> optionally allow local IP by bringing up the loopback interface.
>
> James,
>
> This net-namespaces work sounds quite apropos to some of my other
> projects but I'm having trouble figuring out whether it can be used to
> solve my current problem. Two questions which immediately occur to me
> include:
>
>  1) As with the netfilter suggestions provided by Andi and Evgeniy, it
>  seems that processes require special privileges (e.g. CAP_NET_ADMIN) in
>  order to drop network privileges by means of entering a new net
>  namespace. Is this correct? If so, why is it necessary or appropriate?

Yes.

Mostly general paranoia.  The problem is that the process could later
exec a suid root executable.  Potentially that suid root executable
could be fooled into a breach of security (such as not logging audit
records) because it is running in a network namespace.

The classic example of this class of exploits is using a mount
namespace to replace libc or /etc/passwd.  Both of which can lead
to privilege escalation.

I'm not creative enough at the moment to see how that class of exploits
would apply to a network namespace, but that is the reasoning for
requiring privilege.  

Let's see.  Having a network namespace namespace could allow you
to impersonate the local X server and steal a more privileged
users authentication tokens, provided by a suid binary.

>  2) What happens if I call unshare(CLONE_NEWNET) after I've bound some
>  sockets to an address or connected some sockets to remote endpoints?

All sockets are associated with a network namespace, and they don't change
when an unshare happens.  Accept still continues to work, and create
new sockets in the original network namespace.

However all calls to socket and to socketpair create new sockets that are
limited to living in the processes default network namespace.

> Perhaps you can help straighten me out, e.g. by pointing me at the
> relevant code?
>

Eric
