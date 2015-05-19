From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 3/4] rocker: do not make neighbour entry changes
 when preparing transactions
Date: Wed, 20 May 2015 07:33:27 +0900
Message-ID: <20150519223325.GA18883@penelope.isobedori.kobe.vergenet.net>
References: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
 <1432016657-24231-4-git-send-email-simon.horman@netronome.com>
 <CAE4R7bBZTPeD4PM8xfxvEn0FSwCnWNwPt4FLAf38=7KdQn=s+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35374 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbbESWdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 18:33:37 -0400
Received: by pdea3 with SMTP id a3so43160163pde.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 15:33:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBZTPeD4PM8xfxvEn0FSwCnWNwPt4FLAf38=7KdQn=s+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 09:11:29AM -0700, Scott Feldman wrote:
> On Mon, May 18, 2015 at 11:24 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > rocker_port_ipv4_nh() and in turn rocker_port_ipv4_neigh() may be
> > be called with trans == SWITCHDEV_TRANS_PREPARE and then
> > trans == SWITCHDEV_TRANS_COMMIT from switchdev_port_obj_set() via
> > fib_table_insert().
> >
> > Although I have been unable to find a scenario where a bug manifests
> > I do see some incorrect behaviour when adding a fib entry with a gateway.
> >
> > The first time that rocker_port_ipv4_nh() is called, with
> > trans == SWITCHDEV_TRANS_PREPARE, _rocker_neigh_add()
> > adds a new entry to the neigh table.
> >
> > And the second time  rocker_port_ipv4_nh() is called, with
> > trans == SWITCHDEV_TRANS_COMMIT, that entry is found and
> > _rocker_neigh_update() is called.
> >
> > Assuming the transaction runs to completion this appears to be harmless.
> > I suspect it would be not correct if the transaction was aborted.
> >
> > This problem does not appear to affect deletion as my analysis is
> > that deletion is always performed with trans == SWITCHDEV_TRANS_NONE.
> >
> > For completeness _rocker_neigh_{add,del,prepare} are updated not
> > to manipulate fib table entries if trans == SWITCHDEV_TRANS_PREPARE.
> >
> > Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  drivers/net/ethernet/rocker/rocker.c | 16 ++++++++++++----
> >  1 file changed, 12 insertions(+), 4 deletions(-)
> >
> 
> [cut]
> 
> > @@ -2928,8 +2933,11 @@ static void _rocker_neigh_del(struct rocker_port *rocker_port,
> >  }
> >
> >  static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
> > +                                enum switchdev_trans trans,
> >                                  u8 *eth_dst, bool ttl_check)
> >  {
> > +       if (trans == SWITCHDEV_TRANS_PREPARE)
> > +               return;
> 
> On this one, let move the trans==PREPARE test to the else branch, in
> case someone down the line is dependent on eth_dst and ttl_check being
> copied over.
> 
> Everything else in the patch looks good.

Thanks Scott, I'll adjust things as you suggest.
