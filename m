From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getsockopt/setsockopt with SO_RCVBUF and SO_SNDBUF
 "non-standard" behaviour
Date: Wed, 18 Jul 2012 18:11:15 +0200
Message-ID: <1342627875.2626.3070.camel@edumazet-glaptop>
References: <50052FFE.2060109@pu-pm.univ-fcomte.fr>
	 <5006DD6B.3030300@pu-pm.univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eugen Dedu <Eugen.Dedu@pu-pm.univ-fcomte.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5006DD6B.3030300@pu-pm.univ-fcomte.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-07-18 at 17:59 +0200, Eugen Dedu wrote:
> Any idea?
> 
> On 17/07/12 11:27, Eugen Dedu wrote:
> > Hi all,
> >
> > I looked on Internet and at the old thread
> > http://lkml.indiana.edu/hypermail/linux/kernel/0108.0/0275.html, but the
> > issue is still not settled as far as I see.
> >
> > I need to have the highest memory available for snd/rcv buffer and I
> > need to know/confirm how much it allocated for my process (how much I
> > can use).
> >
> > So with Linux we need to do something like:
> > setsockopt (..., SO_RCVBUF, 256000, ...)
> > getsockopt (..., SO_RCVBUF, &i, ...)
> > i /= 2;
> >
> > where i is the size I am looking for.
> >
> > Now, to make this code work for other OSes it should be changed to:
> > setsockopt (..., SO_RCVBUF, 256000, ...)
> > getsockopt (..., SO_RCVBUF, &i, ...)
> > #ifdef LINUX
> > i /= 2;
> > #endif
> >
> > First question, is this code correct? If not, what code gives the amount
> > of memory useable for my process?
> >
> > Second, it seems to me that linux is definitely "non-standard" here.
> > Saying that linux uses twice as memory has nothing to do with that,
> > since getsockopt should return what the application can count on, not
> > what is the internal use. It is like a hypothetical malloc (10) would
> > return not 10, but 20 (including meta-information). Is that right?
> >
> > Cheers,

That the way it's done on linux since day 0

You can probably find a lot of pages on the web explaining the
rationale.

If your application handles UDP frames, what SO_RCVBUF should count ?

If its the amount of payload bytes, you could have a pathological
situation where an attacker sends 1-byte UDP frames fast enough and
could consume a lot of kernel memory.

Each frame consumes a fair amount of kernel memory (between 512 bytes
and 8 Kbytes depending on the driver).

So linux says : If user expect to receive  XXXX bytes, set a limit of
_kernel_ memory used to store these bytes, and use an estimation of 100%
of overhead. That is : allow 2*XXXX bytes to be allocated for socket
receive buffers.
