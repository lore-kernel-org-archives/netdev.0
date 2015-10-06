From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v3 06/14] rocker: introduce worlds infrastructure
Date: Tue, 06 Oct 2015 14:25:36 -0700
Message-ID: <56143C50.2050604@gmail.com>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us> <1444117913-10386-7-git-send-email-jiri@resnulli.us> <CAE4R7bCdAQxLo3tKbXAqyGa_F3PhUTUkqrM5jTkYqcJJbCDmog@mail.gmail.com> <5613F482.2010200@gmail.com> <CAE4R7bAhc1HyrCxQfbfXUhQgME=UfjdVtF5PAyxy1Oe5g5EoTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33405 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbbJFVZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:25:53 -0400
Received: by pacex6 with SMTP id ex6so221303096pac.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 14:25:52 -0700 (PDT)
In-Reply-To: <CAE4R7bAhc1HyrCxQfbfXUhQgME=UfjdVtF5PAyxy1Oe5g5EoTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>>
>>> Using void * in these ops is unacceptable, I can't agree to this patch.
>>>
>>> There is a much cleaner way to architect this.  If you look at the ops
>>> defined, they're mostly duplicates of the already defined
>>> switchdev_ops.  It would be much cleaner to:
>>>
>>> 0) set port mode on qemu/rocker (the device)
>>> 1) get the port mode on port probe
>>> 2) based on port mode, set the switchdev_ops to point to the port mode
>>> world switchdev_ops
>>> 3) sub-class rocker_port, like I mentioned in before, to store
>>> world-specific stuff in rocker_port
>>>
>>> I don't buy the argument that we need to change port mode dynamically
>>> from the driver.  Set it at the device and be done.
>>>
>>
>> Maybe as a reference this strikes me as similar to how we do multiple
>> device support in a single driver like ixgbe or fm10k (the two I'm most
>> familiar with). At probe time we read the device id and then stub in
>> the specific callbacks for that device.
> 
> Exactly
> 
>> Sorry I'm still hung up on the multiple worlds thing, is it really
>> trying to model different devices under a single driver? In which case
>> maybe rather than port mode expose it as its own device id. Just a
>> thought.
> 
> Yes, different devices under single driver.  New device ID or
> sub-device ID will not work in this case as we're trying to slice it
> at the port level, not the device level.
> 

OK uncovered my next level of suspicion/confusion.

Do you actually have or seen hardware that has completely different
programming interface per port? And completely different pipelines?

This seems really strange to me and perhaps just an artifact of
the qemu implementation? Typically or at least what I expect is you
have a switch pipeline with a set of data structures, tcams, hash
tables, etc all connected together in some (possibly configurable)
topology. Ports feed packets into this pipeline and packets egress
out ports. In my logical view of a "switch" device the pipeline
is a shared resource you can partition it so that ports are isolated
in some sense but you can't use fundamentally different underlying
resources per ports. Its not a per port attribute/mode like this
series sort of hints at.

Also I wonder how this works when a pkt ingresses a port in mode A and
egresses a port in mode B? What fib/fdb tables does it cross when this
happens? It seems easier to just have two switch devices not a
hybrid. If this per port implementation maps to some hardware that
would be really interesting though.

.John
