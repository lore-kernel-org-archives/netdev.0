From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: Re: AF_BUS socket address family
Date: Mon, 2 Jul 2012 15:51:15 +0100
Message-ID: <20120702145114.GD28593@mail.collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
 <20120629.153656.1141845894730637434.davem@davemloft.net>
 <20120629231236.GA28593@mail.collabora.co.uk>
 <20120629.161821.948325645333976311.davem@davemloft.net>
 <20120629234230.GA11480@kyllikki.org>
 <20120630001350.GS21968@kvack.org>
 <20120630135240.41dbaacf@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120630135240.41dbaacf@pyramind.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 30, 2012 at 01:52:40PM +0100, Alan Cox wrote:
> On Fri, 29 Jun 2012 20:13:50 -0400
> Benjamin LaHaise <bcrl@kvack.org> wrote:
> 
> > On Sat, Jun 30, 2012 at 12:42:30AM +0100, Vincent Sanders wrote:
> > > The current users are suffering from the issues outlined in my
> > > introductory mail all the time. These issues are caused by emulating an
> > > IPC system over AF_UNIX in userspace.
> > 
> > Nothing in your introductory statements indicate how your requirements 
> > can't be met through a hybrid socket + shared memory solution.  The IPC 
> > facilities of the kernel are already quite rich, and sufficient for 
> > building many kinds of complex systems.  What's so different about DBus' 
> > requirements?
> 
> dbus wants to
> - multicast
> - pass file handles
> - never lose an event
> - be fast
> - have a security model
> 
> The security model makes a shared memory hack impractical, the file
> handle passing means at least some of it needs to be AF_UNIX. The event
> loss handling/speed argue for putting it in kernel.

Thankyou for making this point more eloquently than I had previously
been able to.

> 
> I'm not convinced AF_BUS entirely sorts this either. In particular the
> failure case dbus currently has to handle for not losing events allows it
> to identify who in a "group" has jammed the bus by not listening (eg by
> locking up). This information appears to be lost in the AF_BUS case and
> that's slightly catastrophic for error recovery.
> 

The strategy the existing AF_UNIX D-Bus daemon implements is simply to
have huge queues and thus rarely encounters the situation. When It
does the bus daemon crafts an error message as a reply to the sender.

The AF_BUS solution is more direct in that the sender gets either
EAGAIN for a direct send or EPOLLOUT from poll. Whatever the response
the sender can use this information to implement a userspace policy
decision.

Your feedback sparked a discussion and we have considered this in more
depth and propose implementing a userspace policy of:

 - sending a message to the bus master and let it "deal" with the
   blocking client.

 - The bus master might choose to isolate the offending client or
    perhaps even cause a service restart etc. 

   The bus master is a privileged client and has state information
    about the bus allowing an optimal decision. Though we intend to
    add a socket option to query the queue lengths so it can make a
    better decisions.

   Regardless this is all userspace policy for the D-Bus client
    library / bus master daemon which I believe addresses David Miller's
    concerns about such decisions being made in userspace.

--
Best Regards 
Vincent Sanders <vincent.sanders@collabora.co.uk>
