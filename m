From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 09/15] userns: Convert process event connector to handle kuids and kgids
Date: Sun, 26 Aug 2012 06:43:45 -0700
Message-ID: <876285ahv2.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <877gsmfrkc.fsf@xmission.com>
	<20120826123354.GA23803@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42192 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2HZNn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 09:43:58 -0400
In-Reply-To: <20120826123354.GA23803@ioremap.net> (Evgeniy Polyakov's message
	of "Sun, 26 Aug 2012 16:33:54 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov <zbr@ioremap.net> writes:

> On Sat, Aug 25, 2012 at 05:02:59PM -0700, Eric W. Biederman (ebiederm@xmission.com) wrote:
>> 
>> - Only allow asking for events from the initial user and pid namespace,
>>   where we generate the events in.
>> 
>> - Convert kuids and kgids into the initial user namespace to report
>>   them via the process event connector.
>
>
> Looks good, if IDs are really supposed to be sent only from root
> namespace.

It is more about where events are recevied rather than where events are
sent from.

With this change events continue to be sent from all processes but can
only be received by processes in the initial user and initial pid
namespace.

To processes in other namespaces the uids and pids that the proc
connector code puts into it's messages are just non-sense, so I
cause the registration of connector clients in other namespaces to fail.

All of that I can do easily without a complete reworking of the current
connector code.  Which is enough for my current goal of building able
to build a kernel with all features enabled and only loosing features
if you are in somethin other than the initial namespaces.


> And you dropped PROC_EVENTS from init/Kconfig, but since it
> was no, it should be ok by default.

The removal of PROC_EVENTS from init/Kconfig was removing of the compile
guard that kept PROC_EVENTS and USER_NS from being selected at the same
time.  The curent user namespace code simply disables code that fails
to build when user namespace support is enabled.

> Feel free to add my acked-by: Evgeniy Polyakov <zbr@ioremap.net>
> Although I thoughs it could be more interesting to generate events
> including namespace id

There isn't a namespace id.  It is perfectly possible to generate events
that can be received by processes in multiple pid and user nameapces
just by calling pid_nr_ns() and from_kuid() with the right parameters.
The challenge is figuring out what namespaces have listening netlink
sockets we should send messages to.

Adding support for recepetion of connector proc events by listeners in
other namespaces looks like it would require near complete rewrite of
the connector code:
- Adding support for connector netlink sockets in other than the initial
  network namespace.
- Tracking which sockets were opened in which pid and which user
  namespaces.
- Filtering messages based on which namespaces the clients are listening
  in.
- Generating the different messages for the different sets of clients.

When someone cares enough I am certain the code will get written.
Having a clear unambigous that configuration does not work is
the first step in getting there.

I presume that whatever listens to connector based proc events listens
for the appropriate ack when registering and the daemon will fail to
start up.

Eric
