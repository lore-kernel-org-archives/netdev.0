From: Terje Eggestad <terje.eggestad@scali.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: 04 Mar 2003 00:29:24 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1046734165.27924.263.camel@eggis1>
References: <3E5E7081.6020704@nortelnetworks.com>	<1046695876.7731.78.camel@pc-16.office
	.scali.no> 	<3E638C51.2000904@nortelnetworks.com>
	<1046720360.28127.209.camel@eggis1>  <3E63D73A.2000402@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, davem@redhat.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3E63D73A.2000402@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

My point is that you can't send a request real work with either shm nor
multicast. You don't know who or howmany recipients there are. You just
use it to update someone that do real work. Then they tend not to need
it until they get a request for real work, then alost always on a tcp
connection or as audp (unicast) message.

How do you design a protocol that uses multicast to send a request to do
work?

All uses I can think of right now of multicast/broadcast is:
* Discovery, like in NIS.
* Announcements like in OSPF. 
* update like in NTP broadcast

DHCP is actually a nice example of very very bad things that happen if
you loose control of how many servers that are running.

On Mon, 2003-03-03 at 23:29, Chris Friesen wrote:
    Terje Eggestad wrote:
    > On Mon, 2003-03-03 at 18:09, Chris Friesen wrote:

    > If you *had* multicast, you don't know *when* a peer proccessed it. 
    > What if the peer is suspended ??? you don't get an error on the send,
    > and you apparently never get an answer, then what? The peer may also
    > gone haywire on a while(1);
    
    Exactly.  So if the message got delivered you have no way of knowing for 
    sure that it was processed and you have application-level timers and 
    stuff. But if the message wasn't delivered to anyone and you know it 
    should have been, then you don't have to wait for the timer to expire to 
    know that they didn't get it.
    

Nice to know, but it help you, how?

If there is a subscriber out there that is hung? You need that timer
*anyway*. Why the special case? 

All I see you're trying to do is something like this (just the
nonblocking version):


do_unix_mcast(message)
{
alarm(timeout);

rc = write(fd_unixmultocast, message, mlen);

if (rc == -1   && errno == nosubscribers) goto they_are_all_dead;

rc = select( fd_unixmultocast ++);
if (rc == -1  && errno = EINTR) goto they_are_all_dead;
alarm(0);
process_reply();
return;

they_all_dead:

handle_all_dead_peers();
return;
};
    
    Chris
    
    
    -- 
    Chris Friesen                    | MailStop: 043/33/F10
    Nortel Networks                  | work: (613) 765-0557
    3500 Carling Avenue              | fax:  (613) 765-2986
    Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
-- 
_________________________________________________________________________

Terje Eggestad                  mailto:terje.eggestad@scali.no
Scali Scalable Linux Systems    http://www.scali.com

Olaf Helsets Vei 6              tel:    +47 22 62 89 61 (OFFICE)
P.O.Box 150, Oppsal                     +47 975 31 574  (MOBILE)
N-0619 Oslo                     fax:    +47 22 62 89 51
NORWAY            
_________________________________________________________________________

