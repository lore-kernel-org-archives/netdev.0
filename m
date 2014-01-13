From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending
 refcount
Date: Mon, 13 Jan 2014 09:55:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D458F61@AcuExch.aculab.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
	<1389543768-20234-4-git-send-email-dborkman@redhat.com>
 <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: 'Cong Wang' <cwang@twopensource.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51071 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750991AbaAMJ5T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 04:57:19 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18521-01 for <netdev@vger.kernel.org>;
 Mon, 13 Jan 2014 09:57:15 +0000 (GMT)
In-Reply-To: <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang
> On Sun, Jan 12, 2014 at 8:22 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> > +static void packet_inc_pending(struct packet_ring_buffer *rb)
> > +{
> > +       this_cpu_inc(*rb->pending_refcnt);
> > +}
> > +
> > +static void packet_dec_pending(struct packet_ring_buffer *rb)
> > +{
> > +       this_cpu_dec(*rb->pending_refcnt);
> > +}
> > +
> > +static int packet_read_pending(const struct packet_ring_buffer *rb)
> > +{
> > +       int i, refcnt = 0;
> > +
> > +       /* We don't use pending refcount in rx_ring. */
> > +       if (rb->pending_refcnt == NULL)
> > +               return 0;
> > +
> > +       for_each_possible_cpu(i)
> > +               refcnt += *per_cpu_ptr(rb->pending_refcnt, i);
> > +
> > +       return refcnt;
> > +}
> 
> How is this supposed to work? Since there is no lock,
> you can't read accurate refcnt. Take a look at lib/percpu_counter.c.
> 
> I guess for some reason you don't care the accuracy?
> Then at least you need to comment in the code.

Hmmm... did the code ever work?

The value looks like the number of active transmits (s/pending/tx_pending/)
The test of the number of pending tx is at the bottom of a code loop,
I'd expect that some action should be locked against this check - but even
the atomic read doesn't do this.

Check what happens if the count reads as 1 just before another cpu
decrements it to zero (or reads 0 just before being incremented).
In one of those cases something is likely to go wrong.

I'm actually surprised that there isn't a mutex covering the code path.

	David
