From: bert hubert <ahu@ds9a.nl>
Subject: Re: off by one error in 3des cbc keying
Date: Mon, 11 Nov 2002 21:03:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021111200321.GA30957@outpost.ds9a.nl>
References: <20021111100109.GB18677@outpost.ds9a.nl> <200211111718.UAA27829@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211111718.UAA27829@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2002 at 08:18:55PM +0300, kuznet@ms2.inr.ac.ru wrote:

> Unlikely. I think while our network is down list exploders just
> drop mails unlike normal mail agents. :-)

Yeah - I had this vague idea maybe you read this list from another address
:-)

> > I wonder, is 'incoming bypass' implemented yet?
> 
> It is. But your example shows that something is wrong there. Fix will follow
> later.

Ok, let me know if I can test. The IPSEC pages on lartc now have had over
3000 real visits, by the way. This is a lot.

> What does happen in logs/setkey -D? Actually, before sending previous
> large patch dealing with expire timers I got it to the point where keys

Communications work, then *something* expires after 30 seconds, and then
there is 10 minute where everything works. Then things break down, and after
a while, renegotiation succeeds. Racoon configuration identical to the
previous one.

Logs of setup:
20:40:12: INFO: main.c:170:main(): @(#)racoon 20001216 20001216
sakane@kame.net
20:40:12: INFO: main.c:171:main(): @(#)This product linked
OpenSSL 0.9.6c 21 dec 2001 (http://www.openssl.org/)
20:40:12: INFO: isakmp.c:1365:isakmp_open(): 127.0.0.1[500] used
as isakmp port (fd=7)
20:40:12: INFO: isakmp.c:1365:isakmp_open(): 10.0.0.216[500] used
as isakmp port (fd=8)
20:40:12: ERROR: isakmp.c:1357:isakmp_open(): failed to bind
(Address already in use).
20:40:12: ERROR: isakmp.c:1357:isakmp_open(): failed to bind
(Address already in use).

Tried to connect to 10.0.0.11:

20:41:06: INFO: isakmp.c:1689:isakmp_post_acquire(): IPsec-SA
request for 10.0.0.11 queued due to no phase1 found.
20:41:06: INFO: isakmp.c:794:isakmp_ph1begin_i(): initiate new
phase 1 negotiation: 10.0.0.216[500]<=>10.0.0.11[500]
20:41:06: INFO: isakmp.c:799:isakmp_ph1begin_i(): begin
Aggressive mode.
20:41:07: INFO: vendorid.c:128:check_vendorid(): received Vendor
ID: KAME/racoon
20:41:07: NOTIFY: oakley.c:2037:oakley_skeyid(): couldn't find
the proper pskey, try to get one by the peer's address.
20:41:07: INFO: isakmp.c:2417:log_ph1established(): ISAKMP-SA
established 10.0.0.216[500]-10.0.0.11[500]
spi:7f7352a7dbd917ba:087da64152cda86a
20:41:07: INFO: isakmp.c:938:isakmp_ph2begin_i(): initiate new
phase 2 negotiation: 10.0.0.216[0]<=>10.0.0.11[0]
20:41:07: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)
20:41:07: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)

After thirty seconds:
20:41:36: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 

After a few minutes, lifetime is 10 minutes:
20:49:07: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)
20:49:07: INFO: isakmp.c:938:isakmp_ph2begin_i(): initiate new
phase 2 negotiation: 10.0.0.216[0]<=>10.0.0.11[0]
20:49:07: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)
20:49:07: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)
20:49:07: ERROR: pfkey.c:206:pfkey_handler(): pfkey ADD failed:
File exists

Period of silence:
20:51:07: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)
20:51:07: INFO: isakmp.c:938:isakmp_ph2begin_i(): initiate new
phase 2 negotiation: 10.0.0.216[0]<=>10.0.0.11[0]
20:51:07: INFO: isakmp.c:1521:isakmp_ph1expire(): ISAKMP-SA
expired 10.0.0.216[500]-10.0.0.11[500] spi:7f7352a7dbd917ba:087da64152cda86a
20:51:07: ERROR: isakmp.c:1741:isakmp_post_getspi(): the
negotiation is stopped, because there is no suitable ISAKMP-SA.
20:51:07: ERROR: pfkey.c:894:pk_recvgetspi(): failed to start
post getspi.
20:51:08: INFO: isakmp.c:1521:isakmp_ph1expire(): ISAKMP-SA
expired 10.0.0.216[500]-10.0.0.11[500] spi:7f7352a7dbd917ba:087da64152cda86a
20:51:09: INFO: isakmp.c:1569:isakmp_ph1delete(): ISAKMP-SA
deleted 10.0.0.216[500]-10.0.0.11[500] spi:7f7352a7dbd917ba:087da64152cda86a

20:51:36: INFO: isakmp.c:1689:isakmp_post_acquire(): IPsec-SA
request for 10.0.0.11 queued due to no phase1 found.
20:51:36: INFO: isakmp.c:794:isakmp_ph1begin_i(): initiate new
phase 1 negotiation: 10.0.0.216[500]<=>10.0.0.11[500]
20:51:36: INFO: isakmp.c:799:isakmp_ph1begin_i(): begin
Aggressive mode.
20:51:37: INFO: vendorid.c:128:check_vendorid(): received Vendor
ID: KAME/racoon
20:51:37: NOTIFY: oakley.c:2037:oakley_skeyid(): couldn't find
the proper pskey, try to get one by the peer's address.
20:51:37: INFO: isakmp.c:2417:log_ph1established(): ISAKMP-SA
established 10.0.0.216[500]-10.0.0.11[500]
spi:48e6122ec72e2b47:55ea41d31553b4c2
20:51:37: INFO: isakmp.c:938:isakmp_ph2begin_i(): initiate new
phase 2 negotiation: 10.0.0.216[0]<=>10.0.0.11[0]
20:51:37: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)
20:51:37: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)

20:52:06: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 

Communications now work again.

In the meantime on the responding site, 10.0.0.11:

20:51:36: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)
20:51:36: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)
20:59:36: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)
20:59:36: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)
20:59:36: INFO: isakmp.c:1045:isakmp_ph2begin_r(): respond new
phase 2 negotiation: 10.0.0.11[0]<=>10.0.0.216[0]
20:59:37: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)
20:59:37: ERROR: pfkey.c:206:pfkey_handler(): pfkey ADD failed:
File exists


setkey -DP with working communications prints the following two real
entries (on 10.0.0.11):
10.0.0.216[any] 10.0.0.11[any] tcp
	
	esp/transport//require
	created:Nov 11 20:40:56 2002 lastused:Nov 11 20:41:25 2002
	lifetime:0(s) validtime:0(s)
	spid=2296 seq=5 pid=1061
	refcnt=21
10.0.0.11[any] 10.0.0.216[any] tcp
	
	esp/transport//require
	created:Nov 11 20:40:56 2002 lastused:Nov 11 20:41:25 2002
	lifetime:0(s) validtime:0(s)
	spid=2289 seq=4 pid=1061
	refcnt=3

And the following apparently bogus ones:

0.0.0.0/0[any] 0.0.0.0/0[any] any
	in none
	created:Nov 11 20:40:58 2002 lastused:                    
	lifetime:0(s) validtime:0(s)
	spid=2323 seq=3 pid=1061
	refcnt=2
0.0.0.0/0[any] 0.0.0.0/0[any] any
	in none
	created:Nov 11 20:40:58 2002 lastused:                    
	lifetime:0(s) validtime:0(s)
	spid=2307 seq=2 pid=1061
	refcnt=2
0.0.0.0/0[any] 0.0.0.0/0[any] any
	out none
	created:Nov 11 20:40:58 2002 lastused:Nov 11 20:41:06 2002
	lifetime:0(s) validtime:0(s)
	spid=2332 seq=1 pid=1061
	refcnt=2
0.0.0.0/0[any] 0.0.0.0/0[any] any
	out none
	created:Nov 11 20:40:58 2002 lastused:                    
	lifetime:0(s) validtime:0(s)
	spid=2316 seq=0 pid=1061
	refcnt=2

Regards,

bert 

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
