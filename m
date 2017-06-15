From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip neigh: allow flush FAILED
 neighbour entry
Date: Thu, 15 Jun 2017 08:30:50 -0700
Message-ID: <20170615083050.62ed4103@xeon-e3>
References: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
        <20170614095450.3c9b5dcb@xeon-e3>
        <20170615023016.GF12974@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32922 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdFOPa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 11:30:59 -0400
Received: by mail-pf0-f177.google.com with SMTP id 83so9013844pfr.0
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 08:30:58 -0700 (PDT)
In-Reply-To: <20170615023016.GF12974@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 10:30:16 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> Hi Stephen,
> On Wed, Jun 14, 2017 at 09:54:50AM -0700, Stephen Hemminger wrote:
> > On Mon,  5 Jun 2017 16:31:29 +0800
> > Hangbin Liu <liuhangbin@gmail.com> wrote:
> >   
> > > After upstream commit 5071034e4af7 ('neigh: Really delete an arp/neigh entry
> > > on "ip neigh delete" or "arp -d"'), we could delete a single FAILED neighbour
> > > entry now. But `ip neigh flush` still skip the FAILED entry.
> > > 
> > > Let's remove this filter so we can also flush FAILED entry.
> > > 
> > > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>  
> > 
> > This might create a problem. iproute2 has to be forward/backwards compatiable
> > with multiple kernel versions. Users must be able to run newer versions of ip
> > command on older kernels.
> > 
> > What happens if you run the ip command with your patch on older kernels?
> >   
> On older kernel with tihs patch. The result is same, we could not delete
> FAILED entry. Since we could not delete it, `ip neigh` will try MAX_ROUNDS
> and fail at the end. But IMHO, this should be the correct behavoir. Because
> this is just what kernel did and what kernel fixed now.
> 
> Here is the result on old kernel:
> 
> With unpatched ip cmd
> # ip -4 neigh show dev eth1
> 192.168.1.5  FAILED
> 192.168.1.4  FAILED
> 192.168.1.3  FAILED
> 192.168.1.6  FAILED
> 192.168.1.2  FAILED
> # ip -4 neigh flush dev eth1
> # ip -4 -s neigh flush dev eth1
> Nothing to flush.
> # echo $?
> 0
> 
> With patched ip cmd
> # ./ip -4 neigh flush dev eth1
> *** Flush not complete bailing out after 10 rounds
> # ./ip -4 -s neigh flush dev eth1
> 
> *** Round 1, deleting 5 entries ***
> 
> *** Round 2, deleting 5 entries ***
> 
> *** Round 3, deleting 5 entries ***
> 
> *** Round 4, deleting 5 entries ***
> 
> *** Round 5, deleting 5 entries ***
> 
> *** Round 6, deleting 5 entries ***
> 
> *** Round 7, deleting 5 entries ***
> 
> *** Round 8, deleting 5 entries ***
> 
> *** Round 9, deleting 5 entries ***
> 
> *** Round 10, deleting 5 entries ***
> *** Flush not complete bailing out after 10 rounds
> # echo $?
> 255
> 
> But if you thought the message reallly annoying. Then how about this patch,
> which is a little tricky.
> 
> diff --git a/ip/ipneigh.c b/ip/ipneigh.c
> index 4d8fc85..9088a05 100644
> --- a/ip/ipneigh.c
> +++ b/ip/ipneigh.c
> @@ -445,7 +445,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
>                 filter.flushb = flushb;
>                 filter.flushp = 0;
>                 filter.flushe = sizeof(flushb);
> -               filter.state &= ~NUD_FAILED;
> 
>                 while (round < MAX_ROUNDS) {
>                         if (rtnl_dump_request_n(&rth, &req.n) < 0) {
> @@ -474,6 +474,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
>                                 printf("\n*** Round %d, deleting %d entries ***\n", round, filter.flushed);
>                                 fflush(stdout);
>                         }
> +                       filter.state &= ~NUD_FAILED;
>                 }
>                 printf("*** Flush not complete bailing out after %d rounds\n",
>                         MAX_ROUNDS);
> 
> 
> With this patch, the result will looks almost the same with old behavior,
> except it will filter out the FAILED entry the first time.
> 
> # ./ip -4 neigh flush dev eth1
> # ./ip -4 -s neigh flush dev eth1
> 
> *** Round 1, deleting 5 entries ***
> *** Flush is complete after 1 round ***
> # echo $?
> 0
> 
> 
> Thanks
> Hangbin

That looks better, could you send an updated patch. I will apply that
