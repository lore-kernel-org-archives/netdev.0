From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: How do I avoid recvmsg races with IP_RECVERR?
Date: Tue, 02 Jun 2015 23:50:44 +0200
Message-ID: <1433281844.2487226.285170105.063B7084@webmail.messagingengine.com>
References: <CALCETrW-jkMrEjidwCTraeAaHCHA_+9eExQAz2phvn=OB8RMhQ@mail.gmail.com>
 <1433279822.2479038.285136017.7DD69CC6@webmail.messagingengine.com>
 <CALCETrXHLZKVuhSRdi1NvqjFbRf0-PKTt1PYPN6Dw=sXeRA4iw@mail.gmail.com>
 <1433281373.2485127.285160441.6F17A081@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45533 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751717AbbFBVuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:50:44 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 77895206AF
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:50:44 -0400 (EDT)
In-Reply-To: <1433281373.2485127.285160441.6F17A081@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015, at 23:42, Hannes Frederic Sowa wrote:
> On Tue, Jun 2, 2015, at 23:33, Andy Lutomirski wrote:
> > On Tue, Jun 2, 2015 at 2:17 PM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> > > On Tue, Jun 2, 2015, at 21:40, Andy Lutomirski wrote:
> >
> > [...]
> >
> > I do this already, which makes me think that there's a bug or another
> > race somewhere.  I've only seen a failure once in several years of
> > operation.
> > 
> > The failure happened on a ping socket.  I suspect that the race is:
> > 
> > ping_err: ip_icmp_error(...);
> > 
> > user: recvmsg(MSG_ERRQUEUE) and dequeues the error.
> > 
> > ping_err: sk_err = err;
> > 
> > user: recvmsg(MSG_ERRQUEUE not set), and recvmsg sees and clears the
> > error via sock_error.
> > 
> > user: recvmsg(MSG_ERRQUEUE), and recvmsg returns -EAGAIN.
> > 
> > Now the user code thinks that it was a real (non-transient) error and
> > aborts.
> > 
> > Shouldn't that sk->sk_err = err assignment at least use WRITE_ONCE?
> 
> Hmm, I don't think this will help.
> 
> > Even if this race were fixed, this interface still sucks IMO.
> 
> Yes. :/
> 
> My proposal would be to make the error conversion lazy:
> 
> Keeping duplicate data is not a good idea in general: So we shouldn't
> use sk->sk_err if IP_RECVERR is set at all but let sock_error just use
> the sk_error_queue and extract the error code from there.
> 
> Only if IP_RECVERR was not set, we use sk->sk_err logic.
> 
> What do you think?

I just noticed that this will probably break existing user space
applications which require that icmp errors are transient even with
IP_RECVERR. We can mark that with a bit in the sk_error_queue pointer
and xchg the pointer, hmmm....

Bye,
Hannes
