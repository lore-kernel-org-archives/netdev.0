From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 2 Mar 2007 15:29:05 -0500
Message-ID: <200703021529.05902.alexandre.sidorenko@hp.com>
References: <200703021128.29208.alexandre.sidorenko@hp.com> <45E872F5.2030102@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:50934 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965109AbXCBU2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 15:28:51 -0500
In-Reply-To: <45E872F5.2030102@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On March 2, 2007 01:54:45 pm John Heffner wrote:
> Alex Sidorenko wrote:
> [snip]
>
> > --- net/ipv4/tcp_output.c.orig  Wed May  3 20:40:43 2006
> > +++ net/ipv4/tcp_output.c       Tue Jan 30 14:24:56 2007
> > @@ -641,6 +641,7 @@
> >   * Note, we don't "adjust" for TIMESTAMP or SACK option bytes.
> >   * Regular options like TIMESTAMP are taken into account.
> >   */
> > +static const char *SWS_id_string="@#SWS-fix-2";
> >  u32 __tcp_select_window(struct sock *sk)
> >  {
> >         struct tcp_opt *tp = &sk->tp_pinfo.af_tcp;
> > @@ -682,6 +683,9 @@
> >         window = tp->rcv_wnd;
> >         if (window <= free_space - mss || window > free_space)
> >                 window = (free_space/mss)*mss;
> > +        /* A fix for small rcvbuf asid@hp.com */
> > +       else if (mss == full_space && window < full_space/2)
> > +               window = full_space/2;
> >
> >         return window;
> >  }
>
> Good analysis of the problem, but the patch does not look quite right.
> In particular, you can't ever announce a zero window. :)

Hi John,

in case when (free_space < full_space/2) we do not reach the modified code and
we will return zero:

    if (free_space < full_space/2) {
            icsk->icsk_ack.quick = 0;
             if (tcp_memory_pressure)
                    tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U*tp->advmss);
             if (free_space < mss)
                    return 0;
    }

Here is how windows look with the fixed kernel (from customer's test):

20:59:45.320758 Node1.logical.40171 > 11.0.0.1.39909: win = 708
20:59:45.322758 Node1.logical.40171 > 11.0.0.1.39909: win = 288
20:59:45.714567 Node1.logical.40171 > 11.0.0.1.39909: win = 354
20:59:45.717110 Node1.logical.40171 > 11.0.0.1.39909: win = 0
20:59:45.719110 Node1.logical.40171 > 11.0.0.1.39909: win = 708
...

Regards,
Alex

> I think this attached patch does the correct SWS avoidance.
>
> Thanks,
>    -John



-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
