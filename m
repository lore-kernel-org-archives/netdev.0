From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] multiqueue changes
Date: Wed, 28 Oct 2009 18:27:10 +0100
Message-ID: <4AE87EEE.4020703@trash.net>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local> <20091008120039.GA8691@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62060 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbZJ1R1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:27:12 -0400
In-Reply-To: <20091008120039.GA8691@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Oct 08, 2009 at 09:03:44AM +0000, Jarek Poplawski wrote:
> ...
>> num_tx_queues. But it seems we should rather use more often
>> real_num_tx_queue in schedulers code like dumps and maybe more
>> (like e.g. sch_multiq does).
> 
> ...i.e. probably everywhere between dev_activate and dev_deactivate
> all qdisc operations could use real_num_tx_queues (including a test
> like: netif_is_real_multique), unless I miss something.

We don't seem to be supporting changing real_num_tx_queues for
registered devices currently (at least I couldn't find it).
So I guess it depends on how this would be implemented.

Simply changing the dev->real_num_tx_queues value while the
device is down would require qdisc operations to operate on
all possible queues since the amount of queues in use could
be changed after the qdisc is created/configured, but before
the device is set up. This approach has more complications
like switching between mq and non-mq root qdiscs, taking care
of non-default root qdisc (cloning them to the new queues), etc.

A simpler alternative would be to destroy the existing root
qdisc on any change to real_num_tx_queues and have dev_activate()
set it up from scratch. In this case, we could (as you suggested)
use real_num_tx_queues, which should fix the problem Eric reported.
