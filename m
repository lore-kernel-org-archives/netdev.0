From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 29 Sep 2004 10:53:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096451623.415a862783d87@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: pablo@eurodev.net, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, herbert@gondor.apana.org.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Re: async netlink messages

Is it possible to deliver async messages to userspace using a polling
mechanism to help solve the overrun problem?

- Have the kernel keep a list of async messages sent towards each
  socket rather than trying to deliver each message to the app
  immediately.  Have the kernel send a netlink event message (say,
  NETLINK_EVENT_WAKEUP) to the app when this queue first goes
  non-empty. No new NETLINK_EVENT_WAKEUP messages are sent until the
  event queue goes empty again.

- On receipt of NETLINK_EVENT_WAKEUP, a process issues a netlink
  GET (or DUMP?) on its netlink socket to read its queued events.

- If the socket event queue overruns, discard new events and flag the
  event queue as having lost messages. When the userspace app reads
  the event queue, it will discover that messages have been lost and
  can then re-read state from the kernel.

- Use a setsockopt on the netlink socket to have the socket configured
  in this polled-event mode.

Just a thought.

/james


-----Original Message-----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
Sent: 28 September 2004 04:59
To: hadi@cyberus.ca
Cc: pablo@eurodev.net,  davem@davemloft.net, netdev@oss.sgi.com
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets

On Mon, Sep 27, 2004 at 11:45:25PM -0400, jamal wrote:
>
> > Now that we know where the events are coming from and what they are,
> > we can decide on the solution.  In this particular case, there is
> > nothing you can do on the sending side.  Stopping people from operating
> > on networking objects just because some netlink listener can't keep up
> > isn't going to work.  So congestion control is out of the question.
>
> fixing the NLM_GOODSIZE issue is a very good first step.

Well I'm afraid that it doesn't help in your interface address example
because rtmsg_ifa() already allocates a buffer of (approximately) the
right size.  That is, it doesn't use NLM_GOODSIZE at all.

> Adding congestion control would be harder but not out of question.

But the question is who are you going to throttle? If you throttle
the source of the messages then you're going to stop people from adding
or deleting IP addresses which can't be right.

If you move the netlink sender into a different execution context and
throttle that then that's just extending the receive queue length by
stealth.

So I'm afraid I don't see how congestion control could be applied in
*this* particular context.

> > So just bite the bullet and reread the system state by issuing dump
> > operations.
>
> We may as well choose to document it as being this mostly because of the
> issue i described above. We shouldnt give up so easily though ;->

Well IMHO this is not giving up at all.

Think of it another way.  Monitoring routes is like maintaining a
program.  Normally you just fix the bugs as they come.  But if the
bug reports are coming in so fast that you can't keep up, perhaps
it's time to throw it away and rewrite it from scratch :)
--
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt






----- End forwarded message -----
