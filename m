From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] can't unload network device's if IPV6 is loaded
Date: Thu, 18 Dec 2003 16:35:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031218163550.572cc9b1.shemminger@osdl.org>
References: <20031211153334.0c59214b.shemminger@osdl.org>
	<E1AUlxI-00060F-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "YOSHIFUJI Hideaki /
 _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@redhat.com>
In-Reply-To: <E1AUlxI-00060F-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Dec 2003 22:59:36 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Stephen Hemminger <shemminger@osdl.org> wrote:
> > In 2.6.0-test11, IPV6 is not correctly cleaning up the network device reference's
> > (ie missing dev_put).  So if I do:
> >        rmmod e100
> > it hangs forever and complains about that not all references have been cleaned up.
> > 
> > This happens even if no IPV6 addresses have been set up. Just having ipv6 available
> > to be loaded at boot up.  The vendor startup scripts (SuSe 9) may be setting something.

Okay, I have a clue about this.. I can reproduce the problem with even
the dummy device.  If the device is removed before the address configuration
timers have completed then it will hang.

Assuming IPV6 is already in the kernel.

Works:
	modprobe dummy; ifconfig dummy0 10.0.0.1; sleep 90; rmmod dummy
Fails:
	modprobe dummy; ifconfig dummy0 10.0.0.1; rmmod dummy

Looks like some tentative entries are floating is space and not in the dst
cache so they don't get destroyed by the notification process.
