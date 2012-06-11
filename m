From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: net: nfc: BUG and panic in accept() on 3.5-rc2
Date: Mon, 11 Jun 2012 16:50:41 +0200
Message-ID: <1339426241.4999.62.camel@lappy>
References: <1339423241.4999.53.camel@lappy>
	 <20120611144134.GX22557@sortiz-mobl>
	 <1339425693.6001.2268.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <sameo@linux.intel.com>,
	David Miller <davem@davemloft.net>,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339425693.6001.2268.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 16:41 +0200, Eric Dumazet wrote:
> On Mon, 2012-06-11 at 16:41 +0200, Samuel Ortiz wrote:
> > Hi Sasha,
> > 
> > On Mon, Jun 11, 2012 at 04:00:41PM +0200, Sasha Levin wrote:
> > > Hi all,
> > > 
> > > I've stumbled on the following while fuzzing with trinity inside a KVM tools guest, running on 3.5-rc2:
> > > 
> > Thanks for the report, it could be worth adding this one to
> > bugzilla.kernel.org.
> > 
> > What's trinity ?
> > Also, if this one is reproducible, would you mind sharing some details about
> > how we could reproduce it ?
> 
> Well, bugfix should be trivial enough ;)
> 
> diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
> index ec1134c..208416e 100644
> --- a/net/nfc/rawsock.c
> +++ b/net/nfc/rawsock.c
> @@ -54,11 +54,12 @@ static int rawsock_release(struct socket *sock)
>  {
>  	struct sock *sk = sock->sk;
>  
> -	pr_debug("sock=%p\n", sock);
> -
> -	sock_orphan(sk);
> -	sock_put(sk);
> +	pr_debug("sock=%p sk=%p\n", sock, sk);
>  
> +	if (sk) {
> +		sock_orphan(sk);
> +		sock_put(sk);
> +	}
>  	return 0;
>  }

Eric, Is there something that documents at what state each of the
callbacks in the network subsystem can be called? Like a big flow chart
of some sorts?

I'm asking because I've looked at this as well before sending this mail,
and while the fix does look trivial, I wasn't sure whether it is really
the correct fix, or the problem is that this callback wasn't supposed be
called at all so something else is broken (we had such issue with
namespaces and unshare() not long ago).
