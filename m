From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: How do I avoid recvmsg races with IP_RECVERR?
Date: Tue, 02 Jun 2015 23:17:02 +0200
Message-ID: <1433279822.2479038.285136017.7DD69CC6@webmail.messagingengine.com>
References: <CALCETrW-jkMrEjidwCTraeAaHCHA_+9eExQAz2phvn=OB8RMhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41289 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751556AbbFBVRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:17:03 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id B3F5220486
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:17:02 -0400 (EDT)
In-Reply-To: <CALCETrW-jkMrEjidwCTraeAaHCHA_+9eExQAz2phvn=OB8RMhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015, at 21:40, Andy Lutomirski wrote:
> As far as I can tell, enabling IP_RECVERR causes the presence of a
> queued error to cause recvmsg, etc to return an error (once).  It's
> worse, though: a new error can be queued asynchronously at any time,
> this setting sk_err to a nonzero value.  How do I sensibly distinguish
> recvmsg failures to to genuine errors receiving messages from recvmsg
> failures because there's a queued error?
> 
> The only way I can see to get reliable error handling is to literally
> call recvmsg in a loop:
> 
> while (true /* or while POLLIN is set */) {
>   int ret = recvmsg(..., MSG_ERRQUEUE not set);
>   if (ret < 0 && /* what goes here? */) {
>     whoops!  this might be a harmless asynchronous error!
>     take no action!
>   }

I see either two possibilities:

We export the icmp_err_convert tables along with the udp_lib_err error
conversions to user space and spice them up with flags to mark if they
are transient (icmp_err_convert already has a fatal flag).

Otherwise you should be able to call recvmsg with MSG_ERRQUEUE set after
you got a ret < 0 when calling without MSG_ERRQUEUE and inspect the
sock_extended_err, no?

Bye,
Hannes
