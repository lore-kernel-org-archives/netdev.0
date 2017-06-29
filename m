From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 8/9] nfp: add a stats handler for flower
 offloads
Date: Thu, 29 Jun 2017 17:27:52 +0200
Message-ID: <20170629152750.GD6215@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMg6Eu+wo=P0kUDHCs_N2K=-qDeZ02sMX2wE+48snr9i2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36429 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752852AbdF2P2A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:28:00 -0400
Received: by mail-qt0-f182.google.com with SMTP id i2so77279430qta.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:28:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMg6Eu+wo=P0kUDHCs_N2K=-qDeZ02sMX2wE+48snr9i2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 06:16:41PM +0300, Or Gerlitz wrote:
> On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> >
> > Previously there was no way of updating flow rule stats after they
> > have been offloaded to hardware. This is solved by keeping track of
> > stats received from hardware and providing this to the TC handler
> > on request.
> 
> > +static void
> > +nfp_flower_update_stats(struct nfp_app *app, struct nfp_fl_stats_frame *stats)
> > +{
> > +       struct nfp_fl_payload *nfp_flow;
> > +       unsigned long flower_cookie;
> > +
> > +       flower_cookie = be64_to_cpu(stats->stats_cookie);
> > +
> > +       rcu_read_lock();
> > +       nfp_flow = nfp_flower_find_in_fl_table(app, flower_cookie);
> > +       if (!nfp_flow)
> > +               goto exit_rcu_unlock;
> > +
> > +       if (nfp_flow->meta.host_ctx_id != stats->stats_con_id)
> > +               goto exit_rcu_unlock;
> > +
> > +       spin_lock(&nfp_flow->lock);
> > +       nfp_flow->stats.pkts += be32_to_cpu(stats->pkt_count);
> > +       nfp_flow->stats.bytes += be64_to_cpu(stats->byte_count);
> 
> you're using += with the values you get form the fw, are they incremental?

Yes, they are incremental.

> 
> > +       nfp_flow->stats.used = jiffies;
> 
> if nothing was changed since your last reading, it's wrong to say that
> used == NOW

This function is called on receipt of a message from the firmware.
And the firmware will only send a message if there is a change in
the counters.

> 
> > +       spin_unlock(&nfp_flow->lock);
> 
> if indeed you need to keep a clone of earlier calls to correctly
> compute the (last)used value,
> maybe you can get rid of the locking?
