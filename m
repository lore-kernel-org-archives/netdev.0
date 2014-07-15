From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 3/3] net: sctp: Add partial support for
 MSG_MORE on SCTP
Date: Tue, 15 Jul 2014 16:13:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17273E46@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB7@AcuExch.aculab.com>
 <53C04509.70304@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D17271E0B@AcuExch.aculab.com>
 <53C42C58.3050108@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D17273C31@AcuExch.aculab.com>
 <53C547AD.3090906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40205 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751604AbaGOQOd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 12:14:33 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13589-01 for <netdev@vger.kernel.org>;
 Tue, 15 Jul 2014 17:14:24 +0100 (BST)
In-Reply-To: <53C547AD.3090906@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 07/15/2014 10:33 AM, David Laight wrote:
> > From: Vlad Yasevich
> >> On 07/14/2014 12:27 PM, David Laight wrote:
> >>> From: Vlad Yasevich
> >>> ...
> >>>>> +	/* Setting MSG_MORE currently has the same effect as enabling Nagle.
> >>>>> +	 * This means that the user can't force bundling of the first two data
> >>>>> +	 * chunks.  It does mean that all the data chunks will be sent
> >>>>> +	 * without an extra timer.
> >>>>> +	 * It is enough to save the last value since any data sent with
> >>>>> +	 * MSG_MORE clear will already have been sent (subject to flow control).
> >>>>> +	 */
> >>>>> +	if (msg->msg_flags & MSG_MORE)
> >>>>> +		sp->tx_delay |= SCTP_F_TX_MSG_MORE;
> >>>>> +	else
> >>>>> +		sp->tx_delay &= ~SCTP_F_TX_MSG_MORE;
> >>>>> +
> >>>>
> >>>> This is ok for 1-1 sockets, but it doesn't really work for 1-many sockets.  If one of
> >>>> the associations uses MSG_MORE while another does not, we'll see some interesting
> >>>> side-effects on the wire.
> >>>
> > ...
> >>> I don't think this is a problem.
> >>
> >> Not, it is not a _problem_, but it does make MSG_MORE rather useless
> >> in some situations.  Waiting for an ACK across low-latency links
> >> is rare, but in a high-latency scenarios where you want to utilize the
> >> bandwidth better with bundling, you may not see the gains you expect.
> >>
> >> Since MSG_MORE is association, it should be handled as such and an
> >> a change on one association should not effect the others.
> >
> > I think the comments already say that it is only a partial implementation.
> > (If you send 2 chunks on an idle connection, they get sent separately.)
> > Perhaps I'll add a note about possibly 'odd' effects for 1-many sockets
> > with multi-threaded apps.
> >
> > It helps a lot for my M3UA traffic.
> > I can get the same effect on an old kernel by repeatedly changing SCTP_NODELAY,
> > but that does rather rely on the way Nagle is implemented.
> 
> You can fix this by having an sp->tx_delay value and a assoc->tx_delay value
> and simple check (sp->tx_delay | assoc->tx_delay).  MSG_MORE would only set
> the assoc->tx_delay while SCTP_NODELAY would effect the socket.
> 
> This way, when one association uses MSG_MORE, it will not effect other associations
> on the same socket that don't use it.

In that case it is probably worth caching SCTP_NODELAY in the asoc as well.
It looks like it ought to be valid for the setsockopt code to 'list_for_each_entry'
on ep->asocs and sctp_endpoint_add_asoc() to copy down the current value.

Should I change the code so that the first chunk is also not sent?
If an application failed to do a final send (with MSG_MORE clear) then
it would never be set, and there is no way to flush it.
I didn't do that because I'm not really interested in merging 2 chunks.
I'm trying to get 100s of chunks merged.

	David
