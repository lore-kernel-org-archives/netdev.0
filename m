From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: How do I avoid recvmsg races with IP_RECVERR?
Date: Tue, 02 Jun 2015 23:42:53 +0200
Message-ID: <1433281373.2485127.285160441.6F17A081@webmail.messagingengine.com>
References: <CALCETrW-jkMrEjidwCTraeAaHCHA_+9eExQAz2phvn=OB8RMhQ@mail.gmail.com>
 <1433279822.2479038.285136017.7DD69CC6@webmail.messagingengine.com>
 <CALCETrXHLZKVuhSRdi1NvqjFbRf0-PKTt1PYPN6Dw=sXeRA4iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47241 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751941AbbFBVmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:42:55 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2E45F20417
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:42:54 -0400 (EDT)
In-Reply-To: <CALCETrXHLZKVuhSRdi1NvqjFbRf0-PKTt1PYPN6Dw=sXeRA4iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015, at 23:33, Andy Lutomirski wrote:
> On Tue, Jun 2, 2015 at 2:17 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Tue, Jun 2, 2015, at 21:40, Andy Lutomirski wrote:
> >> As far as I can tell, enabling IP_RECVERR causes the presence of a
> >> queued error to cause recvmsg, etc to return an error (once).  It's
> >> worse, though: a new error can be queued asynchronously at any time,
> >> this setting sk_err to a nonzero value.  How do I sensibly distinguish
> >> recvmsg failures to to genuine errors receiving messages from recvmsg
> >> failures because there's a queued error?
> >>
> >> The only way I can see to get reliable error handling is to literally
> >> call recvmsg in a loop:
> >>
> >> while (true /* or while POLLIN is set */) {
> >>   int ret = recvmsg(..., MSG_ERRQUEUE not set);
> >>   if (ret < 0 && /* what goes here? */) {
> >>     whoops!  this might be a harmless asynchronous error!
> >>     take no action!
> >>   }
> >
> > I see either two possibilities:
> >
> > We export the icmp_err_convert tables along with the udp_lib_err error
> > conversions to user space and spice them up with flags to mark if they
> > are transient (icmp_err_convert already has a fatal flag).
> 
> This seems overcomplicated.  I'd rather have a flag I pass to tell the
> kernel that I don't want to see transient errors (nd that I'll clear
> them myself using POLLERR and either MSG_ERRQUEUE or SO_ERROR.
> 
> >
> > Otherwise you should be able to call recvmsg with MSG_ERRQUEUE set after
> > you got a ret < 0 when calling without MSG_ERRQUEUE and inspect the
> > sock_extended_err, no?
> 
> I do this already, which makes me think that there's a bug or another
> race somewhere.  I've only seen a failure once in several years of
> operation.
> 
> The failure happened on a ping socket.  I suspect that the race is:
> 
> ping_err: ip_icmp_error(...);
> 
> user: recvmsg(MSG_ERRQUEUE) and dequeues the error.
> 
> ping_err: sk_err = err;
> 
> user: recvmsg(MSG_ERRQUEUE not set), and recvmsg sees and clears the
> error via sock_error.
> 
> user: recvmsg(MSG_ERRQUEUE), and recvmsg returns -EAGAIN.
> 
> Now the user code thinks that it was a real (non-transient) error and
> aborts.
> 
> Shouldn't that sk->sk_err = err assignment at least use WRITE_ONCE?

Hmm, I don't think this will help.

> Even if this race were fixed, this interface still sucks IMO.

Yes. :/

My proposal would be to make the error conversion lazy:

Keeping duplicate data is not a good idea in general: So we shouldn't
use sk->sk_err if IP_RECVERR is set at all but let sock_error just use
the sk_error_queue and extract the error code from there.

Only if IP_RECVERR was not set, we use sk->sk_err logic.

What do you think?

Bye,
Hannes
