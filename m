From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Thu, 19 May 2005 14:23:19 +0200
Message-ID: <20050519122319.GH15391@postel.suug.ch>
References: <428B6B72.5010407@hp.com> <E1DYWM2-0004jM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DYWM2-0004jM-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1DYWM2-0004jM-00@gondolin.me.apana.org.au> 2005-05-19 07:45
> Rick Jones <rick.jones2@hp.com> wrote:
> > If we ass-u-me that the sender is indeed using a random IP ID assignment 
> > mechanism, 30000 is probably too many.  There are only 65536 possible ID's, and 
> > if we "choose" 30000 of them there will undoubtedly be many duplicated.  Someone 
> > who didn't fall asleep too often in ProbStats (unlike myself) can probably tell 
> > us just how many.
> 
> IMHO hosts using purely random IDs all the time are fundamentally broken
> for applications such as NFS over UDP over gigabit.  However, in order
> to handle such hosts we should make this threshold configurable and
> then those who need it can set it to a value like 600 which gives a
> collision probability with the first fragment of just less than 1%.

I agree, however defining a value of 600 system wide is horrible for
all hosts that behave "correctly". So what we could do is take probes
of the id distribution and define the threshold on a per peer scope.

Example: Once in a while we start a probe and set a bit in a bitmap
for every id that matches a defined window. Not sure about the size of
that bitmap yet but 2048 bits might be a good start. The first fragment
id received during the probe defines the lower bound of the window and
the probe lasts until we received 2048 fragment ids. Once the probe
is finished we calculate the ratio between set and unset bits and
calculate the threshold. Additionaly we can define a threshold of bits
set to figure out if the peer is likely to use a counter for id
generation, if so we can set a flag which switches from counting
fragment ids to calculating the delta between the fragment id subject
to expiration and the current last fragment id. So basically we
would have two different modes, the "difficult peer"-mode for peers
using random ids or if we only see a very small portion of the effective
id space and a "counters"-mode for all peers using counters.

The "counters"-mode can offer a nearly perfect solution to detect
wraps without suffering from side effects such as droping perfectly
legal fragments.

This idea relies on the fact that the result of the probe stays
true for some time which might not be true but is probably fair
enough.
