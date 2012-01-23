From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC Hanging clean-up of a namespace
Date: Sun, 22 Jan 2012 23:17:00 -0800
Message-ID: <m1ipk2riqb.fsf@fess.ebiederm.org>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
	<201201230707.33761.hans.schillstrom@ericsson.com>
	<m1aa5frl3j.fsf@fess.ebiederm.org>
	<201201230758.55200.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox\@diac24.net" <equinox@diac24.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59189 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab2AWHO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 02:14:28 -0500
In-Reply-To: <201201230758.55200.hans.schillstrom@ericsson.com> (Hans
	Schillstrom's message of "Mon, 23 Jan 2012 07:58:54 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans.schillstrom@ericsson.com> writes:

> On Monday 23 January 2012 07:25:52 Eric W. Biederman wrote:
>> Hans Schillstrom <hans.schillstrom@ericsson.com> writes:
>> 
>> > On Friday 20 January 2012 21:55:27 Eric W. Biederman wrote:
>> >> My current hypothesis is that the namespace actually didn't get freed
>> >> until the tcp socket finished closing.  You can check by looking at when
>> >> __put_net and then cleanup_net are called.
>> >
>> > __put_net() is called just after tcp_write_timer() fires and then
>> > cleanup_net()
>> 
>> Hypothesis confirmed.  Your speed problem is that it is taking 2 minutes
>> in the pathological case for your tcp socket to close.
>> 
>> Do you have any clue why it is taking your sockets so long to close?
>> Is the other side simply not responding?
>> 
>
> The root cause of death is that the other side (init_net namespace) dies first 
> and when it dies all containers will be killed ...

?????

init_net can not die.  init_net must not die.  It makes no sense for the
ref count on init_net to drop to 0.  Among other places every kernel
thread uses init_net.  Furthermore the network namespaces are
independent so even the impossible death of the initial network
namespace should not kill a child network namespace.

Did I misunderstand what you said?

If you have a setup where you stop being able to talk to the outside
world because you were relaying through the initial network namespace
and the relay through the initial network namespace stopped functioning
that makes sense.  So effectively all of your packets are being dropped
on the floor the tcp retransmit behavior on closing a socket makes
sense.  I just don't get how you have triggered that state.

Eric
