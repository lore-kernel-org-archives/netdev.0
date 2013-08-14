From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 23:18:17 +0200
Message-ID: <1376515097.9293.6.camel@nexus>
References: <1376508095.4596.12.camel@nexus>
 <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
 <520BE51F.40208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out-1.rwth-aachen.de ([134.130.5.186]:46254 "EHLO
	mx-out-1.rwth-aachen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932914Ab3HNVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 17:18:18 -0400
Received: from [192.168.0.131] ([unknown] [178.201.100.77])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0MRJ00F4VHUGP540@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 14 Aug 2013 23:18:17 +0200 (CEST)
In-reply-to: <520BE51F.40208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least in curl, the close() seems to be implicit as it occurs 
at the very end of the trace:

close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++

Nevertheless, shouldn't the stack keep on reading the input
even if the local application is not interested in it?
The other side might rely on it, and I've seen webserver logs
which indicate SSL read errors likely because of this.

Kind regards
 Damian

Am Mittwoch, den 14.08.2013, 13:14 -0700 schrieb Rick Jones:
> On 08/14/2013 12:50 PM, Yuchung Cheng wrote:
> > On Wed, Aug 14, 2013 at 12:21 PM, Damian Lukowski
> > <damian@tvk.rwth-aachen.de> wrote:
> >> Hi,
> >>
> >> the TCP specification states that an endpoint has to accept
> >> packets from the other side even after it has half-closed the
> >> connection locally. This does not seem to be the case
> >> under Linux?
> >>
> >> For example, when I wget -O /dev/null https://www.verisign.com/
> >> --max-redir 0, the local TCP stack sends an FIN,ACK close to the end.
> >> However, the webserver has more data to send (Encrypted Alert).
> >> Instead of ACKing the packet, the local side sends a RST.
> >> This seems wrong to me.
> >
> > Which wget are you using? it's not doing half-close (i.e.,
> > shutdown(SHUT_WR)) on my wget version 1.13.4
> 
> I suspect that when Damian system call traces his wget he will find it 
> is doing either:
> 
> close()
> 
> or
> shutdown(SHUT_WR)
> close()
> without waiting for the read return of zero from the remote.
> 
> it may even be just exiting after getting the last bytes of the URL, 
> which would be an implicit close()
> 
> Over the years I've seen examples of all three behaviours.
> 
> rick jones
> 
> >
> >
> >>
> >> Regards
> >>   Damian
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
