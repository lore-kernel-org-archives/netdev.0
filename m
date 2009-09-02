From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 02 Sep 2009 14:44:49 +0200
Message-ID: <4A9E68C1.5050407@trash.net>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com> <20090902091854.GA6530@ff.dom.local> <20090902093329.GB6530@ff.dom.local> <20090902093710.GA7097@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Lameter <cl@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45480 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZIBMo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 08:44:56 -0400
In-Reply-To: <20090902093710.GA7097@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Sep 02, 2009 at 09:33:29AM +0000, Jarek Poplawski wrote:
>> On Wed, Sep 02, 2009 at 09:18:54AM +0000, Jarek Poplawski wrote:
>>> On Wed, Sep 02, 2009 at 10:28:55AM +0200, Eric Dumazet wrote:
>> ...
>>>> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>>  rate 0bit 0pps backlog 0b 0p requeues 0
>>>>
>>>>
>>>> Same name "eth0" is displayed, that might confuse parsers...
>>>>
>>>> What naming convention should we choose for multiqueue devices ?
>>>>
>>> Hmm... anything could break here something for somebody, so there is
>>> still a (Patrick's) question if not sum it all? Otherwise, I wonder
>>> about using the qdisc handle (tcm_handle>>16): there would be at
>>> least one "pfifo_fast 0:" looking like proper root for somebody...
>> I meant "proper" for pfifo_fast. On the other hand, I wonder why these
>> multiqueue qdisc handles can't be really given such unique per dev
> 
> should be:
> multiqueue qdiscs can't be really given such unique per dev
> 
>> (instead of per queue) handles?

In my opinion the best way would be to sum up the stats and display
them for the "main" qdisc to avoid any compatibility problems and
additionally dump each queue for informational purposes.

This raises a few more questions however. First of all, there's no
"main" qdisc, so if we just use the first one for the summed up stats,
the question is whether the parameters of all root qdiscs are the same.
Currently they should be since pfifo_fast doesn't support changing
parameters, but this might change in the future, in which case we
might be displaying "incorrect" parameters.

The next question would be whether and how to support changing
parameters of individual multiq qdiscs. Similar to dumps, when
changing qdisc parameters we always pick queue number 0. It we want
to support changing parameters of different queues, we could
replicate changes to all queues, which would avoid the problem
stated above, or we could add an optional identifier for the
queue number, or we could use a combination of both which only
replicates settings when no queue number is specified.

In the second and third case, one possibility to get around the
incorrect parameters for the "main" qdisc would be to display
a virtual (non-existant) qdisc as the root, which only contains
the stats. I don't think the default choice of root qdisc type
should be counted as belonging to the API and userspace should
be prepared to deal with this.

And finally, the TC API used to be symetrical in the sense that
you could replay a dump to the kernel to get the same configuration.
Dumping the individual queues would break that property unless
we also support creating and configuring them in a symetrical
fashion.

So here's something of a possible solution, assuming that at some
point we do want to support changing parameters for individual root
qdiscs and taking the above into account:

- when creating a qdisc on a multiqueue-device through the TC
  API, we keep the current behaviour and share it between all
  queues. Configuration changes don't need to be replicated since
  the qdisc is shared. Dumps only contain a single instance of
  the qdisc. This is exactly what is done today.

- for non-shared root qdiscs on a multiqueue device like the
  pfifo_fast qdiscs created by default, we dump a virtual root
  qdisc (multiqueue) which only contains the number of bands
  and the statistics and dump the real root qdiscs as children
  of that qdisc.

- to create or configure a qdisc for a specific queue number, we
  require the user to create the virtual root qdisc (which only
  sets a flag or something like that) and then address each queue
  number. When the virtual qdisc has been created, we don't
  replicate any changes. This restores symetry with dumps and
  allows to address individual queues.

This is just a first collection of thoughts and probably can be
improved. Comments welcome :)

