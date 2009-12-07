From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Tue, 8 Dec 2009 00:38:01 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912080023590.27565@melkinpaasi.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba>
 <4B1ADF79.6000101@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912071532080.7024@wel-95.cs.helsinki.fi> <20091207231804.23baebd2@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-658249380-1260225482=:27565"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60695 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757642AbZLGWiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 17:38:00 -0500
In-Reply-To: <20091207231804.23baebd2@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-658249380-1260225482=:27565
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Trimmed Ccs.

On Mon, 7 Dec 2009, Frederic Leroy wrote:

> Le Mon, 7 Dec 2009 16:01:53 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Sat, 5 Dec 2009, Damian Lukowski wrote:
> > 
> > > Could you please make another test and unplug the cable or drop
> > > [...]
> > After taking some more look into this, this is partly a red herring.
> > It looks like that because of the place of the printk that was still
> > in the end of the function. You can see the full trace of what
> > happens in .13., they come from independent incarnations of RTO
> > recovery (when finally no error happens in tcp_retransmit_skb).
> 
> Doh ! Sorry :( 

Now I think we have had just too many testcases and are all confused :-).
I was referring to the case .11. (the same case as Damian did) ...Not 
something too newish you did, sorry about that.

> > However, the problem itself could occur. Here's the patch which
> > should prevent that (I'm rather convinced that this really isn't
> > stable worthy but net-next or net-2.6 would be fine):
> > 
> > --
> > [PATCH] tcp: fix retrans_stamp advancing in error cases
> > [...]
> 
> Tonight, I made 2 more tests : .20 and .21 . 
> 
> The first with latest damian patch from today.
> Added the printk (This time I doubled checked ;).
> Start the copy, wait 20s, disconnect cable 20s, reconnect. 
> 
> The second try was identical, but I added your patch.
> The copy was slower comparing to the first try.

The losses you are getting are somewhat random process, so it is usually 
the main explination on different transfer rates. One thing leads to 
another and therefore one case suffers more than other.

> I didn't took time to understand tcp retransmission timeout and read
> the code. So, I'm not sure the printk is at the good place and usefull.

Thanks anyway for all testing so far. I'll try to come up with the other 
debug patch tomorrow to get some information on that -EAGAIN. Unless you 
want to do it yourself and printk all the variables involved in this check 
(in tcp_output.c):

        /* Do not sent more than we queued. 1/4 is reserved for possible
         * copying overhead: fragmentation, tunneling, mangling etc.
         */
        if (atomic_read(&sk->sk_wmem_alloc) >
            min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
                return -EAGAIN;

...better to print them before the check it regardless of the actual 
result of the comparison.


...So far only the Damian's patch is clearly required for stable (but I 
suppose DaveM will handle the stable submissions as usual, hopefully it 
won't take too long though as some other people might start reporting this 
same issue once some time has passed and they notice that something is 
wrong with TCP of their new and shiny 2.6.32 :-)).


-- 
 i.
---696230645-658249380-1260225482=:27565--
