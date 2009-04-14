From: Christoph Lameter <cl@linux.com>
Subject: Re: Kernel sends multicast groups to sockets that did not subscribe
 to the MC group
Date: Tue, 14 Apr 2009 14:33:53 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904141424440.30596@qirst.com>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:43071 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758454AbZDNSkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 14:40:47 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 32FB282C4A4
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 14:50:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kUPqQHvxjTdu for <netdev@vger.kernel.org>;
	Tue, 14 Apr 2009 14:50:21 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 15C6682C246
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 14:50:21 -0400 (EDT)
In-Reply-To: <20090414182731.GD14305@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Apr 2009, Neil Horman wrote:

> The only reason that happens is because the apps themselves are broken.  The
> only way an application would get messages from unexpected Multicast addresses
> is if it joined a group, and then bound the socket to INADDR_ANY, rather than to
> the multicast group and port that it joined to.  And if it does that, it has to
> be written to detect and cope with malformed data from unexpected hosts, lest it
> be vulnurable to any number of bugs.

This occurs here if two applications on a machine bind to the
different MC groups but the same port. Applications need to bind to the
same port since MC traffic has a port number included. Do I need to bind
to the IP address of the NIC? What does INADDR_ANY have to do with it?

> It works exactly the same way with unicast UDP.  If an application receives on a
> socket that is bound to INADDR_ANY, it needs to be especially careful in parsing
> the data that it receives, since there is no transport layer validation of the
> sending clients status (the way there is with tcp or sctp).  If host A has a
> socket on an application bound to INADDR_ANY and is receiving data from host B,
> nothing is stopping host C from starting to send whatever garbage it wants to
> host A as well, and its up to the application to sort that out.  Its exactly the
> same with multicast.  Its just that people assume it works in a certain way
> (like I did), and it doesn't.

Again what does this have to do with INADDR_ANY? You are talking about UDP
sockets? In that case the sorting out usually happens based on the source
address anyways.

> Yes, we can change the code, and its not hard, the question is: why?  It would
> make the use of multicast a bit more intuitive, yes, but I would be concerned
> about applications which expect this behavior.  They would all break with this
> change.  I can certainly envision an application listening on multiple multicast
> groups, and as a matter of simplification, binding to INADDR_ANY, and validating
> any received data to toss messages from groups they don't want in user space.  I
> suppose theres some advantage in doing the filtering in kernel space to avoid
> the extraneous copy_to_user, but I'm not sure thats always feasible, As an
> application might not know at any given moment what multicast groups it needs to
> receive on.

Please read the initial message that started this thread.

If an application listens on multiple multicast groups then it needs to
perform join operations otherwise the switch will not forward the
multicast groups to the host.
(Just ignoring the INADDR_ANY bits since I do not know what this would
have to do with the issue at hand)

> Possible, but I'd still be worried about the above.  Using a switch like this is
> global (or at least per net namespace), and prevents a mix of apps written to
> the 'new model' and the current model.  A prctl option or an additional socket
> option might be more palatable.  I think if you could find some standard,
> specification or common practice documenting that multicast works the way
> you 'expect' on other systems, thsi might get more traction.  I've not found
> anything to that effect though (although I've not looked very hard).

I cannot envision that there would be many applications having made any
use of the current situation where all mc traffic to a port is forwarded
to the multiple applications that may have subscribed to disjunct sets of
multicast groups.

One could envison having two processes that open the same socket/port and
coordinate: The first joins the multicast groups and then continues in a
monitoring role whereas the second actually processes the data. But then
the data is forwarded to both processes and one of them is not processing
it. So its fundamentally bad behavior. I would even suggest to make the
socket based filtering the default (as in other OSes).

