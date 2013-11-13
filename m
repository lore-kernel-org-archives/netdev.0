From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 13 Nov 2013 08:22:57 +0100
Message-ID: <20131113072257.GB10591@1wt.eu>
References: <8761s0cqhh.fsf@natisbad.org> <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu> <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu> <87vbzxd473.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
	stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vbzxd473.fsf@natisbad.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 04:34:24PM +0100, Arnaud Ebalard wrote:
> Hi,
> 
> Willy Tarreau <w@1wt.eu> writes:
> 
> > On Tue, Nov 12, 2013 at 10:14:34AM +0100, Arnaud Ebalard wrote:
> >> Tests for the rgression were done w/ scp, and were hence limited by the
> >> crypto (16MB/s using arcfour128). But I also did some tests w/ a simple
> >> wget for a file served by Apache *before* the regression and I never got
> >> more than 60MB/s from what I recall. Can you beat that? 
> >
> > Yes, I finally picked my mirabox out of my bag for a quick test. It boots
> > off 3.10.0-rc7 and I totally saturate one port (stable 988 Mbps) with even
> > a single TCP stream.
> 
> Thanks for the feedback. That's interesting. What are you using for your tests
> (wget, ...)? 

No, inject (for the client) + httpterm (for the server), but it also works with
a simple netcat < /dev/zero, except that netcat uses 8kB buffers and is quickly
CPU-bound. The tools I'm talking about are available here :

  http://1wt.eu/tools/inject/?C=M;O=D
  http://1wt.eu/tools/httpterm/httpterm-1.7.2.tar.gz

Httpterm is a dummy web server. You can send requests like
"GET /?s=1m HTTP/1.0" and it returns 1 MB of data in the response,
which is quite convenient! I'm sorry for the limited documentation
(don't even try to write a config file, it's a fork of an old haproxy
version). Simply start it as :

     httpterm -D -L ip:port    (where 'ip' is optional)

Inject is an HTTP client initially designed to test applications but still
doing well enough for component testing (though it does not scale well with
large numbers of connections). I remember that Pablo Neira rewrote a simpler
equivalent here : http://1984.lsi.us.es/git/http-client-benchmark, but I'm
used to use my old version.

There's an old doc in PDF in the download directory. Unfortunately it
speaks french which is not always very convenient. But what I like there
is that you get one line of stats per second so you can easily follow how
the test goes, as opposite to some tools like "ab" which only give you a
summary at the end. That's one of the key points that Pablo has reimplemented
in his tool BTW.

> > With two systems, one directly connected (dockstar) and the other one via
> > a switch, I get 2*650 Mbps (a single TCP stream is enough on each).
> >
> > I'll have to re-run some tests using a more up to date kernel, but that
> > will probably not be today though.
> 
> Can you give a pre-3.11.7 kernel a try if you find the time? I started
> working on RN102 during 3.10-rc cycle but do not remember if I did the
> first preformance tests on 3.10 or 3.11. And if you find more time,
> 3.11.7 would be nice too ;-)

Still have not found time for this but I observed something intriguing
which might possibly match your experience : if I use large enough send
buffers on the mirabox and receive buffers on the client, then the
traffic drops for objects larger than 1 MB. I have quickly checked what's
happening and it's just that there are pauses of up to 8 ms between some
packets when the TCP send window grows larger than about 200 kB. And
since there are no drops, there is no reason for the window to shrink.
I suspect it's exactly related to the issue explained by Eric about the
timer used to recycle the Tx descriptors. However last time I checked,
these ones were also processed in the Rx path, which means that the
ACKs that flow back should have had the same effect as a Tx IRQ (unless
I'd use asymmetric routing, which was not the case). So there might be
another issue. Ah, and it only happens with GSO.

I really need some time to perform more tests, I'm sorry Arnaud, but I
can't do them right now. What you can do is to try to reduce your send
window to 1 MB or less to see if the issue persists :

   $ cat /proc/sys/ipv4/tcp_wmem
   $ echo 4096 16384 1048576 > /proc/sys/ipv4/tcp_wmem

You also need to monitor your CPU usage to ensure that you're not limited
by some processing inside apache. At 1 Gbps, you should use only something
like 40-50% of the CPU.

Cheers,
Willy
