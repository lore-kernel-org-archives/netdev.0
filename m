From: Julia Lawall <julia@diku.dk>
Subject: Re: Subject: [PATCH] net/ipv6: Use GFP_ATOMIC when a lock is held
Date: Sun, 30 May 2010 23:09:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005302303180.19253@ask.diku.dk>
References: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
 <1275250288.2472.21.camel@edumazet-laptop>  <Pine.LNX.4.64.1005302248500.19253@ask.diku.dk>
 <1275252912.2472.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1939877005-1275253536=:19253"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275252912.2472.23.camel@edumazet-laptop>
Content-ID: <Pine.LNX.4.64.1005302305590.19253@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1939877005-1275253536=:19253
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.1005302305591.19253@ask.diku.dk>

On Sun, 30 May 2010, Eric Dumazet wrote:

> Le dimanche 30 mai 2010 à 22:50 +0200, Julia Lawall a écrit :
> 
> > I think the proposed patch does not work, because the for loop overwrites 
> > p.  That use of p looks like it is completely local to the for loop, so 
> > perhaps a new variable p1 could be added to be used there?
> 
> Please do so.
> 
> I just wanted to tell you changing GFP_KERNEL to GFP_ATOMIC is not an
> appropriate way to solve this kind of problems. My patch was to get an
> idea, not a full and tested patch :)

Looking at it again, there is still a problem, because in the original 
code, the loop:

        for (p = t->prl; p; p = p->next) {
                if (p->addr == a->addr) {
                        if (chg) {
                                p->flags = a->flags;
                                goto out;
                        }
                        err = -EEXIST;
                        goto out;
                }
        }

could exit with success without the kzalloc ever being called.  If the 
kzalloc is moved up, it could fail and then it returns immediately without 
executing the loop.  A solution could be to leave the NULL test on p where 
it is, and only move up the kzalloc.  Or perhaps the change in behavior 
doesn't matter?

julia
---511516320-1939877005-1275253536=:19253--
