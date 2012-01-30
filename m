From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Bug#656476: Sundance network driver (D-Link DFE-580TX) timeouts rendering interface unusable
Date: Mon, 30 Jan 2012 11:14:07 +0100
Message-ID: <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	 <1327205171.8004.96.camel@deadeye>
	 <SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	 <20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
	 <1327811546.5400.291.camel@deadeye>
	 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
Reply-To: Eric Dumazet <eric.dumazet@gmail.com>, 656476@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Ben Hutchings <ben@decadent.org.uk>, "Mike ."
 <mike-bugreport@hotmail.com>,  656476@bugs.debian.org, netdev
 <netdev@vger.kernel.org>
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.656476.B656476.13279184631339@bugs.debian.org>
In-Reply-To: <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Le lundi 30 janvier 2012 =C3=A0 12:51 +0300, Denis Kirjanov a =C3=A9crit =
:
> I'll check this out. After kernel.org was cracked I've missed
> @kernel.org mail account.


At first glance, start_tx() is racy against TX completion.

It does :

        if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1 &&
            !netif_queue_stopped(dev)) {
                /* do nothing */
        } else {
                netif_stop_queue (dev);
        }

So it can call netif_stop_queue() while TX completion handler did a
cleanup of all queued packets right before.


Note intr_handler() doesnt hold the queue spinlock when it does :

                if (netif_queue_stopped(dev) &&
                        np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
                        /* The ring is no longer full, clear busy flag. *=
/
                        netif_wake_queue (dev);
                }





--=20
To UNSUBSCRIBE, email to debian-bugs-dist-REQUEST@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian=
.org
