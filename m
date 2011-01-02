From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Mon, 3 Jan 2011 00:04:32 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>  <1294008562.2535.263.camel@edumazet-laptop> <1294008917.18963.3.camel@wall-e>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1374685088-1294009472=:11481"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com,
	daniel.baluta@gmail.com, jochen@jochen.org
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294008917.18963.3.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1374685088-1294009472=:11481
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Sun, 2 Jan 2011, Stefani Seibold wrote:

> Am Sonntag, den 02.01.2011, 23:49 +0100 schrieb Eric Dumazet:
> > Le dimanche 02 janvier 2011 à 23:39 +0100, stefani@seibold.net a écrit :
> > > +
> > > +/*
> > > + * Create a new destination descriptor for the given IPV4 address and port
> > > + */
> > > +static struct udpcp_dest *new_dest(struct sock *sk, __be32 addr, __be16 port)
> > > +{
> > > +	struct udpcp_dest *dest;
> > > +	struct udpcp_sock *usk = udpcp_sk(sk);
> > > +
> > > +	if (usk->connections >= udpcp_max_connections)
> > > +		return NULL;
> > > +
> > > +	dest = kzalloc(sizeof(*dest), sk->sk_allocation);
> > > +
> > > +	if (dest) {
> > > +		usk->connections++;
> > > +		skb_queue_head_init(&dest->xmit);
> > > +		dest->addr = addr;
> > > +		dest->port = port;
> > > +		dest->ackmode = UDPCP_ACK;
> > > +		list_add_tail(&dest->list, &usk->destlist);
> > > +	}
> > > +
> > > +	return dest;
> > > +}
> > > +
> > 
> > Hmm, so 'connections' is increased, never decreased.
> > 
> > This seems a fatal flaw in this protocol, since a malicious user can
> > easily fill the list with garbage, and block regular communications.
> 
> You are right, there is now way to detect which connection is no longer
> needed. I have not designed this protocol, so i cannot fix it. 
> 
> But in our environment this will be used together with an firewall
> and/or ipsec. In this case it it safe.
> 

Hmm, the first thing that springs into my head as a possible band-aid 
(which is probbaly wrong for many reasons I've not considered, so feel 
free to shoot it down) is; couldn't we use a timer (set to some outrageous 
high value by default and admin tunable) that would decrement 
'connections' (discount dead connections) when there has not been any 
acctivity for a huge period of time? Kill off connections that have been 
idle for ages.

Not perfect, but that would at least let the system recover after a while 
if a malicious client did something nasty with many connections...


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-1374685088-1294009472=:11481--
