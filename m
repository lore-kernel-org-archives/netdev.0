From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: fix a success return may hide an error
Date: Wed, 17 Aug 2016 09:01:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00E0D2A@AcuExch.aculab.com>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
 <20160812.211113.1099230839994600349.davem@davemloft.net>
 <CADvbK_dXX=Z8yr_yQPpHe2zst9uFYkMeL9-fHx17ZOCb5-x07A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00DFD69@AcuExch.aculab.com>
 <CADvbK_fsH9RAc_r6SaTKYTUJusGcZzPuCXX3zntH7UhFFWq-Cg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00E036B@AcuExch.aculab.com>
 <20160816172447.GC3110@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Xin Long' <lucien.xin@gmail.com>,
	David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:54754 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbcHQJEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 05:04:08 -0400
In-Reply-To: <20160816172447.GC3110@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 16 August 2016 18:25
...
> > That doesn't seem a good idea.
> > You don't want to abort the association if there is a transient
> > memory allocation failure.
> > You also can't drop data chunks.
> 
> From a system-wise POV, this behavior - to free the new asoc in case of
> transient memory allocation failure - doesn't seem bad to me.
> That's what will have to happen if any allocation before it failed and
> also it helps the system to reduce the stress a little bit. I don't see
> any inconsistency/problems here because we are not dropping a single
> random chunk but instead we are actually refusing to initialize a new
> asoc in such conditions.

Failing a new association should be ok, whether purists will like
connect() failing ENOMEM is another matter.

> Nevertheless, I agree that letting the application see ENOMEM errors when
> the data actually got queued and is being fully handled, as in, it will
> be retransmitted later, is not be wise, as the application probably
> won't be able to distinguish from ENOMEMs that it should retry or not.

I think an application would be justified in thinking that an ENOMEM return
meant that the system call had no effect.

For send() even ENOMEM is really wrong, it should be treated as 'flow control'
and either block or return EAGAIN/EWOULDBLOCK.
Getting POLLOUT set is left as an exercise to the reader :-)

...
> Well, it may be, but we are trying to improve it.  Please continue
> discussing the fixes so we can keep improving it. :)

Indeed, we have customers who use sctp (for M3UA).
We don't do anything 'complicated', but do end up sending a lot of short
data chunks.

	David
